import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/presentation/feedback/constants/feedback_constants.dart';
import 'package:skelter/presentation/feedback/data/models/feedback_model.dart';
import 'package:skelter/services/firestore_service.dart';

mixin FeedbackRemoteDatasource {
  Future<void> submitFeedback(FeedbackModel feedback);
}

class FeedbackRemoteDatasourceImpl with FeedbackRemoteDatasource {
  FeedbackRemoteDatasourceImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      await _firestoreService.addDocument(
        collection: kFeedbackCollection,
        data: feedback.toMap(),
      );
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }
}
