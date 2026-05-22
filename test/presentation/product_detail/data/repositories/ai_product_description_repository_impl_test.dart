import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/data/datasources/ai_product_description_remote_data_source.dart';
import 'package:skelter/presentation/product_detail/data/models/ai_product_description_model.dart';
import 'package:skelter/presentation/product_detail/data/repositories/ai_product_description_repository_impl.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';

class MockAIProductDescriptionRemoteDataSource extends Mock
    implements AIProductDescriptionRemoteDataSource {}

void main() {
  late AIProductDescriptionRepositoryImpl repository;
  late MockAIProductDescriptionRemoteDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(
      const ProductDetail(
        id: '',
        title: '',
        price: 0,
        description: '',
        category: '',
        image: '',
        rating: 0,
        productImages: [],
      ),
    );
  });

  setUp(() {
    mockDataSource = MockAIProductDescriptionRemoteDataSource();
    repository = AIProductDescriptionRepositoryImpl(mockDataSource);
  });

  const tProductDetail = ProductDetail(
    id: '1',
    title: 'Test Product',
    price: 49.99,
    description: 'Test description',
    category: 'Electronics',
    image: 'img.png',
    rating: 4.5,
    productImages: ['img1.png'],
  );

  final tAIModel = AIProductDescriptionModel(
    productId: '1',
    generatedDescription: 'AI generated',
    generatedAt: DateTime(2024, 1, 15),
  );

  group('generateProductDescription', () {
    test('should return AI description when datasource succeeds', () async {
      when(
        () => mockDataSource.generateProductDescription(
          productDetail: any(named: 'productDetail'),
          userOrderHistory: any(named: 'userOrderHistory'),
        ),
      ).thenAnswer((_) async => tAIModel);

      final result = await repository.generateProductDescription(
        productDetail: tProductDetail,
      );

      result.fold((_) => fail('Should not return failure'), (description) {
        expect(description.productId, equals('1'));
        expect(description.generatedDescription, equals('AI generated'));
      });
    });

    test('should pass userOrderHistory to datasource', () async {
      when(
        () => mockDataSource.generateProductDescription(
          productDetail: any(named: 'productDetail'),
          userOrderHistory: any(named: 'userOrderHistory'),
        ),
      ).thenAnswer((_) async => tAIModel);

      await repository.generateProductDescription(
        productDetail: tProductDetail,
        userOrderHistory: ['Electronics', 'Books'],
      );

      verify(
        () => mockDataSource.generateProductDescription(
          productDetail: tProductDetail,
          userOrderHistory: ['Electronics', 'Books'],
        ),
      ).called(1);
    });

    test(
      'should return APIFailure when datasource throws APIException',
      () async {
        const tException = APIException(message: 'AI Error', statusCode: 500);
        when(
          () => mockDataSource.generateProductDescription(
            productDetail: any(named: 'productDetail'),
            userOrderHistory: any(named: 'userOrderHistory'),
          ),
        ).thenThrow(tException);

        final result = await repository.generateProductDescription(
          productDetail: tProductDetail,
        );

        expect(
          result,
          const Left(APIFailure(message: 'AI Error', statusCode: 500)),
        );
      },
    );

    test(
      'should return APIFailure when datasource throws generic exception',
      () async {
        when(
          () => mockDataSource.generateProductDescription(
            productDetail: any(named: 'productDetail'),
            userOrderHistory: any(named: 'userOrderHistory'),
          ),
        ).thenThrow(Exception('Something went wrong'));

        final result = await repository.generateProductDescription(
          productDetail: tProductDetail,
        );

        result.fold((failure) {
          expect(failure, isA<APIFailure>());
          expect(failure.statusCode, equals(500));
        }, (_) => fail('Should return failure'));
      },
    );
  });

  group('generateProductDescriptionStream', () {
    test('should yield chunks from datasource stream', () async {
      when(
        () => mockDataSource.generateProductDescriptionStream(
          productDetail: any(named: 'productDetail'),
          userOrderHistory: any(named: 'userOrderHistory'),
        ),
      ).thenAnswer((_) => Stream.fromIterable(['Hello', ' World']));

      final results = await repository
          .generateProductDescriptionStream(productDetail: tProductDetail)
          .toList();

      expect(results.length, equals(2));
      expect(results[0].isRight(), isTrue);
      expect(results[1].isRight(), isTrue);
    });

    test(
      'should yield failure when datasource stream throws APIException',
      () async {
        when(
          () => mockDataSource.generateProductDescriptionStream(
            productDetail: any(named: 'productDetail'),
            userOrderHistory: any(named: 'userOrderHistory'),
          ),
        ).thenThrow(
          const APIException(message: 'Stream Error', statusCode: 500),
        );

        final results = await repository
            .generateProductDescriptionStream(productDetail: tProductDetail)
            .toList();

        expect(results.length, equals(1));
        expect(results[0].isLeft(), isTrue);
      },
    );
  });
}
