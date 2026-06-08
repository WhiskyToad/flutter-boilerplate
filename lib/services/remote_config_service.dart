import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/force_update/constants/force_update_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteConfigService {
  static RemoteConfigService? _instance;

  factory RemoteConfigService({SupabaseClient? client}) {
    return _instance ??= RemoteConfigService._internal(client);
  }

  RemoteConfigService._internal(SupabaseClient? client)
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Map<String, String> _values = {
    kRemoteConfigAppLatestVersionKey: '1.0.0',
    kRemoteConfigMandatoryAppVersionKey: '1.0.0',
    kRemoteConfigActiveAppIconKey: 'default',
  };

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final rows = await _client.from('app_config').select('key,value');
      _applyRows(rows);
      _subscription = _client
          .from('app_config')
          .stream(primaryKey: ['key'])
          .listen(_applyRows);
      _logCurrentValues();
      _isInitialized = true;
    } catch (e) {
      debugPrint('[RemoteConfig] Supabase initialization error: $e');
      _isInitialized = true;
    }
  }

  String getString(String key, {String defaultValue = ''}) {
    return _values[key] ?? defaultValue;
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _applyRows(List<Map<String, dynamic>> rows) {
    for (final row in rows) {
      final key = row['key']?.toString();
      if (key == null || key.isEmpty) continue;
      _values[key] = row['value']?.toString() ?? '';
    }
    _logCurrentValues();
  }

  void _logCurrentValues() {
    debugPrint(
      '[RemoteConfig] MandatoryAppVersion: '
      '${getString(kRemoteConfigMandatoryAppVersionKey)}',
    );

    debugPrint(
      '[RemoteConfig] AppLatestVersion: '
      '${getString(kRemoteConfigAppLatestVersionKey)}',
    );
  }
}
