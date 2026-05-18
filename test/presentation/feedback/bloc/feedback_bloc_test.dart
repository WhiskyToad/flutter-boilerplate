import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/feedback/bloc/feedback_bloc.dart';
import 'package:skelter/presentation/feedback/bloc/feedback_event.dart';
import 'package:skelter/presentation/feedback/bloc/feedback_state.dart';
import 'package:skelter/presentation/feedback/domain/usecases/submit_feedback.dart';
import 'package:skelter/presentation/feedback/enum/feedback_category.dart';

import '../../../test_helpers.dart';

class MockSubmitFeedback extends Mock implements SubmitFeedback {}

void main() {
  late FeedbackBloc feedbackBloc;
  late MockSubmitFeedback mockSubmitFeedback;
  late MockAppLocalizations mockLocalizations;

  setUpAll(() {
    registerFallbackValue(
      const SubmitFeedbackParams(
        userId: 'user-1',
        name: 'Test',
        email: 'test@test.com',
        phoneNumber: '+1234567890',
        rating: 4.0,
        category: FeedbackCategory.suggestion,
        message: 'Test',
      ),
    );
  });

  setUp(() {
    mockSubmitFeedback = MockSubmitFeedback();
    mockLocalizations = MockAppLocalizations();

    when(
      () => mockLocalizations.please_select_a_rating,
    ).thenReturn('Please select a rating');
    when(
      () => mockLocalizations.feedback_category_required,
    ).thenReturn('Category is required');
    when(
      () => mockLocalizations.please_share_your_thoughts,
    ).thenReturn('Please share your thoughts');
    when(
      () => mockLocalizations.messageTooLong(any()),
    ).thenReturn('Message is too long');

    feedbackBloc = FeedbackBloc(
      submitFeedback: mockSubmitFeedback,
      localizations: mockLocalizations,
    );
  });

  tearDown(() {
    feedbackBloc.close();
  });

  group('FeedbackBloc', () {
    test('initial state should be FeedbackState.initial()', () {
      expect(feedbackBloc.state.rating, equals(0));
      expect(feedbackBloc.state.message, isEmpty);
      expect(feedbackBloc.state.isLoading, isFalse);
      expect(feedbackBloc.state.category, isNull);
      expect(feedbackBloc.state.errorMessage, isNull);
    });

    group('FeedbackRatingChangedEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should update rating',
        build: () => feedbackBloc,
        act: (bloc) => bloc.add(const FeedbackRatingChangedEvent(rating: 4.5)),
        expect: () => [
          isA<FeedbackState>().having((s) => s.rating, 'rating', 4.5),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'should clear rating error when rating changes and error existed',
        build: () => feedbackBloc,
        seed: () => const FeedbackState(
          rating: 0,
          message: '',
          isLoading: false,
          ratingError: 'Please select a rating',
        ),
        act: (bloc) => bloc.add(const FeedbackRatingChangedEvent(rating: 3.0)),
        expect: () => [
          isA<FeedbackState>().having((s) => s.ratingError, 'ratingError', ''),
          isA<FeedbackState>().having((s) => s.rating, 'rating', 3.0),
        ],
      );
    });

    group('FeedbackRatingErrorEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should set rating error',
        build: () => feedbackBloc,
        act: (bloc) =>
            bloc.add(const FeedbackRatingErrorEvent(error: 'Rating required')),
        expect: () => [
          isA<FeedbackState>().having(
            (s) => s.ratingError,
            'ratingError',
            'Rating required',
          ),
        ],
      );
    });

    group('FeedbackCategoryChangedEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should update category',
        build: () => feedbackBloc,
        act: (bloc) => bloc.add(
          const FeedbackCategoryChangedEvent(category: FeedbackCategory.bug),
        ),
        expect: () => [
          isA<FeedbackState>().having(
            (s) => s.category,
            'category',
            FeedbackCategory.bug,
          ),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'should clear category error when category changes and error existed',
        build: () => feedbackBloc,
        seed: () => const FeedbackState(
          rating: 0,
          message: '',
          isLoading: false,
          categoryError: 'Category required',
        ),
        act: (bloc) => bloc.add(
          const FeedbackCategoryChangedEvent(
            category: FeedbackCategory.suggestion,
          ),
        ),
        expect: () => [
          isA<FeedbackState>().having(
            (s) => s.categoryError,
            'categoryError',
            '',
          ),
          isA<FeedbackState>().having(
            (s) => s.category,
            'category',
            FeedbackCategory.suggestion,
          ),
        ],
      );
    });

    group('FeedbackCategoryErrorEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should set category error',
        build: () => feedbackBloc,
        act: (bloc) => bloc.add(
          const FeedbackCategoryErrorEvent(error: 'Category required'),
        ),
        expect: () => [
          isA<FeedbackState>().having(
            (s) => s.categoryError,
            'categoryError',
            'Category required',
          ),
        ],
      );
    });

    group('FeedbackMessageChangedEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should update message',
        build: () => feedbackBloc,
        act: (bloc) =>
            bloc.add(const FeedbackMessageChangedEvent(message: 'Great app!')),
        expect: () => [
          isA<FeedbackState>().having(
            (s) => s.message,
            'message',
            'Great app!',
          ),
        ],
      );
    });

    group('FeedbackMessageErrorEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should set message error',
        build: () => feedbackBloc,
        act: (bloc) => bloc.add(
          const FeedbackMessageErrorEvent(error: 'Message required'),
        ),
        expect: () => [
          isA<FeedbackState>().having(
            (s) => s.messageError,
            'messageError',
            'Message required',
          ),
        ],
      );
    });

    group('FeedbackSubmittedEvent', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'should emit success state when submission succeeds',
        build: () {
          when(
            () => mockSubmitFeedback(any()),
          ).thenAnswer((_) async => const Right(null));
          return feedbackBloc;
        },
        seed: () => const FeedbackState(
          rating: 4.5,
          message: 'Great app!',
          isLoading: false,
          category: FeedbackCategory.compliment,
        ),
        act: (bloc) => bloc.add(
          const FeedbackSubmittedEvent(
            userId: 'user-1',
            name: 'John',
            email: 'john@test.com',
            phoneNumber: '+123',
          ),
        ),
        expect: () => [
          isA<FeedbackState>().having((s) => s.isLoading, 'isLoading', true),
          isA<FeedbackSubmittedSuccessState>(),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'should emit failure state when submission fails',
        build: () {
          when(() => mockSubmitFeedback(any())).thenAnswer(
            (_) async => const Left(
              APIFailure(message: 'Server Error', statusCode: 500),
            ),
          );
          return feedbackBloc;
        },
        seed: () => const FeedbackState(
          rating: 4.5,
          message: 'Great app!',
          isLoading: false,
          category: FeedbackCategory.compliment,
        ),
        act: (bloc) => bloc.add(
          const FeedbackSubmittedEvent(
            userId: 'user-1',
            name: 'John',
            email: 'john@test.com',
            phoneNumber: '+123',
          ),
        ),
        expect: () => [
          isA<FeedbackState>().having((s) => s.isLoading, 'isLoading', true),
          isA<FeedbackSubmittedFailureState>(),
        ],
      );
    });
  });
}
