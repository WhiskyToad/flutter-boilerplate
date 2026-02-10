import 'package:dartz/dartz.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';


abstract class AIProductDescriptionRepository {
  Future<Either<Failure, AIProductDescription>> generateProductDescription({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  });
  
  Stream<Either<Failure, String>> generateProductDescriptionStream({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  });
}

