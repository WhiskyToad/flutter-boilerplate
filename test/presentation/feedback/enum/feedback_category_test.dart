import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/feedback/enum/feedback_category.dart';

void main() {
  group('FeedbackCategory', () {
    test('should have 5 values', () {
      expect(FeedbackCategory.values.length, equals(5));
    });

    test('should contain all expected categories', () {
      expect(FeedbackCategory.values, contains(FeedbackCategory.bug));
      expect(FeedbackCategory.values, contains(FeedbackCategory.suggestion));
      expect(FeedbackCategory.values, contains(FeedbackCategory.content));
      expect(FeedbackCategory.values, contains(FeedbackCategory.compliment));
      expect(FeedbackCategory.values, contains(FeedbackCategory.other));
    });

    group('value getter', () {
      test('bug should return "bug"', () {
        expect(FeedbackCategory.bug.value, equals('bug'));
      });

      test('suggestion should return "suggestion"', () {
        expect(FeedbackCategory.suggestion.value, equals('suggestion'));
      });

      test('content should return "content"', () {
        expect(FeedbackCategory.content.value, equals('content'));
      });

      test('compliment should return "compliment"', () {
        expect(FeedbackCategory.compliment.value, equals('compliment'));
      });

      test('other should return "other"', () {
        expect(FeedbackCategory.other.value, equals('other'));
      });
    });

    test('each category value should match its name', () {
      for (final category in FeedbackCategory.values) {
        expect(category.value, equals(category.name));
      }
    });
  });
}
