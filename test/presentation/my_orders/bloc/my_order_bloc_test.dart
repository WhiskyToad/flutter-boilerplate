import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/home/data/models/product_model.dart';
import 'package:skelter/presentation/home/domain/usecases/get_products.dart';
import 'package:skelter/presentation/my_orders/bloc/my_order_bloc.dart';
import 'package:skelter/presentation/my_orders/bloc/my_order_event.dart';
import 'package:skelter/presentation/my_orders/bloc/my_order_state.dart';
import 'package:skelter/presentation/product_detail/data/models/product_detail_model.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/get_product_detail.dart';
import 'package:skelter/services/performance_monitoring_service.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockGetProductDetail extends Mock implements GetProductDetail {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late MyOrderBloc bloc;
  late MockGetProducts mockGetProducts;
  late MockGetProductDetail mockGetProductDetail;
  late MockPerformanceMonitoringService mockPerformanceService;
  late MockAppLocalizations mockLocalizations;

  const tProducts = [
    ProductModel(
      id: '1',
      title: 'Order Product',
      price: 29.99,
      description: 'Ordered item',
      category: 'Electronics',
      image: 'img.png',
      rating: 4.5,
      reviews: 10,
      availableQuantities: 5,
      seller: 'Seller',
    ),
  ];

  const tProductDetail = ProductDetailModel(
    id: '1',
    title: 'Order Product',
    price: 29.99,
    description: 'Ordered item',
    category: 'Electronics',
    image: 'img.png',
    rating: 4.5,
    productImages: ['img1.png'],
  );

  setUpAll(() {
    registerFallbackValue(const GetProductDetailParams(id: '1'));
  });

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetProductDetail = MockGetProductDetail();
    mockPerformanceService = MockPerformanceMonitoringService();
    mockLocalizations = MockAppLocalizations();

    when(
      () => mockLocalizations.no_product_selected,
    ).thenReturn('No product selected');
    when(
      () => mockLocalizations.storage_permission_required,
    ).thenReturn('Storage permission required');

    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    bloc = MyOrderBloc(
      getProducts: mockGetProducts,
      getProductDetail: mockGetProductDetail,
      localizations: mockLocalizations,
    );
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('MyOrderBloc', () {
    test('initial state should have empty products', () {
      expect(bloc.state.products, isEmpty);
      expect(bloc.state.selectedProductDetail, isNull);
      expect(bloc.state.isGeneratingInvoice, isFalse);
    });

    group('GetMyOrderProductsEvent', () {
      blocTest<MyOrderBloc, MyOrderState>(
        'should emit [Loading, Loaded] on success',
        build: () {
          when(
            () => mockGetProducts(),
          ).thenAnswer((_) async => const Right(tProducts));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetMyOrderProductsEvent()),
        expect: () => [
          isA<MyOrderLoadingState>(),
          isA<MyOrderLoadedState>().having(
            (s) => s.products.length,
            'products count',
            1,
          ),
        ],
      );

      blocTest<MyOrderBloc, MyOrderState>(
        'should emit [Loading, Error] on failure',
        build: () {
          when(() => mockGetProducts()).thenAnswer(
            (_) async =>
                const Left(APIFailure(message: 'Error', statusCode: 500)),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const GetMyOrderProductsEvent()),
        expect: () => [isA<MyOrderLoadingState>(), isA<MyOrderErrorState>()],
      );
    });

    group('GetOrderProductDetailEvent', () {
      blocTest<MyOrderBloc, MyOrderState>(
        'should emit [Loading, Loaded] on success',
        build: () {
          when(
            () => mockGetProductDetail(any()),
          ).thenAnswer((_) async => const Right(tProductDetail));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GetOrderProductDetailEvent(productId: '1')),
        expect: () => [
          isA<ProductDetailLoadingState>(),
          isA<ProductDetailLoadedState>().having(
            (s) => s.selectedProductDetail,
            'productDetail',
            tProductDetail,
          ),
        ],
      );

      blocTest<MyOrderBloc, MyOrderState>(
        'should emit [Loading, Error] on failure',
        build: () {
          when(() => mockGetProductDetail(any())).thenAnswer(
            (_) async =>
                const Left(APIFailure(message: 'Not Found', statusCode: 404)),
          );
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GetOrderProductDetailEvent(productId: '999')),
        expect: () => [
          isA<ProductDetailLoadingState>(),
          isA<ProductDetailErrorState>(),
        ],
      );
    });

    group('GenerateInvoiceEvent', () {
      blocTest<MyOrderBloc, MyOrderState>(
        'should emit error when no product detail selected',
        build: () => bloc,
        act: (bloc) => bloc.add(const GenerateInvoiceEvent()),
        expect: () => [
          isA<MyOrderState>().having(
            (s) => s.invoiceGenerationError,
            'error',
            'No product selected',
          ),
        ],
      );
    });

    group('ClearInvoiceGenerationErrorEvent', () {
      blocTest<MyOrderBloc, MyOrderState>(
        'should clear invoice generation error',
        build: () => bloc,
        act: (bloc) => bloc.add(const ClearInvoiceGenerationErrorEvent()),
        expect: () => [isA<MyOrderState>()],
      );
    });
  });
}
