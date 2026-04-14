import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/home/data/models/product_model.dart';
import 'package:skelter/presentation/home/domain/entities/product.dart';
import 'package:skelter/utils/typedef.dart';

void main() {
  const tProductModel = ProductModel(
    id: '1',
    title: 'Test Product',
    price: 29.99,
    description: 'A great product',
    category: 'Electronics',
    image: 'https://example.com/image.png',
    rating: 4.5,
    reviews: 100,
    availableQuantities: 50,
    seller: 'Test Seller',
  );

  final DataMap tMap = {
    'id': '1',
    'title': 'Test Product',
    'price': 29.99,
    'description': 'A great product',
    'category': 'Electronics',
    'image': 'https://example.com/image.png',
    'rating': 4.5,
    'reviews': 100,
    'availableQuantities': 50,
    'seller': 'Test Seller',
  };

  group('ProductModel', () {
    test('should be a subclass of Product entity', () {
      expect(tProductModel, isA<Product>());
    });

    group('fromMap', () {
      test('should return a valid model from a map', () {
        final result = ProductModel.fromMap(tMap);

        expect(result.id, equals('1'));
        expect(result.title, equals('Test Product'));
        expect(result.price, equals(29.99));
        expect(result.description, equals('A great product'));
        expect(result.category, equals('Electronics'));
        expect(result.image, equals('https://example.com/image.png'));
        expect(result.rating, equals(4.5));
        expect(result.reviews, equals(100));
        expect(result.availableQuantities, equals(50));
        expect(result.seller, equals('Test Seller'));
      });

      test('should handle price as int', () {
        final mapWithIntPrice = Map<String, dynamic>.from(tMap)..['price'] = 30;

        final result = ProductModel.fromMap(mapWithIntPrice);

        expect(result.price, equals(30.0));
        expect(result.price, isA<double>());
      });
    });

    group('fromJson', () {
      test('should return a valid model from a JSON string', () {
        final jsonString = jsonEncode(tMap);

        final result = ProductModel.fromJson(jsonString);

        expect(result.id, equals('1'));
        expect(result.title, equals('Test Product'));
        expect(result.price, equals(29.99));
      });
    });

    group('toMap', () {
      test('should return a map containing all the proper data', () {
        final result = tProductModel.toMap();

        expect(result, equals(tMap));
      });
    });

    group('toJson', () {
      test('should return a JSON string with proper data', () {
        final result = tProductModel.toJson();
        final decoded = jsonDecode(result) as DataMap;

        expect(decoded['id'], equals('1'));
        expect(decoded['title'], equals('Test Product'));
        expect(decoded['price'], equals(29.99));
      });
    });

    group('copyWith', () {
      test('should return a new model with updated title', () {
        final result = tProductModel.copyWith(title: 'Updated Title');

        expect(result.title, equals('Updated Title'));
        expect(result.id, equals(tProductModel.id));
        expect(result.price, equals(tProductModel.price));
      });

      test('should return a new model with updated price', () {
        final result = tProductModel.copyWith(price: 99.99);

        expect(result.price, equals(99.99));
        expect(result.title, equals(tProductModel.title));
      });

      test('should return identical model when no params are passed', () {
        final result = tProductModel.copyWith();

        expect(result.id, equals(tProductModel.id));
        expect(result.title, equals(tProductModel.title));
        expect(result.price, equals(tProductModel.price));
        expect(result.description, equals(tProductModel.description));
        expect(result.category, equals(tProductModel.category));
        expect(result.image, equals(tProductModel.image));
        expect(result.rating, equals(tProductModel.rating));
        expect(result.reviews, equals(tProductModel.reviews));
        expect(
          result.availableQuantities,
          equals(tProductModel.availableQuantities),
        );
        expect(result.seller, equals(tProductModel.seller));
      });

      test('should update all fields when all params are provided', () {
        final result = tProductModel.copyWith(
          id: '2',
          title: 'New',
          price: 1.0,
          description: 'New desc',
          category: 'Books',
          image: 'new.png',
          rating: 3.0,
          reviews: 10,
          availableQuantities: 5,
          seller: 'New Seller',
        );

        expect(result.id, equals('2'));
        expect(result.title, equals('New'));
        expect(result.price, equals(1.0));
        expect(result.description, equals('New desc'));
        expect(result.category, equals('Books'));
        expect(result.image, equals('new.png'));
        expect(result.rating, equals(3.0));
        expect(result.reviews, equals(10));
        expect(result.availableQuantities, equals(5));
        expect(result.seller, equals('New Seller'));
      });
    });

    group('Equatable', () {
      test('two ProductModels with same data should be equal', () {
        const model1 = ProductModel(
          id: '1',
          title: 'Test Product',
          price: 29.99,
          description: 'A great product',
          category: 'Electronics',
          image: 'https://example.com/image.png',
          rating: 4.5,
          reviews: 100,
          availableQuantities: 50,
          seller: 'Test Seller',
        );

        expect(model1, equals(tProductModel));
      });

      test('two ProductModels with different data should not be equal', () {
        final model2 = tProductModel.copyWith(id: '999');

        expect(model2, isNot(equals(tProductModel)));
      });
    });
  });
}
