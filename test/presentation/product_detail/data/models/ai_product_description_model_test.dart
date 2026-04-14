import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/product_detail/data/models/ai_product_description_model.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/utils/typedef.dart';

void main() {
  final tGeneratedAt = DateTime(2024, 1, 15, 10, 30);

  final tModel = AIProductDescriptionModel(
    productId: 'prod-1',
    generatedDescription: 'A wonderful product description',
    generatedAt: tGeneratedAt,
    isPersonalized: true,
  );

  final DataMap tMap = {
    'productId': 'prod-1',
    'generatedDescription': 'A wonderful product description',
    'generatedAt': tGeneratedAt.toIso8601String(),
    'isPersonalized': true,
  };

  group('AIProductDescriptionModel', () {
    test('should be a subclass of AIProductDescription entity', () {
      expect(tModel, isA<AIProductDescription>());
    });

    group('fromMap', () {
      test('should return a valid model from a map', () {
        final result = AIProductDescriptionModel.fromMap(tMap);

        expect(result.productId, equals('prod-1'));
        expect(
          result.generatedDescription,
          equals('A wonderful product description'),
        );
        expect(result.generatedAt, equals(tGeneratedAt));
        expect(result.isPersonalized, isTrue);
      });

      test('should default isPersonalized to false when not in map', () {
        final mapWithoutPersonalized = Map<String, dynamic>.from(tMap)
          ..remove('isPersonalized');

        final result = AIProductDescriptionModel.fromMap(
          mapWithoutPersonalized,
        );

        expect(result.isPersonalized, isFalse);
      });
    });

    group('toMap', () {
      test('should return a map containing proper data', () {
        final result = tModel.toMap();

        expect(result['productId'], equals('prod-1'));
        expect(
          result['generatedDescription'],
          equals('A wonderful product description'),
        );
        expect(result['generatedAt'], equals(tGeneratedAt.toIso8601String()));
        expect(result['isPersonalized'], isTrue);
      });
    });

    group('fromEntity', () {
      test('should create a model from an entity', () {
        final entity = AIProductDescription(
          productId: 'prod-2',
          generatedDescription: 'Entity description',
          generatedAt: tGeneratedAt,
        );

        final result = AIProductDescriptionModel.fromEntity(entity);

        expect(result.productId, equals('prod-2'));
        expect(result.generatedDescription, equals('Entity description'));
        expect(result.generatedAt, equals(tGeneratedAt));
        expect(result.isPersonalized, isFalse);
      });
    });

    group('toEntity', () {
      test('should return an AIProductDescription entity', () {
        final result = tModel.toEntity();

        expect(result, isA<AIProductDescription>());
        expect(result.productId, equals(tModel.productId));
        expect(
          result.generatedDescription,
          equals(tModel.generatedDescription),
        );
        expect(result.generatedAt, equals(tModel.generatedAt));
        expect(result.isPersonalized, equals(tModel.isPersonalized));
      });
    });

    group('fromGeneratedText', () {
      test('should create a model from generated text', () {
        final result = AIProductDescriptionModel.fromGeneratedText(
          productId: 'prod-3',
          generatedText: 'Generated description text',
          isPersonalized: true,
        );

        expect(result.productId, equals('prod-3'));
        expect(
          result.generatedDescription,
          equals('Generated description text'),
        );
        expect(result.isPersonalized, isTrue);
        expect(result.generatedAt, isA<DateTime>());
      });

      test('should default isPersonalized to false', () {
        final result = AIProductDescriptionModel.fromGeneratedText(
          productId: 'prod-4',
          generatedText: 'Some text',
        );

        expect(result.isPersonalized, isFalse);
      });
    });

    group('roundtrip', () {
      test('toMap then fromMap should produce equivalent model', () {
        final map = tModel.toMap();
        final result = AIProductDescriptionModel.fromMap(map);

        expect(result.productId, equals(tModel.productId));
        expect(
          result.generatedDescription,
          equals(tModel.generatedDescription),
        );
        expect(result.generatedAt, equals(tModel.generatedAt));
        expect(result.isPersonalized, equals(tModel.isPersonalized));
      });
    });
  });
}
