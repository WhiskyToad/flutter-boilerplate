import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/utils/currency_converter/currency_converter_util.dart';
import 'package:skelter/utils/currency_converter/domain/usecases/get_exchange_rate.dart';

import 'data/currency_converter_sample_data.dart';

class MockGetExchangeRate extends Mock implements GetExchangeRate {}

class MockExchangeRateParams extends Mock implements ExchangeRateParams {}

void main() {
  late CurrencyConverterUtil currencyConverterUtil;
  late MockGetExchangeRate mockGetExchangeRate;

  setUp(() {
    mockGetExchangeRate = MockGetExchangeRate();
    currencyConverterUtil = CurrencyConverterUtil(mockGetExchangeRate);
    registerFallbackValue(
      const ExchangeRateParams(fromCurrency: 'USD', toCurrency: 'INR'),
    );
  });

  const testFromCurrencyCode = 'USD';
  const testToCurrencyCode = 'INR';
  const testAmountValue = 100.0;

  final double rateUSDToIndianRupee = sampleCurrencyRateData.rates['INR']!;
  final double rateUSDToBritishPound = sampleCurrencyRateData.rates['GBP']!;
  final double rateUSDToJapaneseYen = sampleCurrencyRateData.rates['JPY']!;
  final double rateUSDToAustralianDollar = sampleCurrencyRateData.rates['AUD']!;
  final double rateUSDToCanadianDollar = sampleCurrencyRateData.rates['CAD']!;
  final double rateUSDToChineseYuan = sampleCurrencyRateData.rates['CNY']!;
  final double rateUSDToSingaporeDollar = sampleCurrencyRateData.rates['SGD']!;
  final double rateUSDToSwissFranc = sampleCurrencyRateData.rates['CHF']!;
  final double rateUSDToHongKongDollar = sampleCurrencyRateData.rates['HKD']!;
  final double rateUSDToSouthKoreanWon = sampleCurrencyRateData.rates['KRW']!;

  group('CurrencyConverterUtil Tests', () {
    test('should return original amount when fromCurrency '
        'and toCurrency are the '
        'same (e.g. USD to USD)', () async {
      final result = await currencyConverterUtil.convert(
        amount: testAmountValue,
        fromCurrency: testFromCurrencyCode,
        toCurrency: testFromCurrencyCode,
      );

      expect(result, equals(testAmountValue));
      verifyZeroInteractions(mockGetExchangeRate);
    });

    group('Top 15 Country Conversions', () {
      test('should correctly convert USD to INR', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'INR',
        );

        expect(result, equals(testAmountValue * rateUSDToIndianRupee));
      });

      test('should correctly convert INR to USD', () async {
        final double rateIndianRupeeToUSD = 1 / rateUSDToIndianRupee;
        final mockData = getSampleCurrencyRate(
          base: 'INR',
          specificRates: {'USD': rateIndianRupeeToUSD},
        );

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => Right(mockData));

        final result = await currencyConverterUtil.convert(
          amount: 5000,
          fromCurrency: 'INR',
          toCurrency: 'USD',
        );

        expect(result, closeTo(5000 * rateIndianRupeeToUSD, 0.000001));
      });

      test('should correctly convert USD to GBP', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'GBP',
        );

        expect(result, equals(testAmountValue * rateUSDToBritishPound));
      });

      test('should correctly convert GBP to USD', () async {
        final double rateBritishPoundToUSD = 1 / rateUSDToBritishPound;
        final mockData = getSampleCurrencyRate(
          base: 'GBP',
          specificRates: {'USD': rateBritishPoundToUSD},
        );

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => Right(mockData));

        final result = await currencyConverterUtil.convert(
          amount: 50,
          fromCurrency: 'GBP',
          toCurrency: 'USD',
        );

        expect(result, closeTo(50 * rateBritishPoundToUSD, 0.000001));
      });

      test('should correctly convert USD to JPY', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'JPY',
        );

        expect(result, equals(testAmountValue * rateUSDToJapaneseYen));
      });

      test('should correctly convert JPY to USD', () async {
        final double rateJapaneseYenToUSD = 1 / rateUSDToJapaneseYen;
        final mockData = getSampleCurrencyRate(
          base: 'JPY',
          specificRates: {'USD': rateJapaneseYenToUSD},
        );

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => Right(mockData));

        final result = await currencyConverterUtil.convert(
          amount: 10000,
          fromCurrency: 'JPY',
          toCurrency: 'USD',
        );

        expect(result, closeTo(10000 * rateJapaneseYenToUSD, 0.000001));
      });

      test('should correctly convert USD to AUD', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'AUD',
        );

        expect(result, equals(testAmountValue * rateUSDToAustralianDollar));
      });

      test('should correctly convert AUD to USD', () async {
        final double rateAustralianDollarToUSD = 1 / rateUSDToAustralianDollar;
        final mockData = getSampleCurrencyRate(
          base: 'AUD',
          specificRates: {'USD': rateAustralianDollarToUSD},
        );

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => Right(mockData));

        final result = await currencyConverterUtil.convert(
          amount: 150,
          fromCurrency: 'AUD',
          toCurrency: 'USD',
        );

        expect(result, closeTo(150 * rateAustralianDollarToUSD, 0.000001));
      });

      test('should correctly convert USD to CAD', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'CAD',
        );

        expect(result, equals(testAmountValue * rateUSDToCanadianDollar));
      });

      test('should correctly convert USD to CNY', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'CNY',
        );

        expect(result, equals(testAmountValue * rateUSDToChineseYuan));
      });

      test('should correctly convert USD to SGD', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'SGD',
        );

        expect(result, equals(testAmountValue * rateUSDToSingaporeDollar));
      });

      test('should correctly convert USD to CHF', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'CHF',
        );

        expect(result, equals(testAmountValue * rateUSDToSwissFranc));
      });

      test('should correctly convert USD to HKD', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'HKD',
        );

        expect(result, equals(testAmountValue * rateUSDToHongKongDollar));
      });

      test('should correctly convert USD to KRW', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'KRW',
        );

        expect(result, equals(testAmountValue * rateUSDToSouthKoreanWon));
      });

      // Mixed: MXN -> BRL (Cross-rate logic depends on implementation, but
      // assuming API provides direct rate)
      test('should correctly convert MXN to BRL given a direct rate', () async {
        // Assume API returns direct rate for MXN -> BRL.
        // Let's say 1 MXN = 0.3 BRL approx
        const rateMXNToBRL = 0.3;
        final mockData = getSampleCurrencyRate(
          base: 'MXN',
          specificRates: {'BRL': rateMXNToBRL},
        );

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => Right(mockData));

        final result = await currencyConverterUtil.convert(
          amount: 100,
          fromCurrency: 'MXN',
          toCurrency: 'BRL',
        );

        expect(result, equals(100 * rateMXNToBRL));
      });
    });

    group('Edge Cases', () {
      test('should return 0.0 when converting amount of 0', () async {
        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: 0,
          fromCurrency: testFromCurrencyCode,
          toCurrency: testToCurrencyCode,
        );

        expect(result, equals(0.0));
      });

      test(
        'should return negative result when converting negative amount',
        () async {
          const negativeAmount = -100.0;

          when(
            () => mockGetExchangeRate(any()),
          ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

          final result = await currencyConverterUtil.convert(
            amount: negativeAmount,
            fromCurrency: 'USD',
            toCurrency: 'INR',
          );

          expect(result, equals(negativeAmount * rateUSDToIndianRupee));
        },
      );

      test('should handle very small amounts (precision check)', () async {
        const smallAmount = 0.000001;

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: smallAmount,
          fromCurrency: 'USD',
          toCurrency: 'INR',
        );

        expect(
          result,
          closeTo(smallAmount * rateUSDToIndianRupee, 0.000000001),
        );
      });

      test('should handle very large amounts (billions)', () async {
        const largeAmount = 1000000000.0;

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => const Right(sampleCurrencyRateData));

        final result = await currencyConverterUtil.convert(
          amount: largeAmount,
          fromCurrency: 'USD',
          toCurrency: 'INR',
        );

        expect(result, equals(largeAmount * rateUSDToIndianRupee));
      });
    });

    group('Error Handling', () {
      test('should return 0.0 when the API call returns a Failure', () async {
        const tFailureMessage = 'API Error';
        when(() => mockGetExchangeRate(any())).thenAnswer(
          (_) async =>
              const Left(APIFailure(message: tFailureMessage, statusCode: 500)),
        );

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: testFromCurrencyCode,
          toCurrency: testToCurrencyCode,
        );

        expect(result, equals(0.0));
      });

      test('should return 0.0 when the returned exchange rates do not'
          ' include the target currency', () async {
        final tEmptyRate = getSampleCurrencyRate(specificRates: {});

        when(
          () => mockGetExchangeRate(any()),
        ).thenAnswer((_) async => Right(tEmptyRate));

        final result = await currencyConverterUtil.convert(
          amount: testAmountValue,
          fromCurrency: 'USD',
          toCurrency: 'INR', // INR is missing in specificRates above
        );

        expect(result, equals(0.0));
      });
    });
  });
}
