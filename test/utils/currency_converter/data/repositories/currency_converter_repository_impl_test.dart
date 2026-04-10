import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/utils/currency_converter/data/datasources/currency_converter_remote_data_source.dart';
import 'package:skelter/utils/currency_converter/data/models/currency_rate_model.dart';
import 'package:skelter/utils/currency_converter/data/repositories/currency_converter_repository_impl.dart';

class MockCurrencyConverterRemoteDatasource extends Mock
    implements CurrencyConverterRemoteDatasource {}

void main() {
  late CurrencyConverterRepositoryImpl repository;
  late MockCurrencyConverterRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockCurrencyConverterRemoteDatasource();
    repository = CurrencyConverterRepositoryImpl(mockDatasource);
  });

  const tCurrencyRateModel = CurrencyRateModel(
    amount: 1.0,
    base: 'USD',
    date: '2024-01-15',
    rates: {'INR': 83.12},
  );

  group('getExchangeRate', () {
    test('should return currency rate when datasource succeeds', () async {
      when(
        () => mockDatasource.getExchangeRate(
          fromCurrency: any(named: 'fromCurrency'),
          toCurrency: any(named: 'toCurrency'),
        ),
      ).thenAnswer((_) async => tCurrencyRateModel);

      final result = await repository.getExchangeRate(
        fromCurrency: 'USD',
        toCurrency: 'INR',
      );

      expect(result, const Right(tCurrencyRateModel));
      verify(
        () => mockDatasource.getExchangeRate(
          fromCurrency: 'USD',
          toCurrency: 'INR',
        ),
      ).called(1);
    });

    test(
      'should return APIFailure when datasource throws APIException',
      () async {
        const tException = APIException(
          message: 'Rate not available',
          statusCode: 404,
        );
        when(
          () => mockDatasource.getExchangeRate(
            fromCurrency: any(named: 'fromCurrency'),
            toCurrency: any(named: 'toCurrency'),
          ),
        ).thenThrow(tException);

        final result = await repository.getExchangeRate(
          fromCurrency: 'USD',
          toCurrency: 'XYZ',
        );

        expect(
          result,
          Left(
            APIFailure(
              message: tException.message,
              statusCode: tException.statusCode,
            ),
          ),
        );
      },
    );
  });
}
