import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:skelter/presentation/feedback/data/models/feedback_model.dart';
import 'package:skelter/presentation/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:skelter/presentation/feedback/enum/feedback_category.dart';

class MockFeedbackRemoteDatasource extends Mock
    implements FeedbackRemoteDatasource {}

void main() {
  late FeedbackRepositoryImpl repository;
  late MockFeedbackRemoteDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(
      FeedbackModel(
        id: '',
        userId: 'user-1',
        name: 'Test',
        email: 'test@test.com',
        phoneNumber: '+1234567890',
        rating: 4.0,
        category: FeedbackCategory.suggestion,
        message: 'Test message',
        createdAt: DateTime(2024, 1, 15),
      ),
    );
  });

  setUp(() {
    mockDatasource = MockFeedbackRemoteDatasource();
    repository = FeedbackRepositoryImpl(mockDatasource);
  });

  group('submitFeedback', () {
    test('should return Right(null) when datasource succeeds', () async {
      when(
        () => mockDatasource.submitFeedback(any()),
      ).thenAnswer((_) async => Future.value());

      final result = await repository.submitFeedback(
        userId: 'user-1',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1234567890',
        rating: 4.5,
        category: FeedbackCategory.suggestion,
        message: 'Great app!',
      );

      expect(result, const Right(null));
      verify(() => mockDatasource.submitFeedback(any())).called(1);
    });

    test(
      'should return APIFailure when datasource throws APIException',
      () async {
        const tException = APIException(
          message: 'Submit failed',
          statusCode: 500,
        );
        when(() => mockDatasource.submitFeedback(any())).thenThrow(tException);

        final result = await repository.submitFeedback(
          userId: 'user-1',
          name: 'John Doe',
          email: 'john@example.com',
          phoneNumber: '+1234567890',
          rating: 4.5,
          category: FeedbackCategory.suggestion,
          message: 'Great app!',
        );

        expect(
          result,
          Left(
            APIFailure(
              message: tException.message,
              statusCode: tException.statusCode,
            ),
          ),
        );
      },
    );

    test(
      'should return APIFailure when datasource throws generic exception',
      () async {
        when(
          () => mockDatasource.submitFeedback(any()),
        ).thenThrow(Exception('Unknown error'));

        final result = await repository.submitFeedback(
          userId: 'user-1',
          name: 'John Doe',
          email: 'john@example.com',
          phoneNumber: '+1234567890',
          rating: 4.5,
          category: FeedbackCategory.suggestion,
          message: 'Great app!',
        );

        result.fold((failure) {
          expect(failure, isA<APIFailure>());
          expect(failure.statusCode, equals(500));
        }, (_) => fail('Should return failure'));
      },
    );
  });
}
