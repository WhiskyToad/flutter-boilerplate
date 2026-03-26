import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skelter/presentation/feedback/constants/feedback_constants.dart';
import 'package:skelter/presentation/feedback/domain/entities/feedback_entity.dart';
import 'package:skelter/utils/typedef.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.rating,
    required super.category,
    required super.message,
    required super.createdAt,
  });

  factory FeedbackModel.fromMap(DataMap map, String id) {
    final categoryStr = map['category'] as String? ?? FeedbackCategory.other.value;
    final category = FeedbackCategory.values.firstWhere(
      (e) => e.value == categoryStr,
      orElse: () => FeedbackCategory.other,
    );
    return FeedbackModel(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      rating: (map['rating'] as num).toDouble(),
      category: category,
      message: map['message'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  DataMap toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'category': category.value,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
