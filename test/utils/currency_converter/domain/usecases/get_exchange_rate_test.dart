import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/utils/currency_converter/domain/entities/currency_rate.dart';
import 'package:skelter/utils/currency_converter/domain/repositories/currency_converter_repository.dart';
import 'package:skelter/utils/currency_converter/domain/usecases/get_exchange_rate.dart';

class MockCurrencyConverterRepository extends Mock
    implements CurrencyConverterRepository {}

void main() {
  late GetExchangeRate useCase;
  late MockCurrencyConverterRepository mockRepository;

  setUp(() {
    mockRepository = MockCurrencyConverterRepository();
    useCase = GetExchangeRate(mockRepository);
  });

  const tCurrencyRate = CurrencyRate(
    amount: 1.0,
    base: 'USD',
    date: '2024-01-15',
    rates: {'INR': 83.12},
  );

  const tParams = ExchangeRateParams(fromCurrency: 'USD', toCurrency: 'INR');

  group('GetExchangeRate', () {
    test('should get exchange rate from the repository', () async {
      when(
        () => mockRepository.getExchangeRate(
          fromCurrency: any(named: 'fromCurrency'),
          toCurrency: any(named: 'toCurrency'),
        ),
      ).thenAnswer((_) async => const Right(tCurrencyRate));

      final result = await useCase(tParams);

      expect(result, const Right(tCurrencyRate));
      verify(
        () => mockRepository.getExchangeRate(
          fromCurrency: 'USD',
          toCurrency: 'INR',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      const tFailure = APIFailure(message: 'Network Error', statusCode: 500);
      when(
        () => mockRepository.getExchangeRate(
          fromCurrency: any(named: 'fromCurrency'),
          toCurrency: any(named: 'toCurrency'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('ExchangeRateParams', () {
    test('should store currencies correctly', () {
      expect(tParams.fromCurrency, equals('USD'));
      expect(tParams.toCurrency, equals('INR'));
    });
  });
}
