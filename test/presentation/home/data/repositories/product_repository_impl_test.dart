import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/home/data/datasources/product_remote_data_source.dart';
import 'package:skelter/presentation/home/data/models/product_model.dart';
import 'package:skelter/presentation/home/data/repositories/product_repository_impl.dart';

class MockProductRemoteDatasource extends Mock
    implements ProductRemoteDatasource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockProductRemoteDatasource();
    repository = ProductRepositoryImpl(mockDatasource);
  });

  const tProducts = [
    ProductModel(
      id: '1',
      title: 'Product 1',
      price: 10.0,
      description: 'Desc 1',
      category: 'Cat 1',
      image: 'img1.png',
      rating: 4.5,
      reviews: 100,
      availableQuantities: 50,
      seller: 'Seller 1',
    ),
  ];

  group('getProducts', () {
    test('should return list of products when datasource succeeds', () async {
      when(
        () => mockDatasource.getProducts(),
      ).thenAnswer((_) async => tProducts);

      final result = await repository.getProducts();

      expect(result, const Right(tProducts));
      verify(() => mockDatasource.getProducts()).called(1);
    });

    test(
      'should return APIFailure when datasource throws APIException',
      () async {
        const tException = APIException(
          message: 'Server Error',
          statusCode: 500,
        );
        when(() => mockDatasource.getProducts()).thenThrow(tException);

        final result = await repository.getProducts();

        expect(
          result,
          Left(
            APIFailure(
              message: tException.message,
              statusCode: tException.statusCode,
            ),
          ),
        );
      },
    );

    test('should return empty list when datasource returns empty', () async {
      when(() => mockDatasource.getProducts()).thenAnswer((_) async => []);

      final result = await repository.getProducts();

      result.fold(
        (_) => fail('Should not return failure'),
        (products) => expect(products, isEmpty),
      );
    });
  });
}
