import 'package:equatable/equatable.dart';
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/presentation/product_detail/domain/repositories/ai_product_description_repository.dart';
import 'package:skelter/utils/typedef.dart';

class GenerateAIProductDescription
    with
        UseCaseWithParams<
          AIProductDescription,
          GenerateAIProductDescriptionParams
        > {
  const GenerateAIProductDescription(this._repository);

  final AIProductDescriptionRepository _repository;

  @override
  ResultFuture<AIProductDescription> call(
    GenerateAIProductDescriptionParams params,
  ) async {
    return _repository.generateProductDescription(
      productDetail: params.productDetail,
      userOrderHistory: params.userOrderHistory,
    );
  }
}

/// Parameters for generating AI product description
class GenerateAIProductDescriptionParams extends Equatable {
  const GenerateAIProductDescriptionParams({
    required this.productDetail,
    this.userOrderHistory,
  });

  final ProductDetail productDetail;
  final List<String>? userOrderHistory;

  @override
  List<Object?> get props => [productDetail, userOrderHistory];
}
