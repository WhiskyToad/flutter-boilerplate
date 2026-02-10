import 'package:dartz/dartz.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/data/datasources/ai_product_description_remote_data_source.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/presentation/product_detail/domain/repositories/ai_product_description_repository.dart';

class AIProductDescriptionRepositoryImpl
    implements AIProductDescriptionRepository {
  const AIProductDescriptionRepositoryImpl(this._remoteDataSource);

  final AIProductDescriptionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AIProductDescription>> generateProductDescription({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  }) async {
    try {
      final result = await _remoteDataSource.generateProductDescription(
        productDetail: productDetail,
        userOrderHistory: userOrderHistory,
      );

      return Right(result);
    } on APIException catch (e) {
      return Left(
        APIFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        APIFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, String>> generateProductDescriptionStream({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  }) async* {
    try {
      final stream = _remoteDataSource.generateProductDescriptionStream(
        productDetail: productDetail,
        userOrderHistory: userOrderHistory,
      );

      await for (final chunk in stream) {
        yield Right(chunk);
      }
    } on APIException catch (e) {
      yield Left(
        APIFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } catch (e) {
      yield Left(
        APIFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }
}

