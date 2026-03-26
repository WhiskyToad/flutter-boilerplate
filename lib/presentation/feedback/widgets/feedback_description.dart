import 'package:flutter/material.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';

class FeedbackDescription extends StatelessWidget {
  const FeedbackDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.localization.feedback_description,
      style: AppTextStyles.p2Regular.copyWith(
        color: context.currentTheme.textNeutralPrimary,
      ),
    );
  }
}
