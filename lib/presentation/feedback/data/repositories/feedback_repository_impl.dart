import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/feedback/constants/feedback_constants.dart';
import 'package:skelter/presentation/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:skelter/presentation/feedback/data/models/feedback_model.dart';
import 'package:skelter/presentation/feedback/domain/repositories/feedback_repository.dart';
import 'package:skelter/utils/typedef.dart';

class FeedbackRepositoryImpl with FeedbackRepository {
  const FeedbackRepositoryImpl(this._remoteDatasource);

  final FeedbackRemoteDatasource _remoteDatasource;

  @override
  ResultVoid submitFeedback({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required double rating,
    required FeedbackCategory category,
    required String message,
  }) async {
    try {
      final model = FeedbackModel(
        id: '',
        userId: userId,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        rating: rating,
        category: category,
        message: message,
        createdAt: DateTime.now(),
      );
      await _remoteDatasource.submitFeedback(model);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e) {
      debugPrint('[FeedbackRepository] unexpected error: $e');
      return Left(
        APIFailure.fromException(
          const APIException(message: kFeedbackSubmissionFailed, statusCode: 500),
        ),
      );
    }
  }
}
