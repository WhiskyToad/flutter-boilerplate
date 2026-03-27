// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class HapticFeedbackUtil {
  HapticFeedbackUtil._();

  static Future<bool> get hasVibrator async => (await Vibration.hasVibrator());

  static Future<void> _vibrate({
    List<int> pattern = const [],
    List<int> intensities = const [],
    int repeat = -1,
    int fallbackDuration = 20,
  }) async {
    if (!(await hasVibrator)) return;

    await Vibration.cancel();

    try {
      if (pattern.isNotEmpty && await Vibration.hasCustomVibrationsSupport()) {
        final bool hasAmplitudeControl = await Vibration.hasAmplitudeControl();

        await Vibration.vibrate(
          pattern: pattern,
          // Note:It will use custom intensities if the device supports amplitude control.
          // If not supported, the system will use the default vibration strength.
          intensities: hasAmplitudeControl ? intensities : [],
          repeat: repeat,
        );
        return;
      }

      await Vibration.vibrate(duration: fallbackDuration);
    } catch (_) {
      try {
        // Absolute fallback vibration
        await Vibration.vibrate(duration: 20);
      } catch (e) {
        debugPrint('Haptic fallback vibration error: $e');
      }
    }
  }

  /// ---------------------------- Basic Haptic Feedback -----------------------

  static Future<void> light() => _vibrate(
    pattern: [0, 12, 30, 14],
    intensities: [0, 60, 0, 60],
    fallbackDuration: 15,
  );

  static Future<void> medium() =>
      _vibrate(pattern: [0, 16, 40, 16], intensities: [0, 120, 0, 120]);

  static Future<void> heavy() => _vibrate(
    pattern: [0, 20, 50, 20],
    intensities: [0, 200, 0, 200],
    fallbackDuration: 18,
  );

  static Future<void> tap() => _vibrate(
    pattern: [0, 10, 20, 10],
    intensities: [0, 80, 0, 80],
    fallbackDuration: 12,
  );

  static Future<void> vibrate() => heavy();

  /// -------------------------- SEMANTIC FEEDBACK -----------------------------

  static Future<void> success() => _vibrate(
    pattern: [0, 18, 40, 18, 60, 25],
    intensities: [0, 150, 0, 200, 0, 255],
  );

  static Future<void> error() => _vibrate(
    pattern: [0, 30, 50, 20, 30, 20],
    intensities: [0, 255, 0, 180, 0, 180],
    fallbackDuration: 30,
  );

  static Future<void> warning() => _vibrate(
    pattern: [0, 25, 40, 25, 40, 25],
    intensities: [0, 200, 0, 200, 0, 200],
    fallbackDuration: 40,
  );

  static Future<void> doubleTap() => _vibrate(
    pattern: [0, 30, 50, 30, 50, 30],
    intensities: [0, 128, 0, 128],
    fallbackDuration: 35,
  );

  static Future<void> tripleTap() => _vibrate(
    pattern: [0, 30, 40, 30, 40, 30],
    intensities: [0, 128, 0, 128, 0, 128],
    fallbackDuration: 40,
  );

  static Future<void> presetSuccess() async {
    if (!await hasVibrator) return;
    await Vibration.cancel();
    try {
      await Vibration.vibrate(preset: VibrationPreset.quickSuccessAlert);
    } catch (_) {
      await success();
    }
  }

  static Future<void> presetDoubleBuzz() async {
    if (!await hasVibrator) return;
    await Vibration.cancel();
    try {
      await Vibration.vibrate(preset: VibrationPreset.doubleBuzz);
    } catch (_) {
      await doubleTap();
    }
  }

  static Future<void> presetEmergencyOrWarning() async {
    if (!await hasVibrator) return;
    await Vibration.cancel();
    try {
      await Vibration.vibrate(preset: VibrationPreset.emergencyAlert);
    } catch (_) {
      await warning();
    }
  }

  static Future<void> customPattern({
    required List<int> pattern,
    List<int> intensities = const [],
    int repeat = -1,
  }) => _vibrate(pattern: pattern, intensities: intensities, repeat: repeat);
}
