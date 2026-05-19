import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/validators/validated_file_result.dart';

void main() {
  group('ValidatedFileResult', () {
    group('Constructor', () {
      test('should create instance with valid files and no error', () {
        final file = File('document.pdf');
        final result = ValidatedFileResult(validFiles: [file]);

        expect(result.validFiles, equals([file]));
        expect(result.error, isNull);
      });

      test('should create instance with valid files and an error message', () {
        final file = File('document.pdf');
        final result = ValidatedFileResult(
          validFiles: [file],
          error: 'File size exceeds limit',
        );

        expect(result.validFiles, equals([file]));
        expect(result.error, equals('File size exceeds limit'));
      });

      test('should create instance with empty file list', () {
        const result = ValidatedFileResult(validFiles: []);

        expect(result.validFiles, isEmpty);
        expect(result.error, isNull);
      });

      test('should create instance with multiple files', () {
        final files = [File('a.pdf'), File('b.doc'), File('c.txt')];
        final result = ValidatedFileResult(validFiles: files);

        expect(result.validFiles, hasLength(3));
        expect(result.validFiles, equals(files));
      });
    });

    group('hasError', () {
      test('should return false when error is null', () {
        const result = ValidatedFileResult(validFiles: []);

        expect(result.hasError, isFalse);
      });

      test('should return true when error is a non-empty string', () {
        const result = ValidatedFileResult(
          validFiles: [],
          error: 'Invalid file type',
        );

        expect(result.hasError, isTrue);
      });

      test('should return true when error is an empty string', () {
        const result = ValidatedFileResult(validFiles: [], error: '');

        expect(result.hasError, isTrue);
      });
    });

    group('Immutability', () {
      test('should keep error accessible after construction', () {
        const errorMessage = 'File too large';
        const result = ValidatedFileResult(validFiles: [], error: errorMessage);

        expect(result.error, equals(errorMessage));
      });

      test('should keep validFiles list accessible after construction', () {
        final files = [File('test.pdf')];
        final result = ValidatedFileResult(validFiles: files);

        expect(result.validFiles, equals(files));
      });
    });
  });
}
