import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/presentation/product_detail/domain/repositories/ai_product_description_repository.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/generate_ai_product_description.dart';

class MockAIProductDescriptionRepository extends Mock
    implements AIProductDescriptionRepository {}

void main() {
  late GenerateAIProductDescription useCase;
  late MockAIProductDescriptionRepository mockRepository;

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
    mockRepository = MockAIProductDescriptionRepository();
    useCase = GenerateAIProductDescription(mockRepository);
  });

  const tProductDetail = ProductDetail(
    id: '1',
    title: 'Test Product',
    price: 49.99,
    description: 'Original description',
    category: 'Electronics',
    image: 'img.png',
    rating: 4.5,
    productImages: ['img1.png'],
  );

  final tAIDescription = AIProductDescription(
    productId: '1',
    generatedDescription: 'AI generated description',
    generatedAt: DateTime(2024, 1, 15),
    isPersonalized: false,
  );

  const tParams = GenerateAIProductDescriptionParams(
    productDetail: tProductDetail,
  );

  const tParamsWithHistory = GenerateAIProductDescriptionParams(
    productDetail: tProductDetail,
    userOrderHistory: ['Electronics', 'Books'],
  );

  group('GenerateAIProductDescription', () {
    test('should call repository with correct params', () async {
      when(
        () => mockRepository.generateProductDescription(
          productDetail: any(named: 'productDetail'),
          userOrderHistory: any(named: 'userOrderHistory'),
        ),
      ).thenAnswer((_) async => Right(tAIDescription));

      final result = await useCase(tParams);

      expect(result, Right(tAIDescription));
      verify(
        () => mockRepository.generateProductDescription(
          productDetail: tProductDetail,
          userOrderHistory: null,
        ),
      ).called(1);
    });

    test('should pass userOrderHistory when provided', () async {
      when(
        () => mockRepository.generateProductDescription(
          productDetail: any(named: 'productDetail'),
          userOrderHistory: any(named: 'userOrderHistory'),
        ),
      ).thenAnswer((_) async => Right(tAIDescription));

      await useCase(tParamsWithHistory);

      verify(
        () => mockRepository.generateProductDescription(
          productDetail: tProductDetail,
          userOrderHistory: ['Electronics', 'Books'],
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      const tFailure = APIFailure(message: 'AI Error', statusCode: 500);
      when(
        () => mockRepository.generateProductDescription(
          productDetail: any(named: 'productDetail'),
          userOrderHistory: any(named: 'userOrderHistory'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('GenerateAIProductDescriptionParams', () {
    test('should support Equatable comparison', () {
      const params1 = GenerateAIProductDescriptionParams(
        productDetail: tProductDetail,
      );
      const params2 = GenerateAIProductDescriptionParams(
        productDetail: tProductDetail,
      );

      expect(params1, equals(params2));
    });

    test('params with different history should not be equal', () {
      expect(tParams, isNot(equals(tParamsWithHistory)));
    });
  });
}
