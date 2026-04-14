import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/feedback/domain/repositories/feedback_repository.dart';
import 'package:skelter/presentation/feedback/domain/usecases/submit_feedback.dart';
import 'package:skelter/presentation/feedback/enum/feedback_category.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late SubmitFeedback useCase;
  late MockFeedbackRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FeedbackCategory.other);
  });

  setUp(() {
    mockRepository = MockFeedbackRepository();
    useCase = SubmitFeedback(mockRepository);
  });

  const tParams = SubmitFeedbackParams(
    userId: 'user-1',
    name: 'John Doe',
    email: 'john@example.com',
    phoneNumber: '+1234567890',
    rating: 4.5,
    category: FeedbackCategory.suggestion,
    message: 'Great app!',
  );

  group('SubmitFeedback', () {
    test('should submit feedback via the repository', () async {
      when(
        () => mockRepository.submitFeedback(
          userId: any(named: 'userId'),
          name: any(named: 'name'),
          email: any(named: 'email'),
          phoneNumber: any(named: 'phoneNumber'),
          rating: any(named: 'rating'),
          category: any(named: 'category'),
          message: any(named: 'message'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(tParams);

      expect(result, const Right(null));
      verify(
        () => mockRepository.submitFeedback(
          userId: 'user-1',
          name: 'John Doe',
          email: 'john@example.com',
          phoneNumber: '+1234567890',
          rating: 4.5,
          category: FeedbackCategory.suggestion,
          message: 'Great app!',
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      const tFailure = APIFailure(message: 'Submit failed', statusCode: 500);
      when(
        () => mockRepository.submitFeedback(
          userId: any(named: 'userId'),
          name: any(named: 'name'),
          email: any(named: 'email'),
          phoneNumber: any(named: 'phoneNumber'),
          rating: any(named: 'rating'),
          category: any(named: 'category'),
          message: any(named: 'message'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('SubmitFeedbackParams', () {
    test('should support Equatable comparison', () {
      const params2 = SubmitFeedbackParams(
        userId: 'user-1',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1234567890',
        rating: 4.5,
        category: FeedbackCategory.suggestion,
        message: 'Great app!',
      );

      expect(tParams, equals(params2));
    });

    test('params with different data should not be equal', () {
      const differentParams = SubmitFeedbackParams(
        userId: 'user-2',
        name: 'Jane Doe',
        email: 'jane@example.com',
        phoneNumber: '+0987654321',
        rating: 3.0,
        category: FeedbackCategory.bug,
        message: 'Found a bug',
      );

      expect(tParams, isNot(equals(differentParams)));
    });
  });
}
