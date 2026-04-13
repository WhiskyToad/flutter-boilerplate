import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/currency_formatter_util.dart';

void main() {
  group('CurrencyFormatter Util Tests', () {
    group('Basic Formatting', () {
      test('formats positive numbers with default setup', () {
        expect(
          CurrencyFormatterUtil.format(1234.56, locale: 'en_US'),
          equals(r'$1,234.56'),
        );
      });

      test('formats zero', () {
        expect(
          CurrencyFormatterUtil.format(0, locale: 'en_US'),
          equals(r'$0.00'),
        );
      });

      test('formats negative numbers', () {
        expect(
          CurrencyFormatterUtil.format(-50.25, locale: 'en_US'),
          equals(r'-$50.25'),
        );
      });

      test('formats large numbers', () {
        expect(
          CurrencyFormatterUtil.format(1000000, locale: 'en_US'),
          equals(r'$1,000,000.00'),
        );
      });
    });

    group('Currency Code Support', () {
      test('formatCurrency displays USD symbol for United States', () {
        expect(
          CurrencyFormatterUtil.format(
            1250.99,
            locale: 'en_US',
            currencyCode: 'USD',
          ),
          contains('\$'),
        );
      });

      test('formatCurrency displays EUR symbol for Euro', () {
        expect(
          CurrencyFormatterUtil.format(
            100.00,
            locale: 'de_DE',
            currencyCode: 'EUR',
          ),
          contains('€'),
        );
      });

      test('formatCurrency displays GBP symbol for British Pound', () {
        expect(
          CurrencyFormatterUtil.format(
            500.50,
            locale: 'en_GB',
            currencyCode: 'GBP',
          ),
          contains('£'),
        );
      });

      test('formatCurrency displays JPY symbol for Japanese Yen', () {
        expect(
          CurrencyFormatterUtil.format(
            100000,
            locale: 'ja_JP',
            currencyCode: 'JPY',
          ),
          contains('¥'),
        );
      });

      test('formatCurrency displays CHF symbol for Swiss Franc', () {
        expect(
          CurrencyFormatterUtil.format(
            250.75,
            locale: 'de_CH',
            currencyCode: 'CHF',
          ),
          contains('CHF'),
        );
      });

      test('formatCurrency displays CAD symbol for Canadian Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            350.25,
            locale: 'en_CA',
            currencyCode: 'CAD',
          ),
          contains('\$'),
        );
      });

      test('formatCurrency displays AUD symbol for Australian Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            450.00,
            locale: 'en_AU',
            currencyCode: 'AUD',
          ),
          contains('\$'),
        );
      });

      test('formatCurrency displays CNY symbol for Chinese Yuan', () {
        expect(
          CurrencyFormatterUtil.format(
            600.50,
            locale: 'zh_CN',
            currencyCode: 'CNY',
          ),
          contains('¥'),
        );
      });

      test('formatCurrency displays INR symbol for Indian Rupee', () {
        expect(
          CurrencyFormatterUtil.format(
            5000.00,
            locale: 'en_IN',
            currencyCode: 'INR',
          ),
          contains('₹'),
        );
      });

      test('formatCurrency displays SGD symbol for Singapore Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            150.75,
            locale: 'en_SG',
            currencyCode: 'SGD',
          ),
          contains('\$'),
        );
      });

      test('formatCurrency displays HKD symbol for Hong Kong Dollar', () {
        expect(
          CurrencyFormatterUtil.format(
            800.25,
            locale: 'zh_HK',
            currencyCode: 'HKD',
          ),
          contains('\$'),
        );
      });

      test('formatCurrency displays MXN symbol for Mexican Peso', () {
        expect(
          CurrencyFormatterUtil.format(
            2000.50,
            locale: 'es_MX',
            currencyCode: 'MXN',
          ),
          contains('\$'),
        );
      });

      test('formatCurrency displays BRL symbol for Brazilian Real', () {
        expect(
          CurrencyFormatterUtil.format(
            1500.75,
            locale: 'pt_BR',
            currencyCode: 'BRL',
          ),
          contains('R'),
        );
      });

      test('formatCurrency displays KRW symbol for South Korean Won', () {
        expect(
          CurrencyFormatterUtil.format(
            50000.00,
            locale: 'ko_KR',
            currencyCode: 'KRW',
          ),
          contains('₩'),
        );
      });

      test('formatCurrency displays THB symbol for Thai Baht', () {
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
      test('default 2 decimals', () {
        expect(
          CurrencyFormatterUtil.format(1234.56789, locale: 'en_US'),
          equals(r'$1,234.57'),
        );
      });

      test('0 decimals rounding', () {
        expect(
          CurrencyFormatterUtil.format(
            1234.56789,
            locale: 'en_US',
            decimalDigits: 0,
          ),
          equals(r'$1,235'),
        );
      });

      test('3 decimals', () {
        expect(
          CurrencyFormatterUtil.format(
            1234.56789,
            locale: 'en_US',
            decimalDigits: 3,
          ),
          equals(r'$1,234.568'),
        );
      });

      test('1 digit decimal', () {
        expect(
          CurrencyFormatterUtil.format(1.5, locale: 'en_US', decimalDigits: 1),
          equals(r'$1.5'),
        );
      });
    });

    group('Symbol Options', () {
      test('hide symbol', () {
        expect(
          CurrencyFormatterUtil.format(
            99.99,
            locale: 'en_US',
            shouldShowSymbol: false,
          ),
          equals('99.99'),
        );
      });

      test('custom symbol override', () {
        expect(
          CurrencyFormatterUtil.format(
            99.99,
            locale: 'en_US',
            symbolOverride: '¥',
          ),
          contains('¥'),
        );
      });

      test('symbol override with pound', () {
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
      test('custom grouping . and decimal ,', () {
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

      test('custom grouping # and 0 decimals', () {
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

      test('custom symbol separator', () {
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
      test('short format for millions', () {
        expect(
          CurrencyFormatterUtil.format(
            1500000,
            locale: 'en_US',
            compactFormatType: CompactFormatType.short,
          ),
          contains('1.5M'),
        );
      });

      test('short format for billions', () {
        expect(
          CurrencyFormatterUtil.format(
            1500000000,
            locale: 'en_US',
            compactFormatType: CompactFormatType.short,
          ),
          contains('1.5B'),
        );
      });

      test('long format for millions', () {
        final result = CurrencyFormatterUtil.format(
          1200000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.long,
        );
        expect(result, contains('million'));
        expect(result, contains('1.2'));
      });

      test('long format for billions', () {
        final result = CurrencyFormatterUtil.format(
          1200000000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.long,
        );
        expect(result, contains('billion'));
        expect(result, contains('1.2'));
      });

      test('compact with custom symbol for millions', () {
        final result = CurrencyFormatterUtil.format(
          1500000,
          locale: 'en_US',
          compactFormatType: CompactFormatType.short,
          symbolOverride: '€',
        );
        expect(result, contains('€'));
        expect(result, contains('1.5M'));
      });

      test('compact with custom symbol for billions', () {
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
      test('string numeric input', () {
        expect(
          CurrencyFormatterUtil.format('123.45', locale: 'en_US'),
          equals(r'$123.45'),
        );
      });

      test('int input', () {
        expect(
          CurrencyFormatterUtil.format(100, locale: 'en_US'),
          equals(r'$100.00'),
        );
      });

      test('null input fallback', () {
        expect(
          CurrencyFormatterUtil.format(null, locale: 'en_US'),
          equals('0.00'),
        );
      });

      test('invalid string fallback', () {
        expect(
          CurrencyFormatterUtil.format('abc', locale: 'en_US'),
          equals('0.00'),
        );
      });

      test('decimal rounding edge', () {
        expect(
          CurrencyFormatterUtil.format(99.999, locale: 'en_US'),
          equals(r'$100.00'),
        );
      });

      test('negative zero', () {
        expect(
          CurrencyFormatterUtil.format(-0, locale: 'en_US'),
          equals(r'$0.00'),
        );
      });

      test('large number with decimals', () {
        expect(
          CurrencyFormatterUtil.format(
            1234567890.123,
            locale: 'en_US',
            decimalDigits: 3,
          ),
          equals(r'$1,234,567,890.123'),
        );
      });

      test('small decimal rounding', () {
        expect(
          CurrencyFormatterUtil.format(0.0049, locale: 'en_US'),
          equals(r'$0.00'),
        );
      });
    });

    group('Fallback Behavior', () {
      test('uses fallback value when amount is null', () {
        expect(
          CurrencyFormatterUtil.format(
            null,
            locale: 'en_US',
            fallbackValue: '-',
          ),
          equals('-'),
        );
      });

      test('uses custom fallback value for invalid input', () {
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
