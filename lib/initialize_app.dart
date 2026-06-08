import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/services/ai/gemini_service.dart';
import 'package:skelter/services/performance_monitoring_service.dart';
import 'package:skelter/services/remote_config_service.dart';
import 'package:skelter/utils/app_environment.dart';
import 'package:skelter/utils/app_flavor_env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> initializeApp({
  SupabaseClient? supabaseClient,
  Object? firebaseAuth,
  Object? googleSignIn,
  Object? firebaseAuthService,
  Dio? dio,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Precache `liquid_glass_widgets` shader to avoid a first-paint white flash.
  await LiquidGlassWidgets.initialize();
  tz.initializeTimeZones();

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('[Env] .env load skipped: $e');
  }

  if (supabaseClient == null) {
    final supabaseUrl = AppConfig.getSupabaseUrl();
    final supabaseAnonKey = AppConfig.getSupabaseAnonKey();
    final useFallbackConfig = AppEnvironment.isTestEnvironment;

    if (!useFallbackConfig &&
        (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty)) {
      throw StateError(
        'Missing Supabase configuration for ${AppConfig.appFlavor.name}. '
        'Set *_SUPABASE_URL and *_SUPABASE_ANON_KEY in .env.',
      );
    }

    await Supabase.initialize(
      url: useFallbackConfig ? 'http://localhost:54321' : supabaseUrl,
      anonKey: useFallbackConfig ? 'test-anon-key' : supabaseAnonKey,
    );
  }

  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();

  await SystemChrome.setPreferredOrientations([.portraitUp, .portraitDown]);

  await configureDependencies(
    supabaseClient: supabaseClient,
    dio: dio,
  );
  await sl<PerformanceMonitoringService>().initialize();

  try {
    sl<GeminiService>().initialize();
  } catch (e) {
    debugPrint('[Gemini] Initialization warning: $e');
  }
}
