import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';

void main() {
  group('APIFailure', () {
    test('should create with message and statusCode', () {
      const failure = APIFailure(message: 'Not Found', statusCode: 404);

      expect(failure.message, equals('Not Found'));
      expect(failure.statusCode, equals(404));
    });

    test('errorMessage should return formatted string', () {
      const failure = APIFailure(message: 'Server Error', statusCode: 500);

      expect(failure.errorMessage, equals('500 Error: Server Error'));
    });

    test('fromException should create failure from APIException', () {
      const exception = APIException(message: 'Unauthorized', statusCode: 401);

      final failure = APIFailure.fromException(exception);

      expect(failure.message, equals('Unauthorized'));
      expect(failure.statusCode, equals(401));
    });

    test('should support Equatable comparison', () {
      const failure1 = APIFailure(message: 'Error', statusCode: 500);
      const failure2 = APIFailure(message: 'Error', statusCode: 500);

      expect(failure1, equals(failure2));
    });

    test('failures with different data should not be equal', () {
      const failure1 = APIFailure(message: 'Error', statusCode: 500);
      const failure2 = APIFailure(message: 'Different', statusCode: 404);

      expect(failure1, isNot(equals(failure2)));
    });

    test('props should contain message and statusCode', () {
      const failure = APIFailure(message: 'Test', statusCode: 200);

      expect(failure.props, equals(['Test', 200]));
    });
  });

  group('APIException', () {
    test('should create with message and statusCode', () {
      const exception = APIException(message: 'Bad Request', statusCode: 400);

      expect(exception.message, equals('Bad Request'));
      expect(exception.statusCode, equals(400));
    });

    test('should support Equatable comparison', () {
      const exception1 = APIException(message: 'Error', statusCode: 500);
      const exception2 = APIException(message: 'Error', statusCode: 500);

      expect(exception1, equals(exception2));
    });

    test('should implement Exception', () {
      const exception = APIException(message: 'Test', statusCode: 500);

      expect(exception, isA<Exception>());
    });
  });
}
