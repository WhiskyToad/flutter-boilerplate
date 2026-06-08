import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skelter/presentation/force_update/constants/force_update_constants.dart';
import 'package:skelter/services/remote_config_service.dart';

/// Supported app icon variants.
/// The [key] must match:
/// - Android: activity-alias suffix in AndroidManifest.xml
/// - iOS: alternate icon key in Info.plist
enum AppIconType {
  defaultIcon('default'),
  diwali('diwali');

  const AppIconType(this.key);

  final String key;

  static AppIconType fromKey(String? key) {
    if (key == null || key.isEmpty) return AppIconType.defaultIcon;
    return AppIconType.values.firstWhere(
      (type) => type.key == key,
      orElse: () => AppIconType.defaultIcon,
    );
  }
}

class DynamicIconService {
  final RemoteConfigService _remoteConfigService;
  String? _applicationId;

  DynamicIconService({RemoteConfigService? remoteConfigService})
    : _remoteConfigService = remoteConfigService ?? RemoteConfigService();

  /// Returns the applicationId (cached after first call).
  Future<String> _getApplicationId() async {
    if (_applicationId != null) return _applicationId!;
    final info = await PackageInfo.fromPlatform();
    _applicationId = info.packageName;
    return _applicationId!;
  }

  /// Builds the native icon name for the given [iconType].
  /// - Android: `${applicationId}.${key}`
  /// (matches manifest `${applicationId}.xxx`).
  /// - iOS: short key for alternate icons, null for primary icon.
  Future<String?> _nativeIconName(AppIconType iconType) async {
    if (Platform.isAndroid) {
      final appId = await _getApplicationId();
      return '$appId.${iconType.key}';
    }
    if (iconType == AppIconType.defaultIcon) return null;
    return iconType.key;
  }

  /// Gets the currently active icon by querying the native plugin.
  Future<AppIconType> getCurrentIcon() async {
    try {
      final currentName = await FlutterDynamicIconPlus.alternateIconName;
      debugPrint('[DynamicIcon] Native current icon: $currentName');
      if (currentName == null || currentName.isEmpty) {
        return AppIconType.defaultIcon;
      }
      // On Android the plugin returns the fully qualified name
      // (e.g. com.solguruz.skelter.dev.diwali), extract the suffix.
      final shortKey = currentName.split('.').last;
      return AppIconType.fromKey(shortKey);
    } catch (e) {
      debugPrint('[DynamicIcon] Failed to get current icon: $e');
      return AppIconType.defaultIcon;
    }
  }

  /// Fetches the desired icon from Supabase app config.
  AppIconType getRemoteConfigIcon() {
    final iconKey = _remoteConfigService.getString(
      kRemoteConfigActiveAppIconKey,
      defaultValue: AppIconType.defaultIcon.key,
    );
    debugPrint('[DynamicIcon] Remote config icon: $iconKey');
    return AppIconType.fromKey(iconKey);
  }

  /// Changes the app icon to the specified [iconType].
  Future<void> setIcon(AppIconType iconType) async {
    final current = await getCurrentIcon();
    if (current == iconType) {
      debugPrint('[DynamicIcon] Icon already set to: ${iconType.key}');
      return;
    }
    try {
      final nativeName = await _nativeIconName(iconType);
      debugPrint('[DynamicIcon] Setting native icon: $nativeName');
      await FlutterDynamicIconPlus.setAlternateIconName(iconName: nativeName);
      debugPrint('[DynamicIcon] Icon changed to: ${iconType.key}');
    } catch (e) {
      debugPrint('[DynamicIcon] Failed to change icon: $e');
    }
  }

  /// Checks Remote Config and applies the icon if different from current.
  /// This should be called on app launch.
  Future<void> syncIconFromRemoteConfig() async {
    try {
      final remoteIcon = getRemoteConfigIcon();
      await setIcon(remoteIcon);
    } catch (e) {
      debugPrint('[DynamicIcon] Failed to sync icon from Remote Config: $e');
    }
  }
}
