import 'package:flutter/material.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/utils/theme/extension/theme_extension.dart';

class PaymentFailedMessage extends StatelessWidget {
  const PaymentFailedMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.localization.payment_failed,
          style: AppTextStyles.h4SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.localization.payment_failed_message,
          style: AppTextStyles.p3Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
