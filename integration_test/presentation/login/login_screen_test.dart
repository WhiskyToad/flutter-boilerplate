import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol/patrol.dart';
import 'package:skelter/constants/integration_test_keys.dart';
import 'package:skelter/initialize_app.dart';
import 'package:skelter/main.dart';

import '../../demo_product_response.dart';
import '../../mock_supabase_auth.dart';

class MockDio extends Mock implements Dio {}

class MockDioResponse<T> extends Mock implements Response<T> {}

void main() {
  final mockAuth = MockSupabaseAuth();
  final mockGoogleSignIn = MockGoogleSignIn();
  final mockDio = MockDio();

  setUpAll(() {
    // NOTE:
    // Mocktail requires a fallback value for non-primitive parameters
    // when using `any()` or `captureAny()` in `when()` / `verify()`.
    // App auth credential fallback, so we register a Fake
    // to prevent "No fallback value registered" runtime errors in tests.
    registerFallbackValue(FakeAuthCredential());
    final mockResponse = MockDioResponse<List<dynamic>>();

    when(() => mockResponse.statusCode).thenReturn(200);
    when(() => mockResponse.data).thenReturn(productsResponse);
    when(
      () => mockDio.get(
        any(),
        options: any(named: 'options'), // ignore the CacheOptions in test
      ),
    ).thenAnswer((_) async => mockResponse);
    when(() => mockDio.interceptors).thenReturn(Interceptors());
  });

  patrolTest(
    'open app, login with mobile number, verify products are displayed',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      await initializeApp(authAdapter: mockAuth, dio: mockDio);
      await $.pumpWidgetAndSettle(const MainApp());

      when(() => mockAuth.signInWithCredential(any())).thenAnswer((
        _,
      ) async {
        final phoneUser = MockUser(
          phoneNumber: '9999988888',
          email: 'phone@example.com',
        );
        mockAuth.setMockUser(phoneUser);
        return MockUserCredential(phoneUser);
      });

      await $(keys.signInPage.mobileNoTextField).enterText('9999988888');
      await $(keys.signInPage.sendOTPButton).tap();
      await $.pumpAndSettle();
      expect(find.text('Invalid mobile number'), findsNothing);

      await $(keys.signInPage.otpTextField).waitUntilVisible();
      await $(keys.signInPage.otpTextField).enterText('123456');

      await $.pumpAndSettle();

      expect(find.text('Premium Wireless Headphones'), findsOneWidget);
      expect(find.text('Smart Fitness Watch'), findsOneWidget);
      expect(find.byKey(keys.homePage.productCardKey), findsExactly(2));

      await $(TablerIcons.user).tap();
      await $.pumpAndSettle();
      await $('Sign out').scrollTo().tap();
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'login with email and password test',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      // Initialise the App
      await initializeApp(
        authAdapter: mockAuth,
        googleSignIn: mockGoogleSignIn,
        dio: mockDio,
      );

      // Stub signOut to reset mock state
      when(() => mockAuth.signOut()).thenAnswer((_) async {
        mockAuth.setMockUser(null);
      });

      await $.pumpWidgetAndSettle(const MainApp());

      // Login with email
      final testUser = MockUser(email: 'test@example.com', emailVerified: true);

      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        mockAuth.setMockUser(testUser);
        return MockUserCredential(testUser);
      });

      await $(keys.signInPage.continueWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Login with email'), findsOneWidget);

      await $(keys.signInPage.emailTextField).enterText('test@example.com');
      await $(keys.signInPage.passwordTextField).enterText('password123');
      await $.pump();

      await $(keys.signInPage.loginWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Premium Wireless Headphones'), findsOneWidget);
      expect(find.text('Smart Fitness Watch'), findsOneWidget);
      expect(find.byKey(keys.homePage.productCardKey), findsExactly(2));

      await $(TablerIcons.user).tap();
      await $.pumpAndSettle();
      await $('Sign out').scrollTo().tap();
      await $.pumpAndSettle();

      expect(find.byKey(keys.signInPage.mobileNoTextField), findsOneWidget);

      final unverifiedUser = MockUser(email: 'unverified@example.com');

      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        mockAuth.setMockUser(unverifiedUser);
        return MockUserCredential(unverifiedUser);
      });

      await $(keys.signInPage.continueWithEmailButton).tap();
      await $.pumpAndSettle();

      await $(
        keys.signInPage.emailTextField,
      ).enterText('unverified@example.com');
      await $(keys.signInPage.passwordTextField).enterText('password123');
      await $.pump();

      await $(keys.signInPage.loginWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);

      final NavigatorState navigator = $.tester.state(find.byType(Navigator));
      navigator.pop();
      navigator.pop();
      await $.pump();

      await $(keys.signInPage.continueWithEmailButton).tap();
      await $.pumpAndSettle();

      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        AuthException(
          code: 'wrong-password',
          message: 'The password you entered is incorrect. Please try again.',
        ),
      );

      await $(keys.signInPage.emailTextField).enterText('invalid@example.com');
      await $(keys.signInPage.passwordTextField).enterText('wrongpassword');
      await $.pump();

      await $(keys.signInPage.loginWithEmailButton).tap();
      await $.pumpAndSettle();
      // NOTE:
      // This below test expects the exact AuthException
      // message for ErrorCode - `wrong-password` returned by auth service.
      // Do NOT customize the message, otherwise the test will fail.
      expect(
        find.text('The password you entered is incorrect. Please try again.'),
        findsOneWidget,
      );

      await $(find.byIcon(TablerIcons.arrow_left)).tap();
    },
  );

  patrolTest(
    'sign in with Google test',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      await initializeApp(
        authAdapter: mockAuth,
        googleSignIn: mockGoogleSignIn,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      // Stub signOut to reset mock state
      when(() => mockAuth.signOut()).thenAnswer((_) async {
        mockAuth.setMockUser(null);
      });

      // Ensure Google login is NOT cancelled
      mockGoogleSignIn.setIsCancelled(value: false);

      // Mock Supabase auth signInWithCredential
      when(() => mockAuth.signInWithCredential(any())).thenAnswer((
        _,
      ) async {
        final googleUser = MockUser(
          email: 'google@example.com',
          emailVerified: true,
        );
        mockAuth.setMockUser(googleUser);
        return MockUserCredential(googleUser);
      });

      // Give Flutter a frame before interaction
      await $.pump();
      await $.pump(const Duration(milliseconds: 300));

      // Tap "Continue with Google"
      await $(keys.signInPage.continueWithGoogleButton).tap();
      await $.pumpAndSettle();

      // Assert Home screen loaded
      expect(find.text('Premium Wireless Headphones'), findsOneWidget);
      expect(find.text('Smart Fitness Watch'), findsOneWidget);
      expect(find.byKey(keys.homePage.productCardKey), findsNWidgets(2));

      await $.pumpAndSettle();

      // Sign out
      await $(TablerIcons.user).tap();
      await $.pumpAndSettle();
      await $('Sign out').scrollTo().tap();
      await $.pumpAndSettle();

      // FAILED / CANCELLED GOOGLE LOGIN

      // Simulate user cancelling Google login
      mockGoogleSignIn.setIsCancelled(value: true);

      // Tap "Continue with Google" again
      await $(keys.signInPage.continueWithGoogleButton).tap();
      await $.pumpAndSettle();

      // Assert error message shown
      expect(find.text('Google sign-in failed'), findsOneWidget);
    },
  );
}
