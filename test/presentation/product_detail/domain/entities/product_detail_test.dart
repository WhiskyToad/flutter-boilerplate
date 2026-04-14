import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';

void main() {
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

  group('ProductDetail', () {
    test('should create with required fields', () {
      expect(tProductDetail.id, equals('1'));
      expect(tProductDetail.title, equals('Test Product'));
      expect(tProductDetail.price, equals(49.99));
      expect(tProductDetail.productImages.length, equals(2));
    });

    test('two entities with same data should be equal', () {
      const entity2 = ProductDetail(
        id: '1',
        title: 'Test Product',
        price: 49.99,
        description: 'Test description',
        category: 'Electronics',
        image: 'img.png',
        rating: 4.5,
        productImages: ['img1.png', 'img2.png'],
      );

      expect(tProductDetail, equals(entity2));
    });

    test('two entities with different data should not be equal', () {
      const entity2 = ProductDetail(
        id: '2',
        title: 'Different',
        price: 99.99,
        description: 'Other',
        category: 'Books',
        image: 'other.png',
        rating: 3.0,
        productImages: [],
      );

      expect(tProductDetail, isNot(equals(entity2)));
    });
  });
}
