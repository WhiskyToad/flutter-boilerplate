import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/biometric_auth/bloc/biometric_auth_bloc.dart';
import 'package:skelter/presentation/biometric_auth/bloc/biometric_auth_event.dart';
import 'package:skelter/presentation/biometric_auth/bloc/biometric_auth_state.dart';
import 'package:skelter/services/local_auth_services.dart';

class MockLocalAuthService extends Mock implements LocalAuthService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late BiometricAuthBloc bloc;
  late MockLocalAuthService mockLocalAuthService;
  late MockAppLocalizations mockLocalizations;

  setUpAll(() {
    registerFallbackValue(MockAppLocalizations());
  });

  setUp(() {
    mockLocalAuthService = MockLocalAuthService();
    mockLocalizations = MockAppLocalizations();

    final sl = GetIt.instance;
    if (sl.isRegistered<LocalAuthService>()) {
      sl.unregister<LocalAuthService>();
    }
    sl.registerSingleton<LocalAuthService>(mockLocalAuthService);

    bloc = BiometricAuthBloc(localizations: mockLocalizations);
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<LocalAuthService>()) {
      sl.unregister<LocalAuthService>();
    }
  });

  group('BiometricAuthBloc', () {
    test('initial state should have biometric not enrolled', () {
      expect(bloc.state.isBiometricEnrolled, isFalse);
      expect(bloc.state.isBiometricSupported, isFalse);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.errorMessage, isNull);
    });

    group('BiometricAuthToggleEvent - enable', () {
      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit not supported state when biometric not supported',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenAnswer((_) async => BiometricAuthStatus.notSupported);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: true)),
        expect: () => [isA<IsBiometricAuthNotSupportedState>()],
      );

      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit too many attempts state',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenAnswer((_) async => BiometricAuthStatus.tooManyAttempts);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: true)),
        expect: () => [isA<BioMetricsTooManyAttemptState>()],
      );

      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit not enrolled state when not enrolled',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenAnswer((_) async => BiometricAuthStatus.notEnrolled);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: true)),
        expect: () => [isA<BiometricAuthNotEnrolledState>()],
      );

      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit disabled and failure on cancelled auth',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenAnswer((_) async => BiometricAuthStatus.cancelled);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: true)),
        expect: () => [
          isA<IsBiometricAuthEnabledState>().having(
            (s) => s.isBiometricEnrolled,
            'isBiometricEnrolled',
            false,
          ),
          isA<BiometricAuthFailureState>(),
        ],
      );
    });

    group('BiometricAuthToggleEvent - disable', () {
      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit too many attempts when disabling',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenAnswer((_) async => BiometricAuthStatus.tooManyAttempts);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: false)),
        expect: () => [isA<BioMetricsTooManyAttemptState>()],
      );

      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit failure on failed auth for disable',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenAnswer((_) async => BiometricAuthStatus.error);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: false)),
        expect: () => [isA<BiometricAuthFailureState>()],
      );
    });

    group('BiometricAuthToggleEvent - error handling', () {
      blocTest<BiometricAuthBloc, BiometricAuthState>(
        'should emit failure state when exception is thrown',
        build: () {
          when(
            () => mockLocalAuthService.authenticate(any()),
          ).thenThrow(Exception('Auth error'));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const BiometricAuthToggleEvent(isBiometricEnabled: true)),
        expect: () => [
          isA<BiometricAuthState>().having(
            (s) => s.isBiometricEnrolled,
            'isBiometricEnrolled',
            false,
          ),
          isA<BiometricAuthFailureState>(),
        ],
      );
    });
  });
}
