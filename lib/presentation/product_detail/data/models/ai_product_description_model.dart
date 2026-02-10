import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/utils/typedef.dart';

class AIProductDescriptionModel extends AIProductDescription {
  const AIProductDescriptionModel({
    required super.productId,
    required super.generatedDescription,
    required super.generatedAt,
    super.isPersonalized,
  });

  factory AIProductDescriptionModel.fromEntity(
    AIProductDescription entity,
  ) {
    return AIProductDescriptionModel(
      productId: entity.productId,
      generatedDescription: entity.generatedDescription,
      generatedAt: entity.generatedAt,
      isPersonalized: entity.isPersonalized,
    );
  }

  factory AIProductDescriptionModel.fromMap(DataMap map) {
    return AIProductDescriptionModel(
      productId: map['productId'] as String,
      generatedDescription: map['generatedDescription'] as String,
      generatedAt: DateTime.parse(map['generatedAt'] as String),
      isPersonalized: map['isPersonalized'] as bool? ?? false,
    );
  }

  DataMap toMap() {
    return {
      'productId': productId,
      'generatedDescription': generatedDescription,
      'generatedAt': generatedAt.toIso8601String(),
      'isPersonalized': isPersonalized,
    };
  }

  factory AIProductDescriptionModel.fromGeneratedText({
    required String productId,
    required String generatedText,
    bool isPersonalized = false,
  }) {
    return AIProductDescriptionModel(
      productId: productId,
      generatedDescription: generatedText,
      generatedAt: DateTime.now(),
      isPersonalized: isPersonalized,
    );
  }

  AIProductDescription toEntity() {
    return AIProductDescription(
      productId: productId,
      generatedDescription: generatedDescription,
      generatedAt: generatedAt,
      isPersonalized: isPersonalized,
    );
  }
}

