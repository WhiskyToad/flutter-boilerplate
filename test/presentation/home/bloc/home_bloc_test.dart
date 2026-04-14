import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/home/bloc/home_bloc.dart';
import 'package:skelter/presentation/home/bloc/home_event.dart';
import 'package:skelter/presentation/home/bloc/home_state.dart';
import 'package:skelter/presentation/home/data/models/product_model.dart';
import 'package:skelter/presentation/home/domain/usecases/get_products.dart';
import 'package:skelter/services/performance_monitoring_service.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late HomeBloc homeBloc;
  late MockGetProducts mockGetProducts;
  late MockPerformanceMonitoringService mockPerformanceService;

  const tProducts = [
    ProductModel(
      id: '1',
      title: 'Test Laptop',
      price: 999.99,
      description: 'A test laptop',
      category: 'Electronics',
      image: 'laptop.png',
      rating: 4.5,
      reviews: 100,
      availableQuantities: 50,
      seller: 'TechSeller',
    ),
    ProductModel(
      id: '2',
      title: 'Test Phone',
      price: 699.99,
      description: 'A test phone',
      category: 'Electronics',
      image: 'phone.png',
      rating: 4.2,
      reviews: 200,
      availableQuantities: 100,
      seller: 'PhoneSeller',
    ),
    ProductModel(
      id: '3',
      title: 'Test Book',
      price: 19.99,
      description: 'A test book',
      category: 'Books',
      image: 'book.png',
      rating: 4.8,
      reviews: 50,
      availableQuantities: 200,
      seller: 'BookSeller',
    ),
  ];

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockPerformanceService = MockPerformanceMonitoringService();

    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    homeBloc = HomeBloc(getProducts: mockGetProducts);
  });

  tearDown(() {
    homeBloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('HomeBloc', () {
    test('initial state should be HomeState.initial()', () {
      expect(homeBloc.state.currentBottomNavIndex, equals(0));
      expect(homeBloc.state.topProducts, isEmpty);
      expect(homeBloc.state.filteredProducts, isEmpty);
      expect(homeBloc.state.searchQuery, isEmpty);
      expect(homeBloc.state.shouldAnimateListenIcon, isFalse);
    });

    group('BottomNavBarIndexChangedEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should emit state with updated bottom nav index',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const BottomNavBarIndexChangedEvent(index: 2)),
        expect: () => [
          isA<HomeState>().having((s) => s.currentBottomNavIndex, 'index', 2),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should update index to 0',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const BottomNavBarIndexChangedEvent(index: 0)),
        expect: () => [
          isA<HomeState>().having((s) => s.currentBottomNavIndex, 'index', 0),
        ],
      );
    });

    group('GetTopProductDataEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should emit [ProductLoadingState, TopProductsLoadedState] on success',
        build: () {
          when(
            () => mockGetProducts(),
          ).thenAnswer((_) async => const Right(tProducts));
          return homeBloc;
        },
        act: (bloc) => bloc.add(const GetTopProductDataEvent()),
        expect: () => [
          isA<ProductLoadingState>(),
          isA<TopProductsLoadedState>().having(
            (s) => s.topProducts.length,
            'products count',
            3,
          ),
        ],
        verify: (_) {
          verify(() => mockGetProducts()).called(1);
          verify(() => mockPerformanceService.startTrace(any())).called(1);
          verify(() => mockPerformanceService.stopTrace(any())).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should emit [ProductLoadingState, AuthenticationError] on failure',
        build: () {
          when(() => mockGetProducts()).thenAnswer(
            (_) async => const Left(
              APIFailure(message: 'Server Error', statusCode: 500),
            ),
          );
          return homeBloc;
        },
        act: (bloc) => bloc.add(const GetTopProductDataEvent()),
        expect: () => [isA<ProductLoadingState>(), isA<AuthenticationError>()],
      );
    });

    group('FilterProductsEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should filter products based on search query',
        build: () {
          when(
            () => mockGetProducts(),
          ).thenAnswer((_) async => const Right(tProducts));
          return homeBloc;
        },
        seed: () => HomeState(
          currentBottomNavIndex: 0,
          topProducts: tProducts,
          filteredProducts: tProducts,
        ),
        act: (bloc) =>
            bloc.add(const FilterProductsEvent(searchQuery: 'laptop')),
        expect: () => [
          isA<HomeState>()
              .having((s) => s.filteredProducts.length, 'filtered count', 1)
              .having(
                (s) => s.filteredProducts.first.title,
                'first title',
                'Test Laptop',
              )
              .having((s) => s.searchQuery, 'searchQuery', 'laptop'),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should return empty list when no products match',
        build: () => homeBloc,
        seed: () => HomeState(
          currentBottomNavIndex: 0,
          topProducts: tProducts,
          filteredProducts: tProducts,
        ),
        act: (bloc) =>
            bloc.add(const FilterProductsEvent(searchQuery: 'xyz123')),
        expect: () => [
          isA<HomeState>().having(
            (s) => s.filteredProducts,
            'filtered',
            isEmpty,
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should be case-insensitive when filtering',
        build: () => homeBloc,
        seed: () => HomeState(
          currentBottomNavIndex: 0,
          topProducts: tProducts,
          filteredProducts: tProducts,
        ),
        act: (bloc) =>
            bloc.add(const FilterProductsEvent(searchQuery: 'PHONE')),
        expect: () => [
          isA<HomeState>().having(
            (s) => s.filteredProducts.length,
            'filtered count',
            1,
          ),
        ],
      );
    });

    group('ToggleSpeechAnimationEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should set shouldAnimateListenIcon to true',
        build: () => homeBloc,
        act: (bloc) => bloc.add(
          const ToggleSpeechAnimationEvent(shouldAnimateListenIcon: true),
        ),
        expect: () => [
          isA<HomeState>().having(
            (s) => s.shouldAnimateListenIcon,
            'animate',
            true,
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should set shouldAnimateListenIcon to false',
        build: () => homeBloc,
        seed: () => HomeState(
          currentBottomNavIndex: 0,
          topProducts: const [],
          filteredProducts: const [],
          shouldAnimateListenIcon: true,
        ),
        act: (bloc) => bloc.add(
          const ToggleSpeechAnimationEvent(shouldAnimateListenIcon: false),
        ),
        expect: () => [
          isA<HomeState>().having(
            (s) => s.shouldAnimateListenIcon,
            'animate',
            false,
          ),
        ],
      );
    });

    group('StopSpeechToTextEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should set shouldAnimateListenIcon to false',
        build: () => homeBloc,
        seed: () => HomeState(
          currentBottomNavIndex: 0,
          topProducts: const [],
          filteredProducts: const [],
          shouldAnimateListenIcon: true,
        ),
        act: (bloc) => bloc.add(const StopSpeechToTextEvent()),
        expect: () => [
          isA<HomeState>().having(
            (s) => s.shouldAnimateListenIcon,
            'animate',
            false,
          ),
        ],
      );
    });

    group('MicrophoneVoiceInputCompleteEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should emit MicrophoneVoiceInputtedState with search results',
        build: () => homeBloc,
        seed: () => HomeState(
          currentBottomNavIndex: 0,
          topProducts: tProducts,
          filteredProducts: const [],
          shouldAnimateListenIcon: true,
        ),
        act: (bloc) => bloc.add(
          MicrophoneVoiceInputCompleteEvent(
            searchQuery: 'Test Phone',
            filteredProducts: [tProducts[1]],
          ),
        ),
        expect: () => [
          isA<MicrophoneVoiceInputtedState>()
              .having((s) => s.searchQuery, 'query', 'Test Phone')
              .having((s) => s.filteredProducts.length, 'count', 1)
              .having((s) => s.shouldAnimateListenIcon, 'animate', false),
        ],
      );
    });
  });
}
