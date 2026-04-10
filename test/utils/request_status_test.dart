import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/request_status.dart';

void main() {
  group('RequestStatus', () {
    test('should have 4 values', () {
      expect(RequestStatus.values.length, equals(4));
    });

    test('should contain all expected statuses', () {
      expect(RequestStatus.values, contains(RequestStatus.initial));
      expect(RequestStatus.values, contains(RequestStatus.loading));
      expect(RequestStatus.values, contains(RequestStatus.success));
      expect(RequestStatus.values, contains(RequestStatus.failure));
    });

    test('initial should have index 0', () {
      expect(RequestStatus.initial.index, equals(0));
    });

    test('loading should have index 1', () {
      expect(RequestStatus.loading.index, equals(1));
    });

    test('success should have index 2', () {
      expect(RequestStatus.success.index, equals(2));
    });

    test('failure should have index 3', () {
      expect(RequestStatus.failure.index, equals(3));
    });
  });
}
