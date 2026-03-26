import 'package:equatable/equatable.dart';
import 'package:skelter/presentation/feedback/enum/feedback_category.dart';

class FeedbackEntity extends Equatable {
  const FeedbackEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.rating,
    required this.category,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final double rating;
  final FeedbackCategory category;
  final String message;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    phoneNumber,
    rating,
    category,
    message,
    createdAt,
  ];
}
