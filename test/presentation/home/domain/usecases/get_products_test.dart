import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/home/data/models/product_model.dart';
import 'package:skelter/presentation/home/domain/repositories/product_repository.dart';
import 'package:skelter/presentation/home/domain/usecases/get_products.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(mockRepository);
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
    ProductModel(
      id: '2',
      title: 'Product 2',
      price: 20.0,
      description: 'Desc 2',
      category: 'Cat 2',
      image: 'img2.png',
      rating: 3.8,
      reviews: 50,
      availableQuantities: 25,
      seller: 'Seller 2',
    ),
  ];

  group('GetProducts', () {
    test('should get list of products from the repository', () async {
      when(
        () => mockRepository.getProducts(),
      ).thenAnswer((_) async => const Right(tProducts));

      final result = await useCase();

      expect(result, const Right(tProducts));
      verify(() => mockRepository.getProducts()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      const tFailure = APIFailure(message: 'Server Error', statusCode: 500);
      when(
        () => mockRepository.getProducts(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase();

      expect(result, const Left(tFailure));
      verify(() => mockRepository.getProducts()).called(1);
    });

    test('should return empty list when no products found', () async {
      when(
        () => mockRepository.getProducts(),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase();

      result.fold(
        (_) => fail('Should not return failure'),
        (products) => expect(products, isEmpty),
      );
    });
  });
}
