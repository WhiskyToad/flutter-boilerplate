import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/login/bloc/login_events.dart';
import 'package:skelter/presentation/login/bloc/login_state.dart';
import 'package:skelter/presentation/login/models/login_details.dart';
import 'package:skelter/presentation/signup/enum/user_details_input_status.dart';
import 'package:skelter/services/auth/app_auth_models.dart';
import 'package:skelter/services/performance_monitoring_service.dart';
import 'package:skelter/services/supabase_auth_service.dart';
import 'package:skelter/shared_pref/pref_keys.dart';
import 'package:skelter/shared_pref/prefs.dart';
import 'package:skelter/utils/extensions/primitive_types_extensions.dart';
import 'package:skelter/utils/haptic_feedback_util.dart';
import 'package:skelter/validators/validators.dart';

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  static const kMinimumPasswordLength = 8;

  final SupabaseAuthService _authService = sl();
  final PerformanceMonitoringService _performanceService = sl();
  final AppLocalizations localizations;

  LoginBloc({required this.localizations}) : super(LoginState.initial()) {
    _setupEventListener();
  }

  void _setupEventListener() {
    on<EnableSignupModeEvent>(_onEnableSignupModeEvent);
    on<PhoneInputHasFocus>(_onUpdatePhoneInputHasFocusEvent);
    on<IsPhoneNumValidEvent>(_onUpdateIsPhoneNumValidEvent);
    on<CountryCodeChangeEvent>(_onUpdateCountryCodeChangeEvent);
    on<PhoneNumChangeEvent>(_onPhoneNumChangeEvent);
    on<NavigateToEmailVerifyScreenEvent>(_onNavigateToEmailVerifyScreenEvent);
    on<PhoneNumErrorEvent>(_onPhoneNumErrorEvent);
    on<PhoneOtpTextChangeEvent>(_onPhoneOtpTextChangeEvent);
    on<PhoneOtpErrorEvent>(_onPhoneOtpErrorEvent);
    on<IsResendOTPEnabledEvent>(_onIsResendOTPEnabledEvent);
    on<ResendOTPTimeLeftEvent>(_onResendOTPTimeLeftEvent);
    on<NavigateToOtpEvent>(_onNavigateToOtpEvent);
    on<SupabasePhoneLoginEvent>(_onSupabasePhoneLoginEvent);
    on<SupabaseOTPVerificationEvent>(_onSupabaseOTPVerificationEvent);
    on<SupabaseOTPAutoVerificationEvent>(_onSupabaseOTPAutoVerificationEvent);
    on<NavigateToHomeScreenEvent>(_onNavigateToHomeScreenEvent);
    on<EmailChangeEvent>(_onEmailChangeEvent);
    on<EmailErrorEvent>(_onEmailErrorEvent);
    on<PasswordChangeEvent>(_onPasswordChangeEvent);
    on<PasswordErrorEvent>(_onPasswordErrorEvent);
    on<IsPasswordVisibleEvent>(_onIsPasswordVisibleEvent);
    on<EmailPasswordLoginEvent>(_onEmailPasswordLoginEvent);
    on<AuthenticationExceptionEvent>(_onAuthenticationExceptionEvent);
    on<CompleteOnboardingEvent>(_onCompleteOnboardingEvent);
    on<ForgotPasswordEvent>(_onForgotPasswordEvent);
    on<ResetPasswordLinkSentEvent>(_onResetPasswordLinkSentEvent);
    on<LoginWithGoogleEvent>(_onLoginWithGoogleSSOEvent);
    on<LoginWithAppleEvent>(_onLoginWithAppleSSOEvent);
    on<PhoneNumLoginLoadingEvent>(_onPhoneNumberLoadingEvent);
    on<EmailLoginLoadingEvent>(_onEmailLoginLoadingEvent);
    on<ResetEmailStateEvent>(_onResetEmailStateEvent);
    on<ResetPhoneNumberStateEvent>(_onResetPhoneNumberStateEvent);
    on<NavigateToVerifiedScreenEvent>(_onNavigateToVerifiedScreenEvent);

    on<SendEmailVerificationLinkEvent>(_onSendEmailVerificationLinkEvent);

    on<RestartVerificationMailResendTimerEvent>(
      _onRestartVerificationMailResendTimerEvent,
    );
    on<VerificationCodeFailedToSendEvent>(_onVerificationCodeFailedToSendEvent);
    on<LoginWithPhoneNumEvent>(_onLoginWithPhoneNumEvent);
    on<ChangeUserDetailsInputStatusEvent>(_onChangeUserDetailsInputStatusEvent);
    on<SelectLoginSignupTypeEvent>(_onSelectLoginSignupTypeEvent);
  }

  void _onSelectLoginSignupTypeEvent(
    SelectLoginSignupTypeEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(selectedLoginType: event.selectedType));
  }

  void _onEnableSignupModeEvent(EnableSignupModeEvent event, Emitter emit) {
    emit(state.copyWith(isSignup: event.isSignup));
  }

  void _onUpdatePhoneInputHasFocusEvent(
    PhoneInputHasFocus event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneInputHasFocus: event.hasFocus,
        ),
      ),
    );
  }

  void _onUpdateIsPhoneNumValidEvent(IsPhoneNumValidEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          isPhoneNumValid: event.isValid,
        ),
      ),
    );
  }

  void _onUpdateCountryCodeChangeEvent(
    CountryCodeChangeEvent event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          countryCode: event.countryCode,
        ),
      ),
    );
  }

  void _onPhoneNumChangeEvent(PhoneNumChangeEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneNumber: event.phoneNumber,
        ),
      ),
    );
  }

  void _onPhoneNumErrorEvent(PhoneNumErrorEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneNumErrorMessage: event.errorMessage,
        ),
      ),
    );
  }

  void _onPhoneOtpTextChangeEvent(PhoneOtpTextChangeEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneOTPText: event.phoneOtpText,
        ),
      ),
    );
  }

  void _onPhoneOtpErrorEvent(PhoneOtpErrorEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneOTPErrorMessage: event.errorMessage,
          canSetOTPErrorMessageToNull: true,
        ),
      ),
    );
  }

  void _onIsResendOTPEnabledEvent(IsResendOTPEnabledEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          isResendOTPEnabled: event.isResendOTPEnabled,
        ),
      ),
    );
  }

  void _onResendOTPTimeLeftEvent(ResendOTPTimeLeftEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          resendOTPTimeLeft: event.resentOTPTimeLeft,
        ),
      ),
    );
  }

  void _onNavigateToOtpEvent(NavigateToOtpEvent event, Emitter emit) {
    emit(
      NavigateToOTPScreenState(
        state,
        phoneOTPVerificationId: event.verificationId,
      ),
    );
  }

  void _onNavigateToHomeScreenEvent(
    NavigateToHomeScreenEvent event,
    Emitter emit,
  ) {
    emit(NavigateToHomeScreenState(state));
  }

  Future<void> _onSupabasePhoneLoginEvent(
    SupabasePhoneLoginEvent event,
    Emitter emit,
  ) async {
    await _supabaseVerifyAndOpenOtpScreenOnCodeSent(
      isFromVerificationScreen: event.isFromVerificationScreen,
    );
  }

  Future<void> _onSupabaseOTPVerificationEvent(
    SupabaseOTPVerificationEvent event,
    Emitter emit,
  ) async {
    await _supabaseOTPVerification();
  }

  void _onSupabaseOTPAutoVerificationEvent(
    SupabaseOTPAutoVerificationEvent event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(SupabaseOTPAutoVerificationState(phoneNumberLoginState));
  }

  void _onEmailChangeEvent(EmailChangeEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          email: event.email,
        ),
      ),
    );
  }

  void _onEmailErrorEvent(EmailErrorEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          emailErrorMessage: event.errorMessage,
          canSetEmailErrorMessageToNull: true,
        ),
      ),
    );
  }

  void _onPasswordChangeEvent(PasswordChangeEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          password: event.password,
        ),
      ),
    );
  }

  void _onPasswordErrorEvent(PasswordErrorEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          passwordErrorMessage: event.errorMessage,
          canSetPasswordErrorMessageToNull: true,
        ),
      ),
    );
  }

  void _onIsPasswordVisibleEvent(IsPasswordVisibleEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          isPasswordVisible: event.isPasswordVisible,
        ),
      ),
    );
  }

  Future<void> _onEmailPasswordLoginEvent(
    EmailPasswordLoginEvent event,
    Emitter emit,
  ) async {
    await _loginUsingEmailAndPassword();
  }

  void _onAuthenticationExceptionEvent(
    AuthenticationExceptionEvent event,
    Emitter emit,
  ) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          authenticationErrorMessage: event.errorMessage,
        ),
        isLoading: false,
      ),
    );
    emit(AuthenticationExceptionState(state));
  }

  Future<void> _onCompleteOnboardingEvent(
    CompleteOnboardingEvent event,
    Emitter emit,
  ) async {
    await Prefs.setBool(PrefKeys.kHasCompletedOnboarding, value: true);
    add(ChangeUserDetailsInputStatusEvent(UserDetailsInputStatus.done));
    add(NavigateToHomeScreenEvent());
  }

  Future<void> _onForgotPasswordEvent(
    ForgotPasswordEvent event,
    Emitter emit,
  ) async {
    await _sendPasswordResetLink();
  }

  void _onResetPasswordLinkSentEvent(
    ResetPasswordLinkSentEvent event,
    Emitter emit,
  ) {
    emit(ResetPasswordLinkSentState(state));
  }

  Future<void> _onLoginWithGoogleSSOEvent(
    LoginWithGoogleEvent event,
    Emitter emit,
  ) async {
    await _loginWithGoogle();
  }

  Future<void> _onLoginWithAppleSSOEvent(
    LoginWithAppleEvent event,
    Emitter emit,
  ) async {
    await _loginWithApple();
  }

  void _onPhoneNumberLoadingEvent(
    PhoneNumLoginLoadingEvent event,
    Emitter emit,
  ) {
    emit(PhoneNumLoginLoadingState(state, isLoading: event.isLoading));
  }

  void _onEmailLoginLoadingEvent(EmailLoginLoadingEvent event, Emitter emit) {
    emit(EmailLoginLoadingState(state, isLoading: event.isLoading));
  }

  void _onResetEmailStateEvent(ResetEmailStateEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        EmailPasswordLoginState.initial();
    emit(state.copyWith(emailPasswordLoginState: emailPasswordLoginState));
    emit(EmailLoginLoadingState(state, isLoading: false));
    emit(ClearLoginWithEmailControllerState(state));
  }

  void _onResetPhoneNumberStateEvent(
    ResetPhoneNumberStateEvent event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        PhoneNumberLoginState.initial();
    emit(state.copyWith(phoneNumberLoginState: phoneNumberLoginState));
    emit(PhoneNumLoginLoadingState(state, isLoading: false));
  }

  void _onNavigateToVerifiedScreenEvent(
    NavigateToVerifiedScreenEvent event,
    Emitter emit,
  ) {
    emit(
      NavigateToVerifiedScreenState(
        state.copyWith(
          userDetailsInputStatus: UserDetailsInputStatus.inProgress,
        ),
      ),
    );
  }

  void _onSendEmailVerificationLinkEvent(
    SendEmailVerificationLinkEvent event,
    Emitter emit,
  ) async {
    add(EmailLoginLoadingEvent(isLoading: true));
    await _authService.sendVerificationEmail(
      onError: (errorMessage, {stackTrace}) {
        add(EmailLoginLoadingEvent(isLoading: false));
        add(AuthenticationExceptionEvent(errorMessage: errorMessage));
      },
    );
    add(EmailLoginLoadingEvent(isLoading: false));
    add(RestartVerificationMailResendTimerEvent());
  }

  void _onRestartVerificationMailResendTimerEvent(
    RestartVerificationMailResendTimerEvent event,
    Emitter emit,
  ) {
    emit(RestartVerificationMailResendTimerState(state));
  }

  void _onVerificationCodeFailedToSendEvent(
    VerificationCodeFailedToSendEvent event,
    Emitter emit,
  ) {
    emit(VerificationCodeFailedToSendState(state));
  }

  Future<void> _onLoginWithPhoneNumEvent(
    LoginWithPhoneNumEvent event,
    Emitter emit,
  ) async {
    add(PhoneNumLoginLoadingEvent(isLoading: true));
    final isPhoneNumValid = await isPhoneNumberValid(event.phoneNumberWithCode);

    if (!isPhoneNumValid) {
      final phoneNumberLoginState =
          state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();

      emit(
        state.copyWith(
          phoneNumberLoginState: phoneNumberLoginState.copyWith(
            phoneNumErrorMessage: localizations.invalid_mobile_number,
          ),
        ),
      );
      add(PhoneNumLoginLoadingEvent(isLoading: false));
      return;
    }
    add(SupabasePhoneLoginEvent(isFromVerificationScreen: false));
  }

  void _onChangeUserDetailsInputStatusEvent(
    ChangeUserDetailsInputStatusEvent event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(userDetailsInputStatus: UserDetailsInputStatus.inProgress),
    );
  }

  void hideAllLoadingsAndShowError() {
    add(PhoneNumLoginLoadingEvent(isLoading: false));
    add(EmailLoginLoadingEvent(isLoading: false));
    add(
      AuthenticationExceptionEvent(
        errorMessage: localizations.opps_something_went_wrong,
      ),
    );
  }

  Future<void> _supabaseVerifyAndOpenOtpScreenOnCodeSent({
    required bool isFromVerificationScreen,
  }) async {
    add(PhoneNumLoginLoadingEvent(isLoading: !isFromVerificationScreen));

    await _authService.sendPhoneOtp(
      phoneNumber: state.phoneNumberLoginState?.phoneNumber ?? '',
      verificationCompleted: (credential) {
        debugPrint('Supabase phone number verified ${credential.smsCode}');
      },
      codeSent: (verificationId) {
        add(PhoneNumLoginLoadingEvent(isLoading: false));
        if (!isFromVerificationScreen) {
          add(NavigateToOtpEvent(verificationId: verificationId));
        }
      },
      codeAutoRetrievalTimeout: (_) {},
      onError: (error, {stackTrace}) {
        add(PhoneNumErrorEvent(errorMessage: error));
        add(PhoneNumLoginLoadingEvent(isLoading: false));
      },
    );
  }

  Future<void> _supabaseOTPVerification() async {
    _performanceService.startTrace(kTraceLoginPhone);
    add(PhoneNumLoginLoadingEvent(isLoading: true));

    final credential = _authService.getPhoneAuthCredential(
      verificationId: state.phoneOTPVerificationId,
      smsCode: state.phoneNumberLoginState?.phoneOTPText ?? '',
    );

    final authCredential = await _authService
        .signInWithPhoneAuthCredential(
          credential,
          onError: (error, {stackTrace}) {
            _performanceService.putAttribute(
              kTraceLoginPhone,
              kTraceAttrError,
              error.truncate(100),
            );
            add(PhoneNumLoginLoadingEvent(isLoading: false));
            add(PhoneOtpErrorEvent(errorMessage: error));
          },
        );

    if (authCredential != null && authCredential.user != null) {
      _performanceService.putAttribute(
        kTraceLoginPhone,
        kTraceAttrSuccess,
        true,
      );
      if (state.isSignup) {
        await _storeLoginDetailsInPrefs(authCredential.user!);
        await HapticFeedbackUtil.success();
        add(NavigateToVerifiedScreenEvent());
      } else {
        await handleUserDetails(
          authCredential.user,
          onError: (error) {
            add(AuthenticationExceptionEvent(errorMessage: error));
          },
        );
      }
    }
    add(PhoneNumLoginLoadingEvent(isLoading: false));
    _performanceService.stopTrace(kTraceLoginPhone);
  }

  Future<void> _loginUsingEmailAndPassword() async {
    _performanceService.startTrace(kTraceLoginEmailPassword);
    add(EmailLoginLoadingEvent(isLoading: true));
    final email = state.emailPasswordLoginState?.email ?? '';
    final password = state.emailPasswordLoginState?.password ?? '';

    final authCredential = await _authService
        .signInWithEmailAndPassword(
          email,
          password,
          onError: (error, {stackTrace}) {
            _performanceService.putAttribute(
              kTraceLoginEmailPassword,
              kTraceAttrError,
              error.truncate(100),
            );
            add(EmailLoginLoadingEvent(isLoading: false));
            add(AuthenticationExceptionEvent(errorMessage: error));
          },
        );

    if (authCredential != null) {
      _performanceService.putAttribute(
        kTraceLoginEmailPassword,
        kTraceAttrSuccess,
        true,
      );
      await handleUserDetails(
        authCredential.user,
        onError: (error) =>
            add(AuthenticationExceptionEvent(errorMessage: error)),
      );
    }
    add(EmailLoginLoadingEvent(isLoading: false));
    _performanceService.stopTrace(kTraceLoginEmailPassword);
  }

  Future<void> _loginWithGoogle() async {
    _performanceService.startTrace(kTraceLoginGoogle);
    final authCredential = await _authService.loginWithGoogle(
      onError: (error, {stackTrace}) {
        _performanceService.putAttribute(
          kTraceLoginGoogle,
          kTraceAttrError,
          error.truncate(100),
        );
        add(AuthenticationExceptionEvent(errorMessage: error));
      },
    );

    if (authCredential != null) {
      _performanceService.putAttribute(
        kTraceLoginGoogle,
        kTraceAttrSuccess,
        true,
      );
      await handleUserDetails(
        authCredential.user,
        onError: (error) =>
            add(AuthenticationExceptionEvent(errorMessage: error)),
      );
    }
    _performanceService.stopTrace(kTraceLoginGoogle);
  }

  Future<void> _loginWithApple() async {
    _performanceService.startTrace(kTraceLoginApple);
    final authCredential = await _authService.loginWithApple(
      onError: (error, {stackTrace}) {
        _performanceService.putAttribute(
          kTraceLoginApple,
          kTraceAttrError,
          error.truncate(100),
        );
        add(AuthenticationExceptionEvent(errorMessage: error));
      },
    );
    if (authCredential != null) {
      _performanceService.putAttribute(
        kTraceLoginApple,
        kTraceAttrSuccess,
        true,
      );
      await handleUserDetails(
        authCredential.user,
        onError: (error) =>
            add(AuthenticationExceptionEvent(errorMessage: error)),
      );
    }
    _performanceService.stopTrace(kTraceLoginApple);
  }

  Future<void> _sendPasswordResetLink() async {
    add(EmailLoginLoadingEvent(isLoading: true));
    await _authService.sendPasswordResetEmail(
      state.emailPasswordLoginState?.email ?? '',
      onError: (error, {stackTrace}) =>
          add(EmailErrorEvent(errorMessage: error)),
    );
    add(EmailLoginLoadingEvent(isLoading: false));
    add(ResetPasswordLinkSentEvent());
  }

  Future<void> handleUserDetails(
    AppAuthUser? authUser, {
    required Function(String) onError,
  }) async {
    final loginType = state.selectedLoginType;
    if (authUser == null) {
      debugPrint('authUser is null');
      onError('User information could not be retrieved.');
      return;
    }
    if (loginType == .PHONE) {
      if (authUser.phoneNumber?.isNullOrEmpty() ?? true) {
        debugPrint('Authentication Current user phone number is null');

        onError('Error retrieving your phone number');
        return;
      }

      await _storeLoginDetailsInPrefs(authUser);
      add(PhoneNumLoginLoadingEvent(isLoading: false));
      add(NavigateToHomeScreenEvent());
    } else if (loginType == .EMAIL) {
      if (authUser.email.isNullOrEmpty()) {
        onError('Error retrieving your email');
        return;
      }
      add(EmailLoginLoadingEvent(isLoading: false));
      if (!authUser.emailVerified) {
        add(SendEmailVerificationLinkEvent());
        add(NavigateToEmailVerifyScreenEvent());
        return;
      }

      await _storeLoginDetailsInPrefs(authUser);
      add(NavigateToHomeScreenEvent());
    } else if (loginType == .GOOGLE) {
      await _storeLoginDetailsInPrefs(authUser);
      add(NavigateToHomeScreenEvent());
    } else if (loginType == .APPLE) {
      await _storeLoginDetailsInPrefs(authUser);
      add(NavigateToHomeScreenEvent());
    } else {
      debugPrint('Login/Signup type not specified');
      hideAllLoadingsAndShowError();
    }
  }

  Future<void> _storeLoginDetailsInPrefs(AppAuthUser authUser) async {
    final loginDetails = LoginDetails(
      uid: authUser.uid,
      token: await authUser.getIdToken(),
      phoneNumber: authUser.phoneNumber,
      email: authUser.email,
    );
    await Prefs.setString(
      PrefKeys.kUserDetails,
      json.encode(loginDetails.toJson()),
    );
  }

  void _onNavigateToEmailVerifyScreenEvent(
    NavigateToEmailVerifyScreenEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(NavigateToEmailVerifyScreenState(state));
  }
}
