const String kFeedbackCollection = 'feedback';

const int kFeedbackMessageMaxLength = 500;
const String kFeedbackSubmissionFailed =
    'Failed to submit feedback. Please try again.';

enum FeedbackCategory {
  bug,
  suggestion,
  content,
  compliment,
  other;

  String get value => name;
}
