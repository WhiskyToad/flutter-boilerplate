import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/currency_converter/data/models/currency_rate_model.dart';
import 'package:skelter/utils/currency_converter/domain/entities/currency_rate.dart';
import 'package:skelter/utils/typedef.dart';

void main() {
  const tCurrencyRateModel = CurrencyRateModel(
    amount: 1.0,
    base: 'USD',
    date: '2024-01-15',
    rates: {'INR': 83.12, 'EUR': 0.92, 'GBP': 0.79},
  );

  final DataMap tMap = {
    'amount': 1.0,
    'base': 'USD',
    'date': '2024-01-15',
    'rates': {'INR': 83.12, 'EUR': 0.92, 'GBP': 0.79},
  };

  group('CurrencyRateModel', () {
    test('should be a subclass of CurrencyRate entity', () {
      expect(tCurrencyRateModel, isA<CurrencyRate>());
    });

    group('fromMap', () {
      test('should return a valid model from a map', () {
        final result = CurrencyRateModel.fromMap(tMap);

        expect(result.amount, equals(1.0));
        expect(result.base, equals('USD'));
        expect(result.date, equals('2024-01-15'));
        expect(result.rates['INR'], equals(83.12));
        expect(result.rates['EUR'], equals(0.92));
        expect(result.rates['GBP'], equals(0.79));
      });

      test('should handle amount as int', () {
        final mapWithIntAmount = Map<String, dynamic>.from(tMap)
          ..['amount'] = 1;

        final result = CurrencyRateModel.fromMap(mapWithIntAmount);

        expect(result.amount, equals(1.0));
        expect(result.amount, isA<double>());
      });

      test('should handle rates with int values', () {
        final mapWithIntRates = Map<String, dynamic>.from(tMap)
          ..['rates'] = {'INR': 83, 'EUR': 1};

        final result = CurrencyRateModel.fromMap(mapWithIntRates);

        expect(result.rates['INR'], equals(83.0));
        expect(result.rates['EUR'], equals(1.0));
      });

      test('should handle empty rates map', () {
        final mapWithEmptyRates = Map<String, dynamic>.from(tMap)
          ..['rates'] = {};

        final result = CurrencyRateModel.fromMap(mapWithEmptyRates);

        expect(result.rates, isEmpty);
      });
    });

    group('fromJson', () {
      test('should return a valid model from a JSON string', () {
        final jsonString = jsonEncode(tMap);

        final result = CurrencyRateModel.fromJson(jsonString);

        expect(result.base, equals('USD'));
        expect(result.rates.length, equals(3));
      });
    });

    group('toMap', () {
      test('should return a map containing proper data', () {
        final result = tCurrencyRateModel.toMap();

        expect(result['amount'], equals(1.0));
        expect(result['base'], equals('USD'));
        expect(result['date'], equals('2024-01-15'));
        expect(
          result['rates'],
          equals({'INR': 83.12, 'EUR': 0.92, 'GBP': 0.79}),
        );
      });
    });

    group('toJson', () {
      test('should return a valid JSON string', () {
        final result = tCurrencyRateModel.toJson();
        final decoded = jsonDecode(result) as DataMap;

        expect(decoded['base'], equals('USD'));
        expect(decoded['amount'], equals(1.0));
      });
    });

    group('copyWith', () {
      test('should return a new model with updated base', () {
        final result = tCurrencyRateModel.copyWith(base: 'EUR');

        expect(result.base, equals('EUR'));
        expect(result.amount, equals(tCurrencyRateModel.amount));
        expect(result.date, equals(tCurrencyRateModel.date));
      });

      test('should return a new model with updated rates', () {
        final result = tCurrencyRateModel.copyWith(rates: {'JPY': 148.5});

        expect(result.rates, equals({'JPY': 148.5}));
        expect(result.base, equals(tCurrencyRateModel.base));
      });

      test('should return identical model when no params are passed', () {
        final result = tCurrencyRateModel.copyWith();

        expect(result.amount, equals(tCurrencyRateModel.amount));
        expect(result.base, equals(tCurrencyRateModel.base));
        expect(result.date, equals(tCurrencyRateModel.date));
        expect(result.rates, equals(tCurrencyRateModel.rates));
      });
    });

    group('roundtrip', () {
      test('toJson then fromJson should produce equivalent model', () {
        final json = tCurrencyRateModel.toJson();
        final result = CurrencyRateModel.fromJson(json);

        expect(result.amount, equals(tCurrencyRateModel.amount));
        expect(result.base, equals(tCurrencyRateModel.base));
        expect(result.date, equals(tCurrencyRateModel.date));
        expect(result.rates, equals(tCurrencyRateModel.rates));
      });
    });
  });
}
