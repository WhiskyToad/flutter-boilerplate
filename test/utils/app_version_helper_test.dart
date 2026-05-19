import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/app_version_helper.dart';

void main() {
  group('getExtendedVersionNumber', () {
    group('Standard versions', () {
      test('should convert 1.0.0 to 100000', () {
        expect(getExtendedVersionNumber('1.0.0'), equals(100000));
      });

      test('should convert 2.3.4 to 203004', () {
        expect(getExtendedVersionNumber('2.3.4'), equals(203004));
      });

      test('should convert 10.20.30 to 1020030', () {
        expect(getExtendedVersionNumber('10.20.30'), equals(1020030));
      });

      test('should convert 0.0.1 to 1', () {
        expect(getExtendedVersionNumber('0.0.1'), equals(1));
      });

      test('should convert 0.1.0 to 1000', () {
        expect(getExtendedVersionNumber('0.1.0'), equals(1000));
      });

      test('should convert 1.0.1 to 100001', () {
        expect(getExtendedVersionNumber('1.0.1'), equals(100001));
      });
    });

    group('Short versions (auto-padded)', () {
      test('should convert 1.0 (two parts) to 100000', () {
        expect(getExtendedVersionNumber('1.0'), equals(100000));
      });

      test('should convert 2.5 (two parts) to 205000', () {
        expect(getExtendedVersionNumber('2.5'), equals(205000));
      });

      test('should convert 1 (single part) to 100000', () {
        expect(getExtendedVersionNumber('1'), equals(100000));
      });
    });

    group('Versions with pre-release / build metadata', () {
      test('should strip -beta suffix from 1.2.3-beta', () {
        expect(getExtendedVersionNumber('1.2.3-beta'), equals(102003));
      });

      test('should strip +build suffix from 1.2.3+build', () {
        expect(getExtendedVersionNumber('1.2.3+build'), equals(102003));
      });

      test('should strip -rc.1 suffix from 2.0.0-rc.1', () {
        expect(getExtendedVersionNumber('2.0.0-rc.1'), equals(200000));
      });
    });

    group('Version comparison', () {
      test(
        'should produce a higher number for newer version than older version',
        () {
          final older = getExtendedVersionNumber('1.2.3');
          final newer = getExtendedVersionNumber('1.2.4');
          expect(newer, greaterThan(older));
        },
      );

      test('should produce a higher number for minor bump than patch bump', () {
        final patch = getExtendedVersionNumber('1.0.1');
        final minor = getExtendedVersionNumber('1.1.0');
        expect(minor, greaterThan(patch));
      });

      test('should produce the highest number for major bump', () {
        final minor = getExtendedVersionNumber('1.9.9');
        final major = getExtendedVersionNumber('2.0.0');
        expect(major, greaterThan(minor));
      });
    });

    group('Invalid input', () {
      test('should return 0 for empty string', () {
        expect(getExtendedVersionNumber(''), equals(0));
      });

      test('should return 0 for non-numeric string', () {
        expect(getExtendedVersionNumber('invalid'), equals(0));
      });

      test('should return 0 for letters mixed with dots', () {
        expect(getExtendedVersionNumber('a.b.c'), equals(0));
      });
    });
  });
}
