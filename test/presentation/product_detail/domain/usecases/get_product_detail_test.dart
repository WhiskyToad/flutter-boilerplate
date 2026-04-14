import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/data/models/product_detail_model.dart';
import 'package:skelter/presentation/product_detail/domain/repositories/product_detail_repository.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/get_product_detail.dart';

class MockProductDetailRepository extends Mock
    implements ProductDetailRepository {}

void main() {
  late GetProductDetail useCase;
  late MockProductDetailRepository mockRepository;

  setUp(() {
    mockRepository = MockProductDetailRepository();
    useCase = GetProductDetail(mockRepository);
  });

  const tProductDetail = ProductDetailModel(
    id: '1',
    title: 'Test Product',
    price: 49.99,
    description: 'A test product',
    category: 'Electronics',
    image: 'img.png',
    rating: 4.5,
    productImages: ['img1.png', 'img2.png'],
  );

  const tParams = GetProductDetailParams(id: '1');

  group('GetProductDetail', () {
    test('should get product detail from the repository', () async {
      when(
        () => mockRepository.getProductDetail(id: any(named: 'id')),
      ).thenAnswer((_) async => const Right(tProductDetail));

      final result = await useCase(tParams);

      expect(result, const Right(tProductDetail));
      verify(() => mockRepository.getProductDetail(id: '1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      const tFailure = APIFailure(message: 'Not Found', statusCode: 404);
      when(
        () => mockRepository.getProductDetail(id: any(named: 'id')),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('GetProductDetailParams', () {
    test('should store the id correctly', () {
      expect(tParams.id, equals('1'));
    });
  });
}
