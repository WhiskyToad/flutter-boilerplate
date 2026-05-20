import 'package:skelter/i18n/app_localizations.dart';

enum DeleteAccountReasons {
  doNotNeedItAnyMore,
  productNoMoreRelevant,
  dislikeTheApp,
  other,
}

extension DeleteAccountReasonExtension on DeleteAccountReasons {
  String toViewString() {
    return '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
  }

  String toDeleteAccountReasonString(AppLocalizations l10n) {
    switch (this) {
      case .doNotNeedItAnyMore:
        return l10n.delete_reason_do_not_need_anymore;
      case .productNoMoreRelevant:
        return l10n.delete_reason_product_no_more_relevant;
      case .dislikeTheApp:
        return l10n.delete_reason_dislike_app;
      case .other:
        return l10n.delete_reason_other;
    }
  }
}
