import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/services/auth/app_auth_models.dart';
import 'package:skelter/services/supabase_auth_service.dart';

class AuthException implements Exception {
  AuthException({required this.code, this.message});

  final String code;
  final String? message;

  @override
  String toString() => message ?? code;
}

class MockSupabaseAuth extends Mock {
  final _userController = StreamController<AppAuthUser?>.broadcast();
  AppAuthUser? _mockUser;

  AppAuthUser? get currentUser => _mockUser;

  void setMockUser(AppAuthUser? user) {
    _mockUser = user;
    _userController.add(user);
  }

  Stream<AppAuthUser?> authStateChanges() =>
      _userController.stream.startWith(_mockUser);

  Stream<AppAuthUser?> userChanges() =>
      _userController.stream.startWith(_mockUser);

  Stream<AppAuthUser?> idTokenChanges() =>
      _userController.stream.startWith(_mockUser);

  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    required void Function(AppPhoneAuthCredential) verificationCompleted,
    required void Function(Object) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
    @visibleForTesting String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
  }) async {
    debugPrint('Mock verifyPhoneNumber called with phone: $phoneNumber');
    codeSent(phoneNumber ?? 'mock-verification-id', 123456);
  }

  Future<AppAuthCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
            Invocation.method(#signInWithEmailAndPassword, const [], {
              #email: email,
              #password: password,
            }),
            returnValue: Future<AppAuthCredential>.value(
              MockUserCredential(
                _mockUser ??
                    MockUser(
                      email: email,
                      emailVerified: true,
                      phoneNumber: null,
                    ),
              ),
            ),
          )
          as Future<AppAuthCredential>;

  Future<AppAuthCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
            Invocation.method(#createUserWithEmailAndPassword, const [], {
              #email: email,
              #password: password,
            }),
            returnValue: Future<AppAuthCredential>.value(
              MockUserCredential(_mockUser ?? MockUser(email: email)),
            ),
          )
          as Future<AppAuthCredential>;

  Future<AppAuthCredential> signInWithCredential(Object credential) =>
      super.noSuchMethod(
            Invocation.method(#signInWithCredential, [credential]),
            returnValue: Future<AppAuthCredential>.value(
              MockUserCredential(_mockUser ?? MockUser()),
            ),
          )
          as Future<AppAuthCredential>;

  Future<void> sendPasswordResetEmail({required String email}) =>
      super.noSuchMethod(
            Invocation.method(#sendPasswordResetEmail, const [], {
              #email: email,
            }),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  Future<void> sendVerificationEmail() async {
    await _mockUser?.sendEmailVerification();
  }

  Future<void> signOut() =>
      super.noSuchMethod(
            Invocation.method(#signOut, const []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;
}

extension on Stream<AppAuthUser?> {
  Stream<AppAuthUser?> startWith(AppAuthUser? initialValue) async* {
    yield initialValue;
    yield* this;
  }
}

class MockUserCredential extends AppAuthCredential {
  MockUserCredential([AppAuthUser? user]) : super(user: user ?? MockUser());
}

class MockUser extends AppAuthUser {
  MockUser({
    String uid = 'mock-user-id',
    String? email,
    bool emailVerified = false,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    List<AppAuthProviderData>? providerData,
  }) : sendVerificationShouldFail = false,
       sendVerificationError = null,
       super(
         uid: uid,
         email: email,
         phoneNumber: phoneNumber ?? '9999988888',
         displayName: displayName,
         photoURL: photoURL,
         emailVerified: emailVerified,
         providerData: providerData ?? const [],
         tokenProvider: () => 'mock-supabase-access-token',
         reloadProvider: () async {},
       );

  bool sendVerificationShouldFail;
  String? sendVerificationError;

  void setEmailVerified({required bool isEmailVerified}) {
    emailVerified = isEmailVerified;
  }

  Future<void> sendEmailVerification() async {
    if (sendVerificationShouldFail) {
      throw AuthException(
        code: 'too-many-requests',
        message: sendVerificationError ?? 'Failed to send verification',
      );
    }
  }
}

class FakeAuthCredential extends Fake {}

class MockGoogleSignInAccount extends Mock {
  MockGoogleSignInAccount({
    this.email = 'google@example.com',
    this.idToken = 'mock-id-token',
  });

  final String email;
  final String idToken;
  String get displayName => 'Mock User';
  String get id => 'mock-user-id';
}

class MockGoogleSignIn extends Mock {
  bool _isCancelled = false;
  bool _shouldFail = false;

  void setIsCancelled({required bool value}) => _isCancelled = value;
  void setShouldFail({required bool value}) => _shouldFail = value;

  Future<MockGoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    if (_shouldFail) throw Exception('Google sign-in failed');
    if (_isCancelled) throw Exception('User cancelled');
    return MockGoogleSignInAccount();
  }

  Future<void> signOut() async {}
}

class MockSupabaseAuthService extends Mock implements SupabaseAuthService {}
