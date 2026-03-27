import 'package:equatable/equatable.dart';
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/feedback/domain/repositories/feedback_repository.dart';
import 'package:skelter/presentation/feedback/enum/feedback_category.dart';
import 'package:skelter/utils/typedef.dart';

class SubmitFeedback with UseCaseWithParams<void, SubmitFeedbackParams> {
  const SubmitFeedback(this._repository);

  final FeedbackRepository _repository;

  @override
  ResultVoid call(SubmitFeedbackParams params) => _repository.submitFeedback(
    userId: params.userId,
    name: params.name,
    email: params.email,
    phoneNumber: params.phoneNumber,
    rating: params.rating,
    category: params.category,
    message: params.message,
  );
}

class SubmitFeedbackParams extends Equatable {
  const SubmitFeedbackParams({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.rating,
    required this.category,
    required this.message,
  });

  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final double rating;
  final FeedbackCategory category;
  final String message;

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    phoneNumber,
    rating,
    category,
    message,
  ];
}
