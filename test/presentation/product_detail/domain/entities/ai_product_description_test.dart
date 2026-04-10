import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';

void main() {
  final tGeneratedAt = DateTime(2024, 1, 15, 10, 30);

  final tDescription = AIProductDescription(
    productId: 'prod-1',
    generatedDescription: 'AI generated description',
    generatedAt: tGeneratedAt,
    isPersonalized: true,
  );

  group('AIProductDescription', () {
    test('should create with required fields', () {
      expect(tDescription.productId, equals('prod-1'));
      expect(
        tDescription.generatedDescription,
        equals('AI generated description'),
      );
      expect(tDescription.generatedAt, equals(tGeneratedAt));
      expect(tDescription.isPersonalized, isTrue);
    });

    test('isPersonalized should default to false', () {
      final description = AIProductDescription(
        productId: 'prod-2',
        generatedDescription: 'Test',
        generatedAt: tGeneratedAt,
      );

      expect(description.isPersonalized, isFalse);
    });

    group('copyWith', () {
      test('should return new entity with updated productId', () {
        final result = tDescription.copyWith(productId: 'prod-99');

        expect(result.productId, equals('prod-99'));
        expect(
          result.generatedDescription,
          equals(tDescription.generatedDescription),
        );
      });

      test('should return new entity with updated description', () {
        final result = tDescription.copyWith(
          generatedDescription: 'Updated description',
        );

        expect(result.generatedDescription, equals('Updated description'));
        expect(result.productId, equals(tDescription.productId));
      });

      test('should return new entity with updated isPersonalized', () {
        final result = tDescription.copyWith(isPersonalized: false);

        expect(result.isPersonalized, isFalse);
      });

      test('should return identical entity when no params are passed', () {
        final result = tDescription.copyWith();

        expect(result.productId, equals(tDescription.productId));
        expect(
          result.generatedDescription,
          equals(tDescription.generatedDescription),
        );
        expect(result.generatedAt, equals(tDescription.generatedAt));
        expect(result.isPersonalized, equals(tDescription.isPersonalized));
      });
    });

    group('Equatable', () {
      test('two entities with same data should be equal', () {
        final description2 = AIProductDescription(
          productId: 'prod-1',
          generatedDescription: 'AI generated description',
          generatedAt: tGeneratedAt,
          isPersonalized: true,
        );

        expect(tDescription, equals(description2));
      });

      test('two entities with different data should not be equal', () {
        final description2 = AIProductDescription(
          productId: 'prod-2',
          generatedDescription: 'Different',
          generatedAt: DateTime(2025, 1, 1),
        );

        expect(tDescription, isNot(equals(description2)));
      });
    });
  });
}
