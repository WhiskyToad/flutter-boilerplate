import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/presentation/signup/bloc/signup_bloc.dart';
import 'package:skelter/presentation/signup/bloc/signup_event.dart';
import 'package:skelter/presentation/signup/bloc/signup_state.dart';
import 'package:skelter/services/firebase_auth_services.dart';
import 'package:skelter/services/performance_monitoring_service.dart';

import '../../../test_helpers.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late SignupBloc bloc;
  late MockAppLocalizations mockLocalizations;
  late MockFirebaseAuthService mockFirebaseAuthService;
  late MockPerformanceMonitoringService mockPerformanceService;

  setUp(() {
    mockLocalizations = MockAppLocalizations();
    mockFirebaseAuthService = MockFirebaseAuthService();
    mockPerformanceService = MockPerformanceMonitoringService();

    when(
      () => mockLocalizations.error_enter_confirm_password,
    ).thenReturn('Enter confirm password');
    when(
      () => mockLocalizations.passwords_do_not_match,
    ).thenReturn('Passwords do not match');
    when(
      () => mockLocalizations.opps_something_went_wrong,
    ).thenReturn('Oops! Something went wrong');

    final sl = GetIt.instance;
    if (sl.isRegistered<FirebaseAuthService>()) {
      sl.unregister<FirebaseAuthService>();
    }
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<FirebaseAuthService>(mockFirebaseAuthService);
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    bloc = SignupBloc(localizations: mockLocalizations);
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<FirebaseAuthService>()) {
      sl.unregister<FirebaseAuthService>();
    }
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('SignupBloc', () {
    test('initial state should have empty fields', () {
      expect(bloc.state.email, isEmpty);
      expect(bloc.state.password, isEmpty);
      expect(bloc.state.confirmPassword, isEmpty);
      expect(bloc.state.isPasswordVisible, isFalse);
      expect(bloc.state.isConfirmPasswordVisible, isFalse);
      expect(bloc.state.passwordStrengthLevel, equals(0));
      expect(bloc.state.isLoading, isFalse);
    });

    group('SignupEmailChangeEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should update email',
        build: () => bloc,
        act: (bloc) => bloc.add(SignupEmailChangeEvent(email: 'test@test.com')),
        expect: () => [
          isA<SignupState>().having((s) => s.email, 'email', 'test@test.com'),
        ],
      );
    });

    group('SignupEmailErrorEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should set email error',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(SignupEmailErrorEvent(errorMessage: 'Invalid email')),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.emailErrorMessage,
            'emailError',
            'Invalid email',
          ),
        ],
      );
    });

    group('SignupPasswordChangeEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should update password and strength for weak password',
        build: () => bloc,
        act: (bloc) => bloc.add(SignupPasswordChangeEvent(password: 'abc')),
        expect: () => [
          isA<SignupState>()
              .having((s) => s.password, 'password', 'abc')
              .having(
                (s) => s.isPasswordLongEnough,
                'isPasswordLongEnough',
                false,
              )
              .having((s) => s.passwordStrengthLevel, 'strengthLevel', 0),
        ],
      );

      blocTest<SignupBloc, SignupState>(
        'should update password and strength for strong password',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(SignupPasswordChangeEvent(password: 'MyPassword1!')),
        expect: () => [
          isA<SignupState>()
              .having((s) => s.password, 'password', 'MyPassword1!')
              .having(
                (s) => s.isPasswordLongEnough,
                'isPasswordLongEnough',
                true,
              )
              .having(
                (s) => s.hasLetterAndNumberInPassword,
                'hasLetterAndNumber',
                true,
              )
              .having(
                (s) => s.hasSpecialCharacterInPassword,
                'hasSpecialChar',
                true,
              )
              .having((s) => s.passwordStrengthLevel, 'strengthLevel', 3),
        ],
      );

      blocTest<SignupBloc, SignupState>(
        'should detect medium strength password',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(SignupPasswordChangeEvent(password: 'password1')),
        expect: () => [
          isA<SignupState>()
              .having(
                (s) => s.isPasswordLongEnough,
                'isPasswordLongEnough',
                true,
              )
              .having(
                (s) => s.hasLetterAndNumberInPassword,
                'hasLetterAndNumber',
                true,
              )
              .having(
                (s) => s.hasSpecialCharacterInPassword,
                'hasSpecialChar',
                false,
              )
              .having((s) => s.passwordStrengthLevel, 'strengthLevel', 2),
        ],
      );
    });

    group('ConfirmPasswordChangeEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should update confirm password',
        build: () => bloc,
        act: (bloc) => bloc.add(
          ConfirmPasswordChangeEvent(confirmPassword: 'MyPassword1!'),
        ),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.confirmPassword,
            'confirmPassword',
            'MyPassword1!',
          ),
        ],
      );
    });

    group('ConfirmPasswordErrorEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should set confirm password error',
        build: () => bloc,
        act: (bloc) => bloc.add(
          ConfirmPasswordErrorEvent(errorMessage: 'Passwords do not match'),
        ),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.confirmPasswordErrorMessage,
            'confirmPasswordError',
            'Passwords do not match',
          ),
        ],
      );
    });

    group('TogglePasswordVisibilityEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should toggle password visibility to true',
        build: () => bloc,
        act: (bloc) => bloc.add(TogglePasswordVisibilityEvent(isVisible: true)),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.isPasswordVisible,
            'isPasswordVisible',
            true,
          ),
        ],
      );

      blocTest<SignupBloc, SignupState>(
        'should toggle password visibility to false',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(TogglePasswordVisibilityEvent(isVisible: false)),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.isPasswordVisible,
            'isPasswordVisible',
            false,
          ),
        ],
      );
    });

    group('ToggleConfirmPasswordVisibilityEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should toggle confirm password visibility',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(ToggleConfirmPasswordVisibilityEvent(isVisible: true)),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.isConfirmPasswordVisible,
            'isConfirmPasswordVisible',
            true,
          ),
        ],
      );
    });

    group('UpdatePasswordStrengthEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should update password strength level',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(UpdatePasswordStrengthEvent(passwordStrengthLevel: 2)),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.passwordStrengthLevel,
            'passwordStrengthLevel',
            2,
          ),
        ],
      );
    });

    group('ProfilePictureDoneToggleEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should toggle profile picture done editing',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(ProfilePictureDoneToggleEvent(isDoneEditing: true)),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.isDoneProfilePicEditing,
            'isDoneProfilePicEditing',
            true,
          ),
        ],
      );
    });

    group('RemoveProfilePictureEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should set profile picture to null',
        build: () => bloc,
        act: (bloc) => bloc.add(RemoveProfilePictureEvent()),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.selectedProfilePicture,
            'selectedProfilePicture',
            isNull,
          ),
        ],
      );
    });

    group('ResendVerificationEmailTimeLeftEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should update resend time left',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(ResendVerificationEmailTimeLeftEvent(resendTimeLeft: 25)),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.resendVerificationEmailTimeLeft,
            'resendTimeLeft',
            25,
          ),
        ],
      );
    });

    group('ResetPasswordStateEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should reset password fields',
        build: () => bloc,
        act: (bloc) => bloc.add(ResetPasswordStateEvent()),
        expect: () => [
          isA<SignupState>()
              .having((s) => s.password, 'password', '')
              .having((s) => s.confirmPassword, 'confirmPassword', '')
              .having((s) => s.isPasswordVisible, 'isPasswordVisible', false)
              .having(
                (s) => s.isConfirmPasswordVisible,
                'isConfirmPasswordVisible',
                false,
              )
              .having(
                (s) => s.passwordStrengthLevel,
                'passwordStrengthLevel',
                0,
              ),
        ],
      );
    });

    group('CheckEmailAvailabilityEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should emit loading false then navigate to create password',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(CheckEmailAvailabilityEvent(email: 'test@test.com')),
        expect: () => [
          isA<SignupLoadingState>(),
          isA<NavigateToCreatePasswordState>(),
        ],
      );
    });

    group('AuthenticationExceptionEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should emit error message and AuthenticationExceptionState',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(AuthenticationExceptionEvent(errorMessage: 'Auth failed')),
        expect: () => [
          isA<SignupState>().having(
            (s) => s.authenticationErrorMessage,
            'errorMessage',
            'Auth failed',
          ),
          isA<AuthenticationExceptionState>(),
        ],
      );
    });

    group('EmailSignUpLoadingEvent', () {
      blocTest<SignupBloc, SignupState>(
        'should emit EmailSignUpLoadingState with isLoading true',
        build: () => bloc,
        act: (bloc) => bloc.add(EmailSignUpLoadingEvent(isLoading: true)),
        expect: () => [isA<EmailSignUpLoadingState>()],
      );
    });
  });
}
