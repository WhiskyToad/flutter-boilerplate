import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/presentation/delete_account/constants/delete_account_constants.dart';
import 'package:skelter/services/auth/app_auth_models.dart';
import 'package:skelter/shared_pref/prefs.dart';
import 'package:skelter/utils/cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService({SupabaseClient? client, Object? firebaseAuth})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Stream<AppAuthUser?> get authStateChanges {
    return _auth.onAuthStateChange.map((state) => getCurrentUser());
  }

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(AppPhoneAuthCredential) verificationCompleted,
    required Function(String) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      await _auth.signInWithOtp(phone: phoneNumber);
      codeSent(phoneNumber);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error sending phone OTP: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
  }

  @Deprecated('Use sendPhoneOtp instead.')
  Future<void> verifyFBAuthPhoneNumber({
    required String phoneNumber,
    required Function(AppPhoneAuthCredential) verificationCompleted,
    required Function(String) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    required Function(String, {StackTrace? stackTrace}) onError,
  }) {
    return sendPhoneOtp(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      onError: onError,
    );
  }

  Future<AppAuthCredential?> signInWithEmailAndPassword(
    String email,
    String password, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _credentialFromResponse(response);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error signing in with email and password: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
    return null;
  }

  Future<void> sendVerificationEmail({
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    final email = _auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      onError(kSomethingWentWrong);
      return;
    }

    try {
      await _auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error resending verification email: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
  }

  Future<void> sendPasswordResetEmail(
    String email, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error sending password reset email: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
  }

  @Deprecated('Use sendPasswordResetEmail instead.')
  Future<void> sendFBAuthPasswordResetEmail(
    String email, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) {
    return sendPasswordResetEmail(email, onError: onError);
  }

  AppPhoneAuthCredential getPhoneAuthCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return AppPhoneAuthCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  Future<AppAuthCredential?> signInWithPhoneAuthCredential(
    AppPhoneAuthCredential credential, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        phone: credential.verificationId,
        token: credential.smsCode,
        type: OtpType.sms,
      );
      return _credentialFromResponse(response);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error verifying phone OTP: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
    return null;
  }

  Future<AppAuthCredential?> loginWithGoogle({
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    return _loginWithOAuth(OAuthProvider.google, onError: onError);
  }

  Future<AppAuthCredential?> loginWithApple({
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    return _loginWithOAuth(OAuthProvider.apple, onError: onError);
  }

  Future<AppAuthCredential?> signupWithEmailAndPassword(
    String email,
    String password, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      final response = await _auth.signUp(email: email, password: password);
      return _credentialFromResponse(response);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error signing up with email and password: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
    return null;
  }

  AppAuthUser? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppAuthUser.fromSupabaseUser(user, _auth.currentSession, reload);
  }

  bool get isSignedInWithGoogle {
    final user = getCurrentUser();
    if (user == null) return false;
    return user.providerData.any(
      (provider) => provider.providerId == kProviderGoogle,
    );
  }

  Future<void> reload() async {
    try {
      await _auth.refreshSession();
    } catch (e) {
      debugPrint('Error refreshing Supabase auth session: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteCurrentUser({
    required Function(String message, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      await _client.rpc('delete_current_user');
      await Prefs.clear();
      await sl<CacheManager>().clearCachedApiResponse();
      await signOut();
    } on PostgrestException catch (e, stack) {
      debugPrint('Supabase account deletion failed: ${e.message}');
      onError(e.message, stackTrace: stack);
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error deleting account: $e');
      onError(kSomethingWentWrong, stackTrace: stack);
    }
  }

  Future<void> reAuthenticateCurrentUser({
    required Function(String message, {StackTrace? stackTrace}) onError,
  }) async {
    onError(kEmailPasswordReAuthRequired);
  }

  Future<void> reAuthWithEmailPassword({
    required String email,
    required String password,
    required Function(String message, {StackTrace? stackTrace}) onError,
  }) async {
    final response = await signInWithEmailAndPassword(
      email,
      password,
      onError: onError,
    );
    if (response == null || response.user == null) {
      onError(kEmailPasswordReAuthRequired);
    }
  }

  Future<AppAuthCredential?> _loginWithOAuth(
    OAuthProvider provider, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      final didLaunch = await _auth.signInWithOAuth(provider);
      if (!didLaunch) {
        onError(kSomethingWentWrong);
        return null;
      }
      return AppAuthCredential(user: getCurrentUser());
    } on AuthException catch (e, stack) {
      _handleAuthError(e, onError, stackTrace: stack);
    } catch (e, stack) {
      debugPrint('Error signing in with ${provider.name}: $e');
      onError('${provider.name} sign-in failed', stackTrace: stack);
    }
    return null;
  }

  AppAuthCredential _credentialFromResponse(AuthResponse response) {
    final user = response.user == null
        ? null
        : AppAuthUser.fromSupabaseUser(
            response.user!,
            response.session ?? _auth.currentSession,
            reload,
          );
    return AppAuthCredential(user: user);
  }

  void _handleAuthError(
    AuthException e,
    Function(String, {StackTrace? stackTrace}) onError, {
    StackTrace? stackTrace,
  }) {
    var errorMessage = e.message;
    final lowerMessage = e.message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials')) {
      errorMessage = 'The email or password you entered is incorrect.';
    } else if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already')) {
      errorMessage = 'Email already in use, please login to continue.';
    } else if (lowerMessage.contains('weak password')) {
      errorMessage = 'The password you entered is invalid.';
    } else if (lowerMessage.contains('otp') ||
        lowerMessage.contains('token')) {
      errorMessage = 'Invalid OTP. Please try again.';
    } else if (lowerMessage.contains('rate limit')) {
      errorMessage = 'Too many requests, please try again later.';
    }

    debugPrint('SupabaseAuth error: $errorMessage');
    onError(errorMessage, stackTrace: stackTrace);
  }
}
