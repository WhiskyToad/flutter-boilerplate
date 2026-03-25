import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/utils/cache_manager.dart';
import 'package:skelter/utils/currency_converter/data/models/currency_rate_model.dart';
import 'package:skelter/utils/typedef.dart';

mixin CurrencyConverterRemoteDatasource {
  Future<CurrencyRateModel> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  });
}

const kCurrencyConverterBaseUrl = 'https://api.frankfurter.app';
const kGetLatestExchangeRatesEndpoint = 'latest';

class CurrencyConverterRemoteDataSrcImpl
    implements CurrencyConverterRemoteDatasource {
  CurrencyConverterRemoteDataSrcImpl(this._dio);

  final Dio _dio;

  @override
  Future<CurrencyRateModel> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await _dio.get(
        '$kCurrencyConverterBaseUrl/$kGetLatestExchangeRatesEndpoint',
        queryParameters: {'from': fromCurrency, 'to': toCurrency},
        options: sl<CacheManager>().defaultCacheOptions.toOptions(),
      );

      if (response.statusCode != 200) {
        throw APIException(
          message: response.data,
          statusCode: response.statusCode ?? 500,
        );
      }

      return CurrencyRateModel.fromMap(response.data as DataMap);
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }
}
