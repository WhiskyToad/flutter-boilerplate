import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/presentation/signup/enum/user_details_input_status.dart';
import 'package:skelter/presentation/verify_email/bloc/verify_email_bloc.dart';
import 'package:skelter/presentation/verify_email/bloc/verify_email_event.dart';
import 'package:skelter/presentation/verify_email/bloc/verify_email_state.dart';
import 'package:skelter/services/supabase_auth_service.dart';

import '../../../test_helpers.dart';

class MockSupabaseAuthService extends Mock implements SupabaseAuthService {}

void main() {
  late VerifyEmailBloc bloc;
  late MockAppLocalizations mockLocalizations;
  late MockSupabaseAuthService mockSupabaseAuthService;

  setUp(() {
    mockLocalizations = MockAppLocalizations();
    mockSupabaseAuthService = MockSupabaseAuthService();

    final sl = GetIt.instance;
    if (sl.isRegistered<SupabaseAuthService>()) {
      sl.unregister<SupabaseAuthService>();
    }
    sl.registerSingleton<SupabaseAuthService>(mockSupabaseAuthService);

    bloc = VerifyEmailBloc(localizations: mockLocalizations);
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<SupabaseAuthService>()) {
      sl.unregister<SupabaseAuthService>();
    }
  });

  group('VerifyEmailBloc', () {
    test('initial state should be VerifyEmailInitialState', () {
      expect(bloc.state, isA<VerifyEmailInitialState>());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isSignUp, isFalse);
    });

    group('InitialEvent', () {
      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should set email and isSignUp',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const InitialEvent(email: 'test@test.com', isSignUp: true),
        ),
        expect: () => [
          isA<VerifyEmailState>()
              .having((s) => s.email, 'email', 'test@test.com')
              .having((s) => s.isSignUp, 'isSignUp', true),
        ],
      );

      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should set isSignUp to false for login flow',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const InitialEvent(email: 'user@test.com', isSignUp: false),
        ),
        expect: () => [
          isA<VerifyEmailState>()
              .having((s) => s.email, 'email', 'user@test.com')
              .having((s) => s.isSignUp, 'isSignUp', false),
        ],
      );
    });

    group('RestartVerificationMailResendTimerEvent', () {
      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should emit RestartVerificationMailResendTimerState',
        build: () => bloc,
        act: (bloc) => bloc.add(RestartVerificationMailResendTimerEvent()),
        expect: () => [isA<RestartVerificationMailResendTimerState>()],
      );
    });

    group('VerificationCodeFailedToSendEvent', () {
      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should emit VerificationCodeFailedToSendState',
        build: () => bloc,
        act: (bloc) => bloc.add(VerificationCodeFailedToSendEvent()),
        expect: () => [isA<VerificationCodeFailedToSendState>()],
      );
    });

    group('ResendVerificationEmailTimeLeftEvent', () {
      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should update resend time left',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const ResendVerificationEmailTimeLeftEvent(resendTimeLeft: 20),
        ),
        expect: () => [
          isA<VerifyEmailState>().having(
            (s) => s.resendTimeLeft,
            'resendTimeLeft',
            20,
          ),
        ],
      );
    });

    group('ChangeUserDetailsInputStatusEvent', () {
      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should set userDetailsInputStatus to inProgress',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const ChangeUserDetailsInputStatusEvent(
            status: UserDetailsInputStatus.inProgress,
          ),
        ),
        expect: () => [
          isA<VerifyEmailState>().having(
            (s) => s.userDetailsInputStatus,
            'status',
            UserDetailsInputStatus.inProgress,
          ),
        ],
      );
    });

    group('NavigateToHomeEvent', () {
      blocTest<VerifyEmailBloc, VerifyEmailState>(
        'should emit NavigateToHomeState',
        build: () => bloc,
        act: (bloc) => bloc.add(NavigateToHomeEvent()),
        expect: () => [isA<NavigateToHomeState>()],
      );
    });
  });
}
