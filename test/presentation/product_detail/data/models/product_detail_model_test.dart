import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/product_detail/data/models/product_detail_model.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/utils/typedef.dart';

void main() {
  const tProductDetailModel = ProductDetailModel(
    id: '1',
    title: 'Test Product',
    price: 49.99,
    description: 'Detailed product description',
    category: 'Electronics',
    image: 'https://example.com/image.png',
    rating: 4.7,
    productImages: ['img1.png', 'img2.png', 'img3.png'],
  );

  final DataMap tMap = {
    'id': '1',
    'title': 'Test Product',
    'price': 49.99,
    'description': 'Detailed product description',
    'category': 'Electronics',
    'image': 'https://example.com/image.png',
    'rating': 4.7,
    'productImages': ['img1.png', 'img2.png', 'img3.png'],
  };

  group('ProductDetailModel', () {
    test('should be a subclass of ProductDetail entity', () {
      expect(tProductDetailModel, isA<ProductDetail>());
    });

    group('fromMap', () {
      test('should return a valid model from a map', () {
        final result = ProductDetailModel.fromMap(tMap);

        expect(result.id, equals('1'));
        expect(result.title, equals('Test Product'));
        expect(result.price, equals(49.99));
        expect(result.description, equals('Detailed product description'));
        expect(result.category, equals('Electronics'));
        expect(result.rating, equals(4.7));
        expect(
          result.productImages,
          equals(['img1.png', 'img2.png', 'img3.png']),
        );
      });

      test('should handle price as int', () {
        final mapWithIntPrice = Map<String, dynamic>.from(tMap)..['price'] = 50;

        final result = ProductDetailModel.fromMap(mapWithIntPrice);

        expect(result.price, equals(50.0));
        expect(result.price, isA<double>());
      });

      test('should handle rating as int', () {
        final mapWithIntRating = Map<String, dynamic>.from(tMap)
          ..['rating'] = 5;

        final result = ProductDetailModel.fromMap(mapWithIntRating);

        expect(result.rating, equals(5.0));
        expect(result.rating, isA<double>());
      });

      test('should handle empty productImages list', () {
        final mapWithEmptyImages = Map<String, dynamic>.from(tMap)
          ..['productImages'] = [];

        final result = ProductDetailModel.fromMap(mapWithEmptyImages);

        expect(result.productImages, isEmpty);
      });
    });

    group('fromJson', () {
      test('should return a valid model from a JSON string', () {
        final jsonString = jsonEncode(tMap);

        final result = ProductDetailModel.fromJson(jsonString);

        expect(result.id, equals('1'));
        expect(result.title, equals('Test Product'));
        expect(result.productImages.length, equals(3));
      });
    });

    group('toMap', () {
      test('should return a map containing all the proper data', () {
        final result = tProductDetailModel.toMap();

        expect(result, equals(tMap));
      });
    });

    group('toJson', () {
      test('should return a JSON string with proper data', () {
        final result = tProductDetailModel.toJson();
        final decoded = jsonDecode(result) as DataMap;

        expect(decoded['id'], equals('1'));
        expect(decoded['productImages'], isList);
        expect((decoded['productImages'] as List).length, equals(3));
      });
    });

    group('copyWith', () {
      test('should return a new model with updated title', () {
        final result = tProductDetailModel.copyWith(title: 'New Title');

        expect(result.title, equals('New Title'));
        expect(result.id, equals(tProductDetailModel.id));
      });

      test('should return a new model with updated productImages', () {
        final result = tProductDetailModel.copyWith(productImages: ['new.png']);

        expect(result.productImages, equals(['new.png']));
        expect(result.title, equals(tProductDetailModel.title));
      });

      test('should return identical model when no params are passed', () {
        final result = tProductDetailModel.copyWith();

        expect(result.id, equals(tProductDetailModel.id));
        expect(result.title, equals(tProductDetailModel.title));
        expect(result.price, equals(tProductDetailModel.price));
        expect(result.productImages, equals(tProductDetailModel.productImages));
      });
    });

    group('Equatable', () {
      test('two models with same data should be equal', () {
        const model2 = ProductDetailModel(
          id: '1',
          title: 'Test Product',
          price: 49.99,
          description: 'Detailed product description',
          category: 'Electronics',
          image: 'https://example.com/image.png',
          rating: 4.7,
          productImages: ['img1.png', 'img2.png', 'img3.png'],
        );

        expect(model2, equals(tProductDetailModel));
      });
    });
  });
}
