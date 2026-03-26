import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/feedback/bloc/feedback_bloc.dart';
import 'package:skelter/presentation/feedback/bloc/feedback_state.dart';
import 'package:skelter/presentation/feedback/domain/usecases/submit_feedback.dart';
import 'package:skelter/presentation/feedback/widgets/feedback_app_bar.dart';
import 'package:skelter/presentation/feedback/widgets/feedback_category_section.dart';
import 'package:skelter/presentation/feedback/widgets/feedback_description.dart';
import 'package:skelter/presentation/feedback/widgets/feedback_message_section.dart';
import 'package:skelter/presentation/feedback/widgets/feedback_rating_section.dart';
import 'package:skelter/presentation/feedback/widgets/feedback_submit_button.dart';
import 'package:skelter/utils/extensions/build_context_ext.dart';

@RoutePage()
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = context.localization;
    return BlocProvider(
      create: (_) => FeedbackBloc(
        submitFeedback: sl<SubmitFeedback>(),
        localizations: appLocalizations,
      ),
      child: BlocListener<FeedbackBloc, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSubmittedSuccessState) {
            context.router.maybePop();
            context.showSnackBar(
              context.localization.feedback_submitted_success,
            );
          } else if (state is FeedbackSubmittedFailureState) {
            context.showSnackBar(
              state.errorMessage ??
                  context.localization.opps_something_went_wrong,
              isDisplayingError: true,
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: const FeedbackAppBar(),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: const FeedbackScreenBody(),
            ),
            bottomNavigationBar: const FeedbackSubmitButton(),
          ),
        ),
      ),
    );
  }
}

class FeedbackScreenBody extends StatelessWidget {
  const FeedbackScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          FeedbackDescription(),
          SizedBox(height: 30),
          FeedbackRatingSection(),
          SizedBox(height: 24),
          FeedbackCategorySection(),
          SizedBox(height: 24),
          FeedbackMessageSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
