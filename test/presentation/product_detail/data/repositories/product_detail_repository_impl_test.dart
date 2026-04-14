import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/data/datasources/product_detail_remote_data_source.dart';
import 'package:skelter/presentation/product_detail/data/models/product_detail_model.dart';
import 'package:skelter/presentation/product_detail/data/repositories/product_detail_repository_impl.dart';

class MockProductDetailRemoteDatasource extends Mock
    implements ProductDetailRemoteDatasource {}

void main() {
  late ProductDetailRepositoryImpl repository;
  late MockProductDetailRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockProductDetailRemoteDatasource();
    repository = ProductDetailRepositoryImpl(mockDatasource);
  });

  const tProductDetail = ProductDetailModel(
    id: '1',
    title: 'Test Product',
    price: 49.99,
    description: 'Test description',
    category: 'Electronics',
    image: 'img.png',
    rating: 4.5,
    productImages: ['img1.png', 'img2.png'],
  );

  group('getProductDetail', () {
    test('should return product detail when datasource succeeds', () async {
      when(
        () => mockDatasource.getProductDetail(id: any(named: 'id')),
      ).thenAnswer((_) async => tProductDetail);

      final result = await repository.getProductDetail(id: '1');

      expect(result, const Right(tProductDetail));
      verify(() => mockDatasource.getProductDetail(id: '1')).called(1);
    });

    test(
      'should return APIFailure when datasource throws APIException',
      () async {
        const tException = APIException(message: 'Not Found', statusCode: 404);
        when(
          () => mockDatasource.getProductDetail(id: any(named: 'id')),
        ).thenThrow(tException);

        final result = await repository.getProductDetail(id: '1');

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
  });
}
