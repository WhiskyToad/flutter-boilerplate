import 'package:skelter/presentation/feedback/constants/feedback_constants.dart';
import 'package:skelter/utils/typedef.dart';

mixin FeedbackRepository {
  ResultVoid submitFeedback({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required double rating,
    required FeedbackCategory category,
    required String message,
  });
}
