import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/currency_formatter_util.dart';

void main() {
  group('CurrencyFormatter Util Tests', () {
    group('Basic Formatting', () {
      test('should format positive numbers with default setup', () {
        expect(
          CurrencyFormatterUtil.format(1234.56, locale: 'en_US'),
          equals(r'$1,234.56'),
        );
      });

      test('should format zero', () {
        expect(
          CurrencyFormatterUtil.format(0, locale: 'en_US'),
          equals(r'$0.00'),
        );
      });

      test('should format negative numbers', () {
        expect(
          CurrencyFormatterUtil.format(-50.25, locale: 'en_US'),
          equals(r'-$50.25'),
        );
      });

      test('should format large numbers', () {
        expect(
          CurrencyFormatterUtil.format(1000000, locale: 'en_US'),
          equals(r'$1,000,000.00'),
        );
      });
    });

    group('Currency Code Support', () {
      test('should display USD symbol for United States', () {
        expect(
          CurrencyFormatterUtil.format(
            1250.99,
            locale: 'en_US',
            currencyCode: 'USD',
          ),
          contains('\$'),
        );
      });

      test('should display EUR symbol for Euro', () {
        expect(
          CurrencyFormatterUtil.format(
            100.00,
            locale: 'de_DE',
            currencyCode: 'EUR',
          ),
          contains('€'),
        );
      });

      test('should display GBP symbol for British Pound', () {
        expect(
          CurrencyFormatterUtil.format(
            500.50,
            locale: 'en_GB',
            currencyCode: 'GBP',
          ),
          contains('£'),
        );
      });

      test('should display JPY symbol for Japanese Yen', () {
        expect(
          CurrencyFormatterUtil.format(
            100000,
            locale: 'ja_JP',
            currencyCode: 'JPY',
          ),
          contains('¥'),
        );
      });

      test('should display CHF symbol for Swiss Franc', () {
        expect(
          CurrencyFormatterUtil.format(
            250.75,
            locale: 'de_CH',
            currencyCode: 'CHF',
          ),
          contains('CHF'),
        );
      });

      test('should display CAD symbol for Canadian Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            350.25,
            locale: 'en_CA',
            currencyCode: 'CAD',
          ),
          contains('\$'),
        );
      });

      test('should display AUD symbol for Australian Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            450.00,
            locale: 'en_AU',
            currencyCode: 'AUD',
          ),
          contains('\$'),
        );
      });

      test('should display CNY symbol for Chinese Yuan', () {
        expect(
          CurrencyFormatterUtil.format(
            600.50,
            locale: 'zh_CN',
            currencyCode: 'CNY',
          ),
          contains('¥'),
        );
      });

      test('should display INR symbol for Indian Rupee', () {
        expect(
          CurrencyFormatterUtil.format(
            5000.00,
            locale: 'en_IN',
            currencyCode: 'INR',
          ),
          contains('₹'),
        );
      });

      test('should display SGD symbol for Singapore Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            150.75,
            locale: 'en_SG',
            currencyCode: 'SGD',
          ),
          contains('\$'),
        );
      });

      test('should display HKD symbol for Hong Kong Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            800.25,
            locale: 'zh_HK',
            currencyCode: 'HKD',
          ),
          contains('\$'),
        );
      });

      test('should display MXN symbol for Mexican Peso', () {
        expect(
          CurrencyFormatterUtil.format(
            2000.50,
            locale: 'es_MX',
            currencyCode: 'MXN',
          ),
          contains('\$'),
        );
      });

      test('should display BRL symbol for Brazilian Real', () {
        expect(
          CurrencyFormatterUtil.format(
            1500.75,
            locale: 'pt_BR',
            currencyCode: 'BRL',
          ),
          contains('R'),
        );
      });

      test('should display KRW symbol for South Korean Won', () {
        expect(
          CurrencyFormatterUtil.format(
            50000.00,
            locale: 'ko_KR',
            currencyCode: 'KRW',
          ),
          contains('₩'),
        );
      });

      test('should display THB symbol for Thai Baht', () {
        expect(
          CurrencyFormatterUtil.format(
            8000.50,
            locale: 'th_TH',
            currencyCode: 'THB',
          ),
          contains('฿'),
        );
      });
    });

    group('Decimal Digits', () {
      test('should use default 2 decimals', () {
        expect(
          CurrencyFormatterUtil.format(1234.56789, locale: 'en_US'),
          equals(r'$1,234.57'),
        );
      });

      test('should round with 0 decimals', () {
        expect(
          CurrencyFormatterUtil.format(
            1234.56789,
            locale: 'en_US',
            decimalDigits: 0,
          ),
          equals(r'$1,235'),
        );
      });

      test('should format with 3 decimals', () {
        expect(
          CurrencyFormatterUtil.format(
            1234.56789,
            locale: 'en_US',
            decimalDigits: 3,
          ),
          equals(r'$1,234.568'),
        );
      });

      test('should format with 1 digit decimal', () {
        expect(
          CurrencyFormatterUtil.format(1.5, locale: 'en_US', decimalDigits: 1),
          equals(r'$1.5'),
        );
      });
    });

    group('Symbol Options', () {
      test('should hide symbol', () {
        expect(
          CurrencyFormatterUtil.format(
            99.99,
            locale: 'en_US',
            shouldShowSymbol: false,
          ),
          equals('99.99'),
        );
      });

      test('should apply custom symbol override', () {
        expect(
          CurrencyFormatterUtil.format(
            99.99,
            locale: 'en_US',
            symbolOverride: '¥',
          ),
          contains('¥'),
        );
      });

      test('should apply symbol override with pound', () {
        expect(
          CurrencyFormatterUtil.format(
            50,
            locale: 'en_US',
            symbolOverride: '£',
          ),
          contains('£'),
        );
      });
    });

    group('Custom Separators', () {
      test('should apply custom grouping . and decimal ,', () {
        expect(
          CurrencyFormatterUtil.format(
            1234567.89,
            locale: 'en_US',
            groupingSeparator: '.',
            decimalSeparator: ',',
          ),
          contains('1.234.567,89'),
        );
      });

      test('should apply custom grouping # and 0 decimals', () {
        expect(
          CurrencyFormatterUtil.format(
            1234567.89,
            locale: 'en_US',
            groupingSeparator: '#',
            decimalDigits: 0,
          ),
          contains('1#234#568'),
        );
      });

      test('should apply custom symbol separator', () {
        expect(
          CurrencyFormatterUtil.format(
            1234.56,
            locale: 'en_US',
            symbolSeparator: ':::',
          ),
          contains(':::'),
        );
      });
    });

    group('Compact Format', () {
      test('should apply short format for millions', () {
        expect(
          CurrencyFormatterUtil.format(
            1500000,
            locale: 'en_US',
            compactFormatType: CompactFormatType.short,
          ),
          contains('1.5M'),
        );
      });

      test('should apply short format for billions', () {
        expect(
          CurrencyFormatterUtil.format(
            1500000000,
            locale: 'en_US',
            compactFormatType: CompactFormatType.short,
          ),
          contains('1.5B'),
        );
      });

      test('should apply long format for millions', () {
        final result = CurrencyFormatterUtil.format(
          1200000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.long,
        );
        expect(result, contains('million'));
        expect(result, contains('1.2'));
      });

      test('should apply long format for billions', () {
        final result = CurrencyFormatterUtil.format(
          1200000000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.long,
        );
        expect(result, contains('billion'));
        expect(result, contains('1.2'));
      });

      test('should apply compact format with custom symbol for millions', () {
        final result = CurrencyFormatterUtil.format(
          1500000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.short,
          symbolOverride: '€',
        );
        expect(result, contains('€'));
        expect(result, contains('1.5M'));
      });

      test('should apply compact format with custom symbol for billions', () {
        final result = CurrencyFormatterUtil.format(
          1500000000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.short,
          symbolOverride: '€',
        );
        expect(result, contains('€'));
        expect(result, contains('1.5B'));
      });
    });

    group('Input Types & Edge Cases', () {
      test('should handle string numeric input', () {
        expect(
          CurrencyFormatterUtil.format('123.45', locale: 'en_US'),
          equals(r'$123.45'),
        );
      });

      test('should handle int input', () {
        expect(
          CurrencyFormatterUtil.format(100, locale: 'en_US'),
          equals(r'$100.00'),
        );
      });

      test('should use fallback for null input', () {
        expect(
          CurrencyFormatterUtil.format(null, locale: 'en_US'),
          equals('0.00'),
        );
      });

      test('should use fallback for invalid string', () {
        expect(
          CurrencyFormatterUtil.format('abc', locale: 'en_US'),
          equals('0.00'),
        );
      });

      test('should handle decimal rounding edge case', () {
        expect(
          CurrencyFormatterUtil.format(99.999, locale: 'en_US'),
          equals(r'$100.00'),
        );
      });

      test('should handle negative zero', () {
        expect(
          CurrencyFormatterUtil.format(-0, locale: 'en_US'),
          equals(r'$0.00'),
        );
      });

      test('should format large number with decimals', () {
        expect(
          CurrencyFormatterUtil.format(
            1234567890.123,
            locale: 'en_US',
            decimalDigits: 3,
          ),
          equals(r'$1,234,567,890.123'),
        );
      });

      test('should handle small decimal rounding', () {
        expect(
          CurrencyFormatterUtil.format(0.0049, locale: 'en_US'),
          equals(r'$0.00'),
        );
      });
    });

    group('Fallback Behavior', () {
      test('should use fallback value when amount is null', () {
        expect(
          CurrencyFormatterUtil.format(
            null,
            locale: 'en_US',
            fallbackValue: '-',
          ),
          equals('-'),
        );
      });

      test('should use custom fallback value for invalid input', () {
        expect(
          CurrencyFormatterUtil.format(
            'invalid',
            locale: 'en_US',
            fallbackValue: 'N/A',
          ),
          equals('N/A'),
        );
      });
    });
  });
}
