import 'package:flutter/foundation.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:skelter/constants/constants.dart';

/// Triggers the native in-app review prompt (iOS StoreKit / Android Play Core).
///
/// Throttled to 7-day minimum / 60-day remind via `rate_my_app`.
/// iOS uses placeholder [kAppStoreIdentifier] — OK for the native dialog
/// (StoreKit identifies the app by bundle id), but replace before iOS release.
/// Stores silently skip if quota is exhausted or app isn't Play-installed.
class InAppReviewService {
  InAppReviewService()
    : _rateMyApp = RateMyApp(
        googlePlayIdentifier: kGooglePlayIdentifier,
        appStoreIdentifier: kAppStoreIdentifier,
        minDays: 7,
        minLaunches: 0,
        remindDays: 60,
      );

  final RateMyApp _rateMyApp;

  /// Initializes the rate_my_app gating and, if eligible, launches the
  /// native review dialog on the current platform.
  Future<void> requestReviewIfEligible() async {
    try {
      await _rateMyApp.init();
      if (!_rateMyApp.shouldOpenDialog) return;
      await _rateMyApp.callEvent(RateMyAppEventType.requestReview);
      await _rateMyApp.launchNativeReviewDialog();
    } catch (e, s) {
      debugPrint('[InAppReview] Failed to launch native review: $e\n$s');
    }
  }
}
