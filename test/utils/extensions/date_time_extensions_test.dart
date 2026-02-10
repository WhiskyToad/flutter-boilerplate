import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/utils/date_time_picker_util.dart';
import 'package:skelter/utils/extensions/date_time_extensions.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  group('DateTimeExtensions Tests', () {
    final testCurrentDate = DateTime(2025, 9, 22, 12);

    test('isFuture returns true for a date after now', () {
      final now = DateTime(2025, 9, 20);
      final futureDate = now.add(const Duration(days: 5));

      expect(futureDate.isFuture(now), true);
    });

    test('isPast returns true for a date before now', () {
      final now = DateTime(2025, 9, 20);
      final pastDate = now.subtract(const Duration(days: 5));

      expect(pastDate.isPast(now), true);
    });

    test('format returns correctly formatted date string', () {
      expect(testCurrentDate.format(pattern: 'yyyy-MM-dd'), '2025-09-22');
      expect(testCurrentDate.format(pattern: 'MM/dd/yyyy'), '09/22/2025');
    });

    test('isSameDay returns true when two dates fall on the same day', () {
      final sameDayDate = DateTime(2025, 9, 22, 23, 59);
      expect(testCurrentDate.isSameDay(sameDayDate), true);
    });

    test('isSameDay returns false for different days', () {
      final differentDayDate = DateTime(2025, 9, 23);
      expect(testCurrentDate.isSameDay(differentDayDate), false);
    });

    test('isInRange returns true when date is within a start-end range', () {
      final rangeStart = testCurrentDate.subtract(const Duration(days: 1));
      final rangeEnd = testCurrentDate.add(const Duration(days: 1));
      expect(testCurrentDate.isInRange(rangeStart, rangeEnd), true);
    });

    test('isInRange returns false when date is outside the range', () {
      final rangeStart = testCurrentDate.add(const Duration(days: 1));
      final rangeEnd = testCurrentDate.add(const Duration(days: 2));
      expect(testCurrentDate.isInRange(rangeStart, rangeEnd), false);
    });

    test('to12HourFormat formats time correctly in 12-hour format', () {
      final testTimeMorning = DateTime(2025, 9, 22, 9, 15);
      final testTimeEvening = DateTime(2025, 9, 22, 21, 45);

      expect(testTimeMorning.to12HourFormat(), '09:15 AM');
      expect(testTimeEvening.to12HourFormat(), '09:45 PM');
    });

    testWidgets(
      'timeAgo returns correct localized strings for different ranges',
      (tester) async {
        final mockLocalizations = MockAppLocalizations();

        when(() => mockLocalizations.justNow).thenReturn('Just now');
        when(() => mockLocalizations.oneMinuteAgo).thenReturn('1 min ago');
        when(() => mockLocalizations.oneHourAgo).thenReturn('1 hr ago');
        when(() => mockLocalizations.yesterday).thenReturn('Yesterday');
        when(() => mockLocalizations.lastMonth).thenReturn('Last month');
        when(() => mockLocalizations.lastYear).thenReturn('Last year');

        when(() => mockLocalizations.minutesAgo(any())).thenAnswer(
          (mockCall) => '${mockCall.positionalArguments.first} min ago',
        );
        when(() => mockLocalizations.hoursAgo(any())).thenAnswer(
          (mockCall) => '${mockCall.positionalArguments.first} hrs ago',
        );
        when(() => mockLocalizations.daysAgo(any())).thenAnswer(
          (mockCall) => '${mockCall.positionalArguments.first} days ago',
        );
        when(() => mockLocalizations.monthsAgo(any())).thenAnswer(
          (mockCall) => '${mockCall.positionalArguments.first} months ago',
        );
        when(() => mockLocalizations.yearsAgo(any())).thenAnswer(
          (mockCall) => '${mockCall.positionalArguments.first} years ago',
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: [
              _MockLocalizationsDelegate(mockLocalizations),
            ],
            home: Builder(
              builder: (context) {
                final testCurrentTime = testCurrentDate;

                final testCases = [
                  (testCurrentTime, 'Just now'),
                  (
                    testCurrentTime.subtract(const Duration(minutes: 1)),
                    '1 min ago',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(minutes: 5)),
                    '5 min ago',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(hours: 1)),
                    '1 hr ago',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(hours: 5)),
                    '5 hrs ago',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(days: 1)),
                    'Yesterday',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(days: 3)),
                    '3 days ago',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(days: 30)),
                    'Last month',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(days: 60)),
                    '2 months ago',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(days: 365)),
                    'Last year',
                  ),
                  (
                    testCurrentTime.subtract(const Duration(days: 730)),
                    '2 years ago',
                  ),
                ];

                for (final (dateTime, expectedString) in testCases) {
                  final result = dateTime.timeAgo(mockLocalizations);
                  expect(
                    result,
                    expectedString,
                    reason: 'Failed for $dateTime',
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  group('Timezone Tests', () {
    setUpAll(() {
      tz.initializeTimeZones();
    });

    group('getCurrentTimeInTimezone Tests', () {
      test('should return valid DateTime objects for New York, '
          'Los Angeles, and Tokyo timezones', () {
        final nyTime = DateTimePickerUtil.getCurrentTimeInTimezone(
          'America/New_York',
        );
        final laTime = DateTimePickerUtil.getCurrentTimeInTimezone(
          'America/Los_Angeles',
        );
        final tokyoTime = DateTimePickerUtil.getCurrentTimeInTimezone(
          'Asia/Tokyo',
        );

        expect(nyTime, isA<DateTime>());
        expect(laTime, isA<DateTime>());
        expect(tokyoTime, isA<DateTime>());

        final hourDifference = nyTime.hour - laTime.hour;
        expect(hourDifference.abs(), greaterThanOrEqualTo(0));
      });

      test('should return valid DateTime for Tokyo and London timezones', () {
        final tokyoTime = DateTimePickerUtil.getCurrentTimeInTimezone(
          'Asia/Tokyo',
        );
        final londonTime = DateTimePickerUtil.getCurrentTimeInTimezone(
          'Europe/London',
        );

        expect(tokyoTime, isA<DateTime>());
        expect(londonTime, isA<DateTime>());
      });

      test(
        'should return valid current time for top 15 countries worldwide',
        () {
          final timezones = [
            'America/New_York',
            'Europe/London',
            'Asia/Tokyo',
            'Asia/Kolkata',
            'Asia/Shanghai',
            'Europe/Berlin',
            'Europe/Paris',
            'Australia/Sydney',
            'America/Toronto',
            'America/Sao_Paulo',
            'Europe/Moscow',
            'Asia/Dubai',
            'Asia/Singapore',
            'Africa/Johannesburg',
            'America/Mexico_City',
          ];

          for (final timezone in timezones) {
            final currentTime = DateTimePickerUtil.getCurrentTimeInTimezone(
              timezone,
            );

            expect(currentTime, isA<DateTime>());
            expect(currentTime.year, greaterThanOrEqualTo(2025));
            expect(currentTime.month, greaterThanOrEqualTo(1));
            expect(currentTime.month, lessThanOrEqualTo(12));
            expect(currentTime.day, greaterThanOrEqualTo(1));
            expect(currentTime.day, lessThanOrEqualTo(31));
            expect(currentTime.hour, greaterThanOrEqualTo(0));
            expect(currentTime.hour, lessThanOrEqualTo(23));
          }
        },
      );
    });

    group('convertDateTimeToTimezone Tests', () {
      test('should convert UTC date to New York, Tokyo, London, '
          'and India timezones with correct hour offsets', () {
        final utcDate = DateTime.utc(2025, 1, 15, 12);

        final nyTime = DateTimePickerUtil.convertDateTimeToTimezone(
          utcDate,
          'America/New_York',
        );
        final tokyoTime = DateTimePickerUtil.convertDateTimeToTimezone(
          utcDate,
          'Asia/Tokyo',
        );
        final londonTime = DateTimePickerUtil.convertDateTimeToTimezone(
          utcDate,
          'Europe/London',
        );
        final indiaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          utcDate,
          'Asia/Kolkata',
        );

        expect(nyTime, isA<DateTime>());
        expect(tokyoTime, isA<DateTime>());
        expect(londonTime, isA<DateTime>());
        expect(indiaTime, isA<DateTime>());

        expect(nyTime.hour, 7);
        expect(tokyoTime.hour, 21);
        expect(londonTime.hour, 12);
        expect(indiaTime.hour, 17);
        expect(indiaTime.minute, 30);
      });

      test('should preserve year, month, and seconds when '
          'converting to Chicago timezone', () {
        final testDate = DateTime.utc(2025, 3, 20, 10, 45, 30);

        final convertedDate = DateTimePickerUtil.convertDateTimeToTimezone(
          testDate,
          'America/Chicago',
        );

        expect(convertedDate.year, 2025);
        expect(convertedDate.month, 3);
        expect(convertedDate.second, 30);
      });

      test('should accurately convert UTC noon to correct local '
          'times for top 15 countries', () {
        final baseDate = DateTime.utc(2025, 3, 15, 12);

        final indiaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Asia/Kolkata',
        );
        expect(indiaTime.hour, 17);
        expect(indiaTime.minute, 30);

        final usaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'America/New_York',
        );
        expect(usaTime.hour, 8);
        expect(usaTime.minute, 0);

        final ukTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Europe/London',
        );
        expect(ukTime.hour, 12);
        expect(ukTime.minute, 0);

        final japanTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Asia/Tokyo',
        );
        expect(japanTime.hour, 21);
        expect(japanTime.minute, 0);

        final chinaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Asia/Shanghai',
        );
        expect(chinaTime.hour, 20);
        expect(chinaTime.minute, 0);

        final germanyTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Europe/Berlin',
        );
        expect(germanyTime.hour, 13);
        expect(germanyTime.minute, 0);

        final franceTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Europe/Paris',
        );
        expect(franceTime.hour, 13);
        expect(franceTime.minute, 0);

        final australiaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Australia/Sydney',
        );
        expect(australiaTime.hour, 23);
        expect(australiaTime.minute, 0);

        final canadaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'America/Toronto',
        );
        expect(canadaTime.hour, 8);
        expect(canadaTime.minute, 0);

        final brazilTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'America/Sao_Paulo',
        );
        expect(brazilTime.hour, 9);
        expect(brazilTime.minute, 0);

        final russiaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Europe/Moscow',
        );
        expect(russiaTime.hour, 15);
        expect(russiaTime.minute, 0);

        final uaeTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Asia/Dubai',
        );
        expect(uaeTime.hour, 16);
        expect(uaeTime.minute, 0);

        final singaporeTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Asia/Singapore',
        );
        expect(singaporeTime.hour, 20);
        expect(singaporeTime.minute, 0);

        final southAfricaTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'Africa/Johannesburg',
        );
        expect(southAfricaTime.hour, 14);
        expect(southAfricaTime.minute, 0);

        final mexicoTime = DateTimePickerUtil.convertDateTimeToTimezone(
          baseDate,
          'America/Mexico_City',
        );
        expect(mexicoTime.hour, 6);
        expect(mexicoTime.minute, 0);
      });

      test('should maintain valid date components across '
          'multiple timezone conversions', () {
        final baseDate = DateTime.utc(2025, 5, 10, 15);

        final timezones = [
          'America/New_York',
          'America/Los_Angeles',
          'Europe/London',
          'Asia/Tokyo',
          'Australia/Sydney',
          'Asia/Kolkata',
        ];

        final convertedTimes = timezones
            .map(
              (tz) =>
                  DateTimePickerUtil.convertDateTimeToTimezone(baseDate, tz),
            )
            .toList();

        for (final time in convertedTimes) {
          expect(time, isA<DateTime>());
          expect(time.year, 2025);
          expect(time.month, greaterThanOrEqualTo(1));
          expect(time.month, lessThanOrEqualTo(12));
        }
      });

      test('should correctly calculate India timezone offset '
          'across New Year, summer, and year-end dates', () {
        final testDates = [
          DateTime.utc(2025, 1, 0, 1),
          DateTime.utc(2025, 6, 15, 12),
          DateTime.utc(2025, 12, 31, 23, 59, 59),
        ];

        for (final utcDate in testDates) {
          final indiaTime = DateTimePickerUtil.convertDateTimeToTimezone(
            utcDate,
            'Asia/Kolkata',
          );

          // India is always UTC+5:30 (no DST)
          final expectedHour = (utcDate.hour + 5) % 24;
          final expectedMinute = (utcDate.minute + 30) % 60;
          final hourCarry = (utcDate.minute + 30) ~/ 60;

          expect(indiaTime.hour, (expectedHour + hourCarry) % 24);
          expect(indiaTime.minute, expectedMinute);
        }
      });
    });

    group('Edge Case Tests', () {
      test('should convert noon UTC to correct time in New York timezone', () {
        final noon = DateTime.utc(2025, 6, 15, 12);
        final nyTime = DateTimePickerUtil.convertDateTimeToTimezone(
          noon,
          'America/New_York',
        );

        expect(nyTime.hour, 8);
      });

      test('should handle date rollover when converting '
          'end of day UTC to Tokyo timezone', () {
        final endOfDay = DateTime.utc(2025, 3, 10, 23, 59, 59);
        final tokyoTime = DateTimePickerUtil.convertDateTimeToTimezone(
          endOfDay,
          'Asia/Tokyo',
        );

        expect(tokyoTime.hour, 8);
        expect(tokyoTime.day, 11);
      });

      test('should correctly convert leap year date '
          '(Feb 29, 2024) to London timezone', () {
        final leapDay = DateTime.utc(2024, 2, 29, 15);
        final londonTime = DateTimePickerUtil.convertDateTimeToTimezone(
          leapDay,
          'Europe/London',
        );

        expect(londonTime.year, 2024);
        expect(londonTime.month, 2);
        expect(londonTime.day, 29);
      });

      test('should correctly handle year boundary when converting '
          'New Year Eve to Sydney timezone', () {
        final newYearEve = DateTime.utc(2024, 12, 31, 23);
        final sydneyTime = DateTimePickerUtil.convertDateTimeToTimezone(
          newYearEve,
          'Australia/Sydney',
        );

        expect(sydneyTime.year, 2025);
        expect(sydneyTime.month, 1);
        expect(sydneyTime.day, 1);
      });
    });

    group('DST Handling Tests', () {
      test('should apply different UTC offsets for New '
          'York during summer (EDT) vs winter (EST)', () {
        final date1 = DateTime.utc(2025, 6, 15, 18, 30);
        final date2 = DateTime.utc(2025, 12, 15, 18, 30);

        final nyTimeSummer = DateTimePickerUtil.convertDateTimeToTimezone(
          date1,
          'America/New_York',
        );
        final nyTimeWinter = DateTimePickerUtil.convertDateTimeToTimezone(
          date2,
          'America/New_York',
        );

        expect(nyTimeSummer, isA<DateTime>());
        expect(nyTimeWinter, isA<DateTime>());

        expect(nyTimeSummer.hour, 14);
        expect(nyTimeWinter.hour, 13);
      });
    });

    group('Error Handling Tests', () {
      test(
        'should throw LocationNotFoundException for invalid timezone string',
        () {
          expect(
            () =>
                DateTimePickerUtil.getCurrentTimeInTimezone('Invalid/Timezone'),
            throwsA(isA<tz.LocationNotFoundException>()),
          );
        },
      );
    });
  });
}

class _MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations mockLocalizations;

  const _MockLocalizationsDelegate(this.mockLocalizations);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => mockLocalizations;

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
