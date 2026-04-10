import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_bloc.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_event.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_state.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/generate_ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/get_product_detail.dart';
import 'package:skelter/services/performance_monitoring_service.dart';

class MockGetProductDetail extends Mock implements GetProductDetail {}

class MockGenerateAIProductDescription extends Mock
    implements GenerateAIProductDescription {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late ProductDetailBloc bloc;
  late MockGetProductDetail mockGetProductDetail;
  late MockGenerateAIProductDescription mockGenerateAIDescription;
  late MockPerformanceMonitoringService mockPerformanceService;

  const tProductDetail = ProductDetail(
    id: '1',
    title: 'Test Product',
    price: 49.99,
    description: 'Test description',
    category: 'Electronics',
    image: 'img.png',
    rating: 4.5,
    productImages: ['img1.png', 'img2.png'],
  );

  final tAIDescription = AIProductDescription(
    productId: '1',
    generatedDescription: 'AI generated description',
    generatedAt: DateTime(2024, 1, 15),
    isPersonalized: false,
  );

  setUpAll(() {
    registerFallbackValue(const GetProductDetailParams(id: '1'));
    registerFallbackValue(
      const GenerateAIProductDescriptionParams(productDetail: tProductDetail),
    );
  });

  setUp(() {
    mockGetProductDetail = MockGetProductDetail();
    mockGenerateAIDescription = MockGenerateAIProductDescription();
    mockPerformanceService = MockPerformanceMonitoringService();

    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    bloc = ProductDetailBloc(
      getProductDetail: mockGetProductDetail,
      generateAIProductDescription: mockGenerateAIDescription,
    );
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('ProductDetailBloc', () {
    test('initial state should be ProductDetailState.initial()', () {
      expect(bloc.state.selectedImageIndex, equals(0));
      expect(bloc.state.productDetail, isNull);
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.aiDescription, isNull);
      expect(bloc.state.isGeneratingAIDescription, isFalse);
    });

    group('GetProductDetailDataEvent', () {
      blocTest<ProductDetailBloc, ProductDetailState>(
        'should emit [Loading, Loaded] on success',
        build: () {
          when(
            () => mockGetProductDetail(any()),
          ).thenAnswer((_) async => const Right(tProductDetail));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GetProductDetailDataEvent(productId: '1')),
        expect: () => [
          isA<ProductDetailLoading>(),
          isA<ProductDetailLoadedState>().having(
            (s) => s.productDetail,
            'productDetail',
            tProductDetail,
          ),
        ],
        verify: (_) {
          verify(() => mockGetProductDetail(any())).called(1);
        },
      );

      blocTest<ProductDetailBloc, ProductDetailState>(
        'should emit [Loading, Error] on failure',
        build: () {
          when(() => mockGetProductDetail(any())).thenAnswer(
            (_) async =>
                const Left(APIFailure(message: 'Not Found', statusCode: 404)),
          );
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GetProductDetailDataEvent(productId: '1')),
        expect: () => [
          isA<ProductDetailLoading>(),
          isA<ProductDetailErrorState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Not Found'),
          ),
        ],
      );
    });

    group('ProductImageSelectedEvent', () {
      blocTest<ProductDetailBloc, ProductDetailState>(
        'should update selectedImageIndex',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const ProductImageSelectedEvent(selectedIndex: 2)),
        expect: () => [
          isA<ProductDetailState>().having(
            (s) => s.selectedImageIndex,
            'selectedImageIndex',
            2,
          ),
        ],
      );
    });

    group('GenerateAIDescriptionEvent', () {
      blocTest<ProductDetailBloc, ProductDetailState>(
        'should emit [Generating, Generated] on success',
        build: () {
          when(
            () => mockGenerateAIDescription(any()),
          ).thenAnswer((_) async => Right(tAIDescription));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const GenerateAIDescriptionEvent(productDetail: tProductDetail),
        ),
        expect: () => [
          isA<AIDescriptionGenerating>().having(
            (s) => s.isGeneratingAIDescription,
            'isGenerating',
            true,
          ),
          isA<AIDescriptionGenerated>().having(
            (s) => s.aiDescription,
            'aiDescription',
            tAIDescription,
          ),
        ],
      );

      blocTest<ProductDetailBloc, ProductDetailState>(
        'should emit [Generating, Error] on failure',
        build: () {
          when(() => mockGenerateAIDescription(any())).thenAnswer(
            (_) async =>
                const Left(APIFailure(message: 'AI Error', statusCode: 500)),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const GenerateAIDescriptionEvent(productDetail: tProductDetail),
        ),
        expect: () => [
          isA<AIDescriptionGenerating>(),
          isA<AIDescriptionError>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('AI Error'),
          ),
        ],
      );

      blocTest<ProductDetailBloc, ProductDetailState>(
        'should pass userOrderHistory when provided',
        build: () {
          when(
            () => mockGenerateAIDescription(any()),
          ).thenAnswer((_) async => Right(tAIDescription));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const GenerateAIDescriptionEvent(
            productDetail: tProductDetail,
            userOrderHistory: ['Electronics', 'Books'],
          ),
        ),
        expect: () => [
          isA<AIDescriptionGenerating>(),
          isA<AIDescriptionGenerated>(),
        ],
      );

      blocTest<ProductDetailBloc, ProductDetailState>(
        'should emit AIDescriptionError when usecase throws exception',
        build: () {
          when(
            () => mockGenerateAIDescription(any()),
          ).thenThrow(Exception('Unexpected'));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const GenerateAIDescriptionEvent(productDetail: tProductDetail),
        ),
        expect: () => [
          isA<AIDescriptionGenerating>(),
          isA<AIDescriptionError>(),
        ],
      );
    });
  });
}
