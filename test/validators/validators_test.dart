import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/validators/validators.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations mockLocalizations;

  const MockLocalizationsDelegate(this.mockLocalizations);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => mockLocalizations;

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

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
    testWidgets('should return null for valid email', (tester) async {
      final mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = isEmailValid('user@example.com', context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('should return error message for empty email', (tester) async {
      final mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = isEmailValid('', context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, equals("Email can't be empty"));
    });

    testWidgets('should return error message for email without @ symbol', (
      tester,
    ) async {
      final mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = isEmailValid('invalidemail.com', context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, equals('Invalid email'));
    });

    testWidgets('should return error message for email without domain', (
      tester,
    ) async {
      final mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = isEmailValid('user@', context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, equals('Invalid email'));
    });

    testWidgets(
      'should return error message for email with single-character TLD',
      (tester) async {
        final mockL10n = MockAppLocalizations();
        when(
          () => mockL10n.email_cant_be_empty,
        ).thenReturn("Email can't be empty");
        when(() => mockL10n.invalid_email).thenReturn('Invalid email');

        String? result;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    result = isEmailValid('user@example.c', context);
                  },
                  child: const Text('Validate'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Validate'));
        await tester.pump();
        expect(result, equals('Invalid email'));
      },
    );

    testWidgets('should return null for email with subdomain', (tester) async {
      final mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = isEmailValid('user@mail.example.com', context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('should return null for email with plus sign', (tester) async {
      final mockL10n = MockAppLocalizations();
      when(
        () => mockL10n.email_cant_be_empty,
      ).thenReturn("Email can't be empty");
      when(() => mockL10n.invalid_email).thenReturn('Invalid email');

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = isEmailValid('user+tag@example.com', context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
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
    testWidgets('should return null when value is within limit', (
      tester,
    ) async {
      final mockL10n = MockAppLocalizations();
      when(() => mockL10n.messageTooLong(any())).thenAnswer(
        (i) => 'Message too long (max ${i.positionalArguments.first} chars)',
      );

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = maxLengthValidator('Hello', 10, context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('should return null when value length equals the limit', (
      tester,
    ) async {
      final mockL10n = MockAppLocalizations();
      when(() => mockL10n.messageTooLong(any())).thenAnswer(
        (i) => 'Message too long (max ${i.positionalArguments.first} chars)',
      );

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = maxLengthValidator('Hello', 5, context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('should return error message when value exceeds the limit', (
      tester,
    ) async {
      final mockL10n = MockAppLocalizations();
      when(() => mockL10n.messageTooLong(any())).thenAnswer(
        (i) => 'Message too long (max ${i.positionalArguments.first} chars)',
      );

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = maxLengthValidator('Hello World', 5, context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, equals('Message too long (max 5 chars)'));
    });

    testWidgets('should return null for null value', (tester) async {
      final mockL10n = MockAppLocalizations();
      when(() => mockL10n.messageTooLong(any())).thenAnswer(
        (i) => 'Message too long (max ${i.positionalArguments.first} chars)',
      );

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = maxLengthValidator(null, 10, context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('should return null for empty string', (tester) async {
      final mockL10n = MockAppLocalizations();
      when(() => mockL10n.messageTooLong(any())).thenAnswer(
        (i) => 'Message too long (max ${i.positionalArguments.first} chars)',
      );

      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [MockLocalizationsDelegate(mockL10n)],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = maxLengthValidator('', 5, context);
                },
                child: const Text('Validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(result, isNull);
    });
  });
}
