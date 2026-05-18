import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/validators/file_validator.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('file_validator_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File createFile(String name, List<int> bytes) {
    final file = File('${tempDir.path}/$name');
    file.writeAsBytesSync(Uint8List.fromList(bytes));
    return file;
  }

  group('FileValidator.isValidByMimeAndExtension', () {
    group('PDF files', () {
      test('should return true for valid PDF with correct signature', () async {
        // PDF signature: %PDF- = 0x25 0x50 0x44 0x46 0x2D
        final file = createFile('document.pdf', [
          0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
          0x31, 0x2E, 0x34, 0x0A, 0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A, 0x0A,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isTrue);
      });

      test('should return false for .pdf file with wrong signature', () async {
        final file = createFile('fake.pdf', [
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
          0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });

      test(
        'should return false for PDF file with insufficient header bytes',
        () async {
          final file = createFile('short.pdf', [0x25, 0x50]); // Only 2 bytes

          final result = await FileValidator.isValidByMimeAndExtension(file);

          expect(result, isFalse);
        },
      );
    });

    group('DOC files', () {
      test('should return true for valid DOC with OLE signature', () async {
        // OLE compound document signature
        final file = createFile('document.doc', [
          0xD0,
          0xCF,
          0x11,
          0xE0,
          0xA1,
          0xB1,
          0x1A,
          0xE1,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isTrue);
      });

      test('should return false for .doc file with wrong signature', () async {
        final file = createFile('fake.doc', [
          0x25, 0x50, 0x44, 0x46, 0x2D, // PDF signature in a .doc file
          0x31, 0x2E, 0x34, 0x0A, 0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A, 0x0A,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });
    });

    group('TXT files', () {
      test('should return true for valid plain text file', () async {
        final file = createFile(
          'notes.txt',
          'Hello, this is a plain text file.'.codeUnits,
        );

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isTrue);
      });

      test(
        'should return true for empty txt file (null MIME treated as valid)',
        () async {
          final file = createFile('empty.txt', []);

          final result = await FileValidator.isValidByMimeAndExtension(file);

          expect(result, isTrue);
        },
      );
    });

    group('MP4 files', () {
      test('should return true for valid MP4 with ftyp signature', () async {
        // MP4: bytes 4-7 must be 'ftyp' (0x66 0x74 0x79 0x70)
        final file = createFile('video.mp4', [
          0x00, 0x00, 0x00, 0x18, // box size
          0x66, 0x74, 0x79, 0x70, // 'ftyp'
          0x6D, 0x70, 0x34, 0x32, // 'mp42'
          0x00, 0x00, 0x00, 0x00, // flags
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isTrue);
      });

      test(
        'should return false for .mp4 file without ftyp signature',
        () async {
          final file = createFile('fake.mp4', [
            0x00, 0x00, 0x00, 0x18,
            0x61, 0x62, 0x63, 0x64, // 'abcd' instead of 'ftyp'
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          ]);

          final result = await FileValidator.isValidByMimeAndExtension(file);

          expect(result, isFalse);
        },
      );

      test(
        'should return false for .mp4 file with header shorter than 16 bytes',
        () async {
          final file = createFile('short.mp4', [
            0x00, 0x00, 0x00, 0x18,
            0x66, 0x74, 0x79, 0x70, // only 8 bytes
          ]);

          final result = await FileValidator.isValidByMimeAndExtension(file);

          expect(result, isFalse);
        },
      );
    });

    group('Unsupported extensions', () {
      test('should return false for .png file', () async {
        final file = createFile('image.png', [
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          0x00,
          0x00,
          0x00,
          0x0D,
          0x49,
          0x48,
          0x44,
          0x52,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });

      test('should return false for .jpg file', () async {
        final file = createFile('photo.jpg', [
          0xFF, 0xD8, 0xFF, 0xE0, // JPEG signature
          0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
          0x00, 0x00, 0x00, 0x01,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });

      test('should return false for .exe file', () async {
        final file = createFile('app.exe', [
          0x4D, 0x5A, // MZ header
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });

      test('should return false for file with no extension', () async {
        final file = createFile('noextension', [0x00, 0x01, 0x02]);

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });
    });

    group('Error handling', () {
      test('should return false for non-existent file', () async {
        final file = File('${tempDir.path}/does_not_exist.pdf');

        final result = await FileValidator.isValidByMimeAndExtension(file);

        expect(result, isFalse);
      });
    });
  });
}
