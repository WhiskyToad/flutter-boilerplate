import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/validators/validators.dart';

import '../test_helpers.dart';

void main() {
  group('isValidUrl', () {
    test('should return true for https URL', () {
      expect(isValidUrl(url: 'https://example.com'), isTrue);
    });

    test('should return true for http URL', () {
      expect(isValidUrl(url: 'http://example.com'), isTrue);
    });

    test('should return true for www URL', () {
      expect(isValidUrl(url: 'www.example.com'), isTrue);
    });

    test('should return true for URL with path', () {
      expect(isValidUrl(url: 'https://example.com/path/to/page'), isTrue);
    });

    test('should return true for URL with subdomain', () {
      expect(isValidUrl(url: 'https://sub.example.com'), isTrue);
    });

    test('should return true for URL with port', () {
      expect(isValidUrl(url: 'https://example.com:8080'), isTrue);
    });

    test('should return true for URL with query params', () {
      expect(isValidUrl(url: 'https://example.com/search?q=flutter'), isTrue);
    });

    test('should be case insensitive', () {
      expect(isValidUrl(url: 'HTTPS://EXAMPLE.COM'), isTrue);
    });

    test('should return false for empty string', () {
      expect(isValidUrl(url: ''), isFalse);
    });

    test('should return false for plain text', () {
      expect(isValidUrl(url: 'just some text'), isFalse);
    });

    test('should return false for URL without protocol or www', () {
      expect(isValidUrl(url: 'example.com'), isFalse);
    });

    test('should return false for ftp URL', () {
      expect(isValidUrl(url: 'ftp://example.com'), isFalse);
    });

    test('should return false for single word', () {
      expect(isValidUrl(url: 'example'), isFalse);
    });
  });

  group('isEmailValid', () {
    late MockAppLocalizations mockL10n;

    setUp(() {
      mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');
    });

    testWidgets('should return null for valid email', (tester) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => isEmailValid('user@example.com', ctx),
      );
      expect(result, isNull);
    });

    testWidgets('should return error message for empty email', (tester) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => isEmailValid('', ctx),
      );
      expect(result, equals("Email can't be empty"));
    });

    testWidgets('should return error message for email without @ symbol', (
      tester,
    ) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => isEmailValid('invalidemail.com', ctx),
      );
      expect(result, equals('Invalid email'));
    });

    testWidgets('should return error message for email without domain', (
      tester,
    ) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => isEmailValid('user@', ctx),
      );
      expect(result, equals('Invalid email'));
    });

    testWidgets(
      'should return error message for email with single-character TLD',
      (tester) async {
        final result = await tester.runValidator(
          mockL10n,
          (ctx) => isEmailValid('user@example.c', ctx),
        );
        expect(result, equals('Invalid email'));
      },
    );

    testWidgets('should return null for email with subdomain', (tester) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => isEmailValid('user@mail.example.com', ctx),
      );
      expect(result, isNull);
    });

    testWidgets('should return null for email with plus sign', (tester) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => isEmailValid('user+tag@example.com', ctx),
      );
      expect(result, isNull);
    });
  });

  group('isPhoneNumberValid', () {
    test('should return true for valid international phone number', () async {
      final result = await isPhoneNumberValid('+919876543210');
      expect(result, isTrue);
    });

    test('should return true for valid US phone number', () async {
      final result = await isPhoneNumberValid('+12025551234');
      expect(result, isTrue);
    });

    test('should return true for valid UK phone number', () async {
      final result = await isPhoneNumberValid('+447911123456');
      expect(result, isTrue);
    });

    test('should return false for number without country code', () async {
      final result = await isPhoneNumberValid('9876543210');
      expect(result, isFalse);
    });

    test('should throw exception for empty string', () async {
      expect(() async => isPhoneNumberValid(''), throwsA(anything));
    });

    test('should return false for number that is too short', () async {
      final result = await isPhoneNumberValid('+911234');
      expect(result, isFalse);
    });
  });

  group('maxLengthValidator', () {
    late MockAppLocalizations mockL10n;

    setUp(() {
      mockL10n = MockAppLocalizations();
      when(() => mockL10n.messageTooLong(any())).thenAnswer(
        (i) => 'Message too long (max ${i.positionalArguments.first} chars)',
      );
    });

    testWidgets('should return null when value is within limit', (
      tester,
    ) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => maxLengthValidator('Hello', 10, ctx),
      );
      expect(result, isNull);
    });

    testWidgets('should return null when value length equals the limit', (
      tester,
    ) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => maxLengthValidator('Hello', 5, ctx),
      );
      expect(result, isNull);
    });

    testWidgets('should return error message when value exceeds the limit', (
      tester,
    ) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => maxLengthValidator('Hello World', 5, ctx),
      );
      expect(result, equals('Message too long (max 5 chars)'));
    });

    testWidgets('should return null for null value', (tester) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => maxLengthValidator(null, 10, ctx),
      );
      expect(result, isNull);
    });

    testWidgets('should return null for empty string', (tester) async {
      final result = await tester.runValidator(
        mockL10n,
        (ctx) => maxLengthValidator('', 5, ctx),
      );
      expect(result, isNull);
    });
  });
}
