import 'package:equatable/equatable.dart';

class AIProductDescription extends Equatable {
  const AIProductDescription({
    required this.productId,
    required this.generatedDescription,
    required this.generatedAt,
    this.isPersonalized = false,
  });

  final String productId;
  final String generatedDescription;
  final DateTime generatedAt;
  final bool isPersonalized;

  @override
  List<Object?> get props => [
        productId,
        generatedDescription,
        generatedAt,
        isPersonalized,
      ];

  AIProductDescription copyWith({
    String? productId,
    String? generatedDescription,
    DateTime? generatedAt,
    bool? isPersonalized,
  }) {
    return AIProductDescription(
      productId: productId ?? this.productId,
      generatedDescription: generatedDescription ?? this.generatedDescription,
      generatedAt: generatedAt ?? this.generatedAt,
      isPersonalized: isPersonalized ?? this.isPersonalized,
    );
  }
}

