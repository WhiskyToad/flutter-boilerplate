import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/home/domain/entities/product.dart';

void main() {
  const tProduct = Product(
    id: '1',
    image: 'image.png',
    title: 'Test Product',
    description: 'A test product',
    category: 'Electronics',
    rating: 4.5,
    reviews: 100,
    availableQuantities: 50,
    price: 29.99,
    seller: 'Test Seller',
  );

  group('Product', () {
    test('should create with required fields', () {
      expect(tProduct.id, equals('1'));
      expect(tProduct.image, equals('image.png'));
      expect(tProduct.title, equals('Test Product'));
      expect(tProduct.description, equals('A test product'));
      expect(tProduct.category, equals('Electronics'));
      expect(tProduct.rating, equals(4.5));
      expect(tProduct.reviews, equals(100));
      expect(tProduct.availableQuantities, equals(50));
      expect(tProduct.price, equals(29.99));
      expect(tProduct.seller, equals('Test Seller'));
    });

    test('two Products with same data should be equal', () {
      const product2 = Product(
        id: '1',
        image: 'image.png',
        title: 'Test Product',
        description: 'A test product',
        category: 'Electronics',
        rating: 4.5,
        reviews: 100,
        availableQuantities: 50,
        price: 29.99,
        seller: 'Test Seller',
      );

      expect(tProduct, equals(product2));
    });

    test('two Products with different data should not be equal', () {
      const product2 = Product(
        id: '2',
        image: 'different.png',
        title: 'Different',
        description: 'Different',
        category: 'Books',
        rating: 3.0,
        reviews: 10,
        availableQuantities: 5,
        price: 9.99,
        seller: 'Other',
      );

      expect(tProduct, isNot(equals(product2)));
    });

    test('props should contain all fields', () {
      expect(
        tProduct.props,
        equals([
          '1',
          'image.png',
          'Test Product',
          'A test product',
          'Electronics',
          4.5,
          100,
          50,
          29.99,
          'Test Seller',
        ]),
      );
    });
  });
}
