import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/chat/domain/usecases/create_chat_user_document.dart';
import 'package:skelter/presentation/login/enum/enum_login_type.dart';
import 'package:skelter/presentation/login/models/login_details.dart';
import 'package:skelter/presentation/signup/bloc/signup_event.dart';
import 'package:skelter/presentation/signup/bloc/signup_state.dart';
import 'package:skelter/presentation/signup/enum/user_details_input_status.dart';
import 'package:skelter/services/auth/app_auth_models.dart';
import 'package:skelter/services/performance_monitoring_service.dart';
import 'package:skelter/services/supabase_auth_service.dart';
import 'package:skelter/shared_pref/pref_keys.dart';
import 'package:skelter/shared_pref/prefs.dart';
import 'package:skelter/utils/extensions/primitive_types_extensions.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  static const kMinimumPasswordLength = 8;

  final SupabaseAuthService _authService = sl();
  final PerformanceMonitoringService _performanceService = sl();
  final AppLocalizations localizations;

  SignupBloc({required this.localizations}) : super(SignupState.initial()) {
    _setupEventListener();
  }

  void _setupEventListener() {
    on<SelectedProfilePictureEvent>(_onSelectedProfilePictureEvent);
    on<RemoveProfilePictureEvent>(_onRemoveProfilePictureEvent);
    on<ProfilePictureDoneToggleEvent>(_onProfilePictureDoneToggleEvent);
    on<ResetSignUpStateOnScreenClosedEvent>(
      _resetSignUpStateOnScreenClosedEvent,
    );
    on<SignupEmailChangeEvent>(_onSignupEmailChangeEvent);
    on<SignupEmailErrorEvent>(_onSignupEmailErrorEvent);
    on<SignupPasswordChangeEvent>(_onSignupPasswordChangeEvent);
    on<ConfirmPasswordChangeEvent>(_onConfirmPasswordChangeEvent);
    on<ConfirmPasswordErrorEvent>(_onConfirmPasswordErrorEvent);
    on<TogglePasswordVisibilityEvent>(_onTogglePasswordVisibilityEvent);
    on<ToggleConfirmPasswordVisibilityEvent>(
      _onToggleConfirmPasswordVisibilityEvent,
    );
    on<UpdatePasswordStrengthEvent>(_onUpdatePasswordStrengthEvent);
    on<SignupWithEmailEvent>(_onSignupWithEmailEvent);
    on<ResendVerificationEmailTimeLeftEvent>(
      _onResendVerificationEmailTimeLeftEvent,
    );
    on<FinishProfilePictureEvent>(_onFinishProfilePictureEvent);
    on<AuthenticationExceptionEvent>(_onAuthenticationExceptionEvent);

    on<EmailSignUpLoadingEvent>(_onEmailSignUpLoadingEvent);
    on<CheckEmailAvailabilityEvent>(_onVerifyEmailAccountEvent);
    on<ResetPasswordStateEvent>(_onResetPasswordStateEvent);
    on<ChangeUserDetailsInputStatusEvent>(_onChangeUserDetailsInputStatusEvent);
    on<SendEmailVerificationLinkEvent>(_onSendEmailVerificationLinkEvent);
    on<RestartVerificationMailResendTimerEvent>(
      _onRestartVerificationMailResendTimerEvent,
    );
    on<NavigateToEmailVerifyScreenEvent>(_onNavigateToEmailVerifyScreenEvent);
  }

  void _onChangeUserDetailsInputStatusEvent(
    ChangeUserDetailsInputStatusEvent event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(userDetailsInputStatus: UserDetailsInputStatus.inProgress),
    );
  }

  void _onResetPasswordStateEvent(ResetPasswordStateEvent event, Emitter emit) {
    emit(
      state.copyWith(
        password: '',
        confirmPassword: '',
        isPasswordVisible: false,
        isConfirmPasswordVisible: false,
        passwordStrengthLevel: 0,
        isPasswordLongEnough: false,
        hasLetterAndNumberInPassword: false,
        hasSpecialCharacterInPassword: false,
      ),
    );
  }

  void _onVerifyEmailAccountEvent(
    CheckEmailAvailabilityEvent event,
    Emitter emit,
  ) {
    emit(SignupLoadingState(state, isLoading: false));
    emit(NavigateToCreatePasswordState(state));
  }

  void _onSelectedProfilePictureEvent(
    SelectedProfilePictureEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(selectedProfilePicture: event.image));
  }

  void _onRemoveProfilePictureEvent(
    RemoveProfilePictureEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(canSetProfilePictureToNull: true));
  }

  void _onProfilePictureDoneToggleEvent(
    ProfilePictureDoneToggleEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(isDoneProfilePicEditing: event.isDoneEditing));
  }

  void _resetSignUpStateOnScreenClosedEvent(
    ResetSignUpStateOnScreenClosedEvent event,
    Emitter emit,
  ) {
    // If we are in the process of completing the user details,
    // we don’t want to reset the signup state on page closed.
    if (state.userDetailsInputStatus != UserDetailsInputStatus.inProgress) {
      emit(SignupState.initial());
    }
  }

  void _onSignupEmailChangeEvent(SignupEmailChangeEvent event, Emitter emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onSignupEmailErrorEvent(SignupEmailErrorEvent event, Emitter emit) {
    emit(
      state.copyWith(
        emailErrorMessage: event.errorMessage,
        canSetEmailErrorMessageToNull: true,
      ),
    );
  }

  void _onSignupPasswordChangeEvent(
    SignupPasswordChangeEvent event,
    Emitter emit,
  ) {
    final password = event.password;
    final bool isLongEnough = password.length >= kMinimumPasswordLength;
    final bool hasLetterAndNumber = password.hasLetterAndNumber();
    final bool hasSpecialCharacter = password.hasSpecialCharacter();
    final int passedCriteria =
        (isLongEnough ? 1 : 0) +
        (hasLetterAndNumber ? 1 : 0) +
        (hasSpecialCharacter ? 1 : 0);

    emit(
      state.copyWith(
        password: event.password,
        passwordStrengthLevel: passedCriteria,
        isPasswordLongEnough: isLongEnough,
        hasLetterAndNumberInPassword: hasLetterAndNumber,
        hasSpecialCharacterInPassword: hasSpecialCharacter,
      ),
    );
  }

  void _onConfirmPasswordChangeEvent(
    ConfirmPasswordChangeEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword));
  }

  void _onConfirmPasswordErrorEvent(
    ConfirmPasswordErrorEvent event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(
        confirmPasswordErrorMessage: event.errorMessage,
        canSetEmailErrorMessageToNull: true,
      ),
    );
  }

  void _onTogglePasswordVisibilityEvent(
    TogglePasswordVisibilityEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(isPasswordVisible: event.isVisible));
  }

  void _onToggleConfirmPasswordVisibilityEvent(
    ToggleConfirmPasswordVisibilityEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(isConfirmPasswordVisible: event.isVisible));
  }

  void _onUpdatePasswordStrengthEvent(
    UpdatePasswordStrengthEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(passwordStrengthLevel: event.passwordStrengthLevel));
  }

  void _onSignupWithEmailEvent(SignupWithEmailEvent event, Emitter emit) {
    final String password = state.password;
    final String confirmPassword = state.confirmPassword;
    if (confirmPassword.isEmpty) {
      add(
        ConfirmPasswordErrorEvent(
          errorMessage: localizations.error_enter_confirm_password,
        ),
      );
      return;
    } else if (password != confirmPassword) {
      add(
        ConfirmPasswordErrorEvent(
          errorMessage: localizations.passwords_do_not_match,
        ),
      );
      return;
    }
    _signupWithEmailAndPassword();
  }

  void _onResendVerificationEmailTimeLeftEvent(
    ResendVerificationEmailTimeLeftEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(resendVerificationEmailTimeLeft: event.resendTimeLeft));
  }

  void _onFinishProfilePictureEvent(
    FinishProfilePictureEvent event,
    Emitter emit,
  ) {
    _proceedSignUpDetailsUpload();
  }

  void _onAuthenticationExceptionEvent(
    AuthenticationExceptionEvent event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(
        authenticationErrorMessage: event.errorMessage,
        isLoading: false,
      ),
    );
    emit(AuthenticationExceptionState(state));
  }

  void _onEmailSignUpLoadingEvent(EmailSignUpLoadingEvent event, Emitter emit) {
    emit(EmailSignUpLoadingState(state, isLoading: event.isLoading));
  }

  void _proceedSignUpDetailsUpload() async {
    final AppAuthUser? currentAuthUser = _authService.getCurrentUser();
    if (currentAuthUser == null) {
      debugPrint('Supabase current user == null');

      add(
        AuthenticationExceptionEvent(
          errorMessage: localizations.opps_something_went_wrong,
        ),
      );
      return;
    }
    final String? token = await currentAuthUser.getIdToken(true);
    if (token == null) {
      debugPrint('token == null');
      hideAllLoadingsAndShowError();
      return;
    }
    switch (state.selectedLoginSignupType) {
      case LoginType.PHONE:
        await _performSignupWithPhone(currentAuthUser, token);
      case LoginType.EMAIL:
      case LoginType.GOOGLE:
      case LoginType.APPLE:
        await _performSignupWithEmailOrSSO(currentAuthUser, token);
    }
  }

  Future<void> _performSignupWithPhone(
    AppAuthUser currentAuthUser,
    String token,
  ) async {
    add(PhoneNumSignUpLoadingEvent(isLoading: true));
    final String? phoneNumber = currentAuthUser.phoneNumber;
    if (phoneNumber == null) {
      debugPrint('Supabase current user phone number == null');

      add(PhoneNumSignUpLoadingEvent(isLoading: false));
      add(
        AuthenticationExceptionEvent(
          errorMessage: localizations.opps_something_went_wrong,
        ),
      );
      return;
    }
  }

  Future<void> _performSignupWithEmailOrSSO(
    AppAuthUser currentAuthUser,
    String token,
  ) async {
    add(EmailSignUpLoadingEvent(isLoading: true));
    if (currentAuthUser.email == null) {
      debugPrint('Supabase current user email == null');

      add(EmailSignUpLoadingEvent(isLoading: false));
      add(
        AuthenticationExceptionEvent(
          errorMessage: localizations.opps_something_went_wrong,
        ),
      );
      return;
    }
  }

  Future<void> _signupWithEmailAndPassword() async {
    _performanceService.startTrace(kTraceSignupEmail);
    add(EmailSignUpLoadingEvent(isLoading: true));
    final email = state.email;
    final password = state.password;

    final authCredential = await _authService
        .signupWithEmailAndPassword(
          email,
          password,
          onError: (error, {stackTrace}) {
            _performanceService.putAttribute(
              kTraceSignupEmail,
              kTraceAttrError,
              error.truncate(100),
            );
            add(EmailSignUpLoadingEvent(isLoading: false));
            add(AuthenticationExceptionEvent(errorMessage: error));
          },
        );

    if (authCredential != null) {
      _performanceService.putAttribute(
        kTraceSignupEmail,
        kTraceAttrSuccess,
        true,
      );
      final authUser = authCredential.user;
      if (authUser != null) {
        // Fire-and-forget: a slow Supabase write must not delay the
        // verification-email queueing.
        unawaited(_ensureChatUserDocument(authUser));
      }
      add(SendEmailVerificationLinkEvent());
    } else {
      debugPrint('signup with Email/Password authCredential is null');
      _performanceService.stopTrace(kTraceSignupEmail);
      return;
    }
    add(NavigateToEmailVerifyScreenEvent());
    add(EmailSignUpLoadingEvent(isLoading: false));
    _performanceService.stopTrace(kTraceSignupEmail);
  }

  Future<void> handleUserDetails(
    AppAuthUser? authUser, {
    required Function(String) onError,
  }) async {
    final loginType = state.selectedLoginSignupType;
    if (authUser == null) {
      debugPrint('authUser is null');
      onError(localizations.user_info_not_retrieved);
      return;
    }
    if (loginType == LoginType.PHONE) {
      if (authUser.phoneNumber.isNullOrEmpty()) {
        debugPrint('Authentication Current user phone number is null');

        onError(localizations.error_retrieving_phone_number);
        return;
      }

      await _storeLoginDetailsInPrefs(authUser);
      add(PhoneNumSignUpLoadingEvent(isLoading: false));
      add(NavigateToHomeScreenEvent());
    } else if (loginType == LoginType.EMAIL) {
      if (authUser.email.isNullOrEmpty()) {
        onError(localizations.error_retrieving_email);
        return;
      }
    } else if (loginType == LoginType.GOOGLE) {
    } else if (loginType == LoginType.APPLE) {
    } else {
      debugPrint('Login/Signup type not specified');
      hideAllLoadingsAndShowError();
    }
  }

  /// Writes a minimal profile document for the freshly-signed-up user into the
  /// `users` table so they can be discovered by the chat feature. Fires
  /// non-blocking — Supabase outages must not derail the signup flow.
  Future<void> _ensureChatUserDocument(AppAuthUser authUser) async {
    final email = authUser.email ?? '';
    final phoneNumber = authUser.phoneNumber ?? '';
    final fallbackName = email.contains('@')
        ? email.split('@').first
        : phoneNumber;
    final trimmedDisplayName = authUser.displayName?.trim() ?? '';
    final name = trimmedDisplayName.isNotEmpty
        ? trimmedDisplayName
        : fallbackName;
    final result = await sl<CreateChatUserDocument>()(
      CreateChatUserDocumentParams(
        userId: authUser.uid,
        name: name,
        email: email,
        photoUrl: authUser.photoURL,
      ),
    );
    result.fold(
      (failure) => debugPrint(
        '[Signup] chat user row write failed: ${failure.message}',
      ),
      (_) => debugPrint('[Signup] chat user row upserted'),
    );
  }

  void hideAllLoadingsAndShowError() {
    add(
      AuthenticationExceptionEvent(
        errorMessage: localizations.opps_something_went_wrong,
      ),
    );
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

  FutureOr<void> _onSendEmailVerificationLinkEvent(
    SendEmailVerificationLinkEvent event,
    Emitter<SignupState> emit,
  ) async {
    add(EmailSignUpLoadingEvent(isLoading: true));
    await _authService.sendVerificationEmail(
      onError: (errorMessage, {stackTrace}) {
        add(EmailSignUpLoadingEvent(isLoading: false));
        add(AuthenticationExceptionEvent(errorMessage: errorMessage));
      },
    );
    add(EmailSignUpLoadingEvent(isLoading: false));
    add(RestartVerificationMailResendTimerEvent());
  }

  FutureOr<void> _onRestartVerificationMailResendTimerEvent(
    RestartVerificationMailResendTimerEvent event,
    Emitter<SignupState> emit,
  ) {
    emit(RestartVerificationMailResendTimerState(state));
  }

  FutureOr<void> _onNavigateToEmailVerifyScreenEvent(
    NavigateToEmailVerifyScreenEvent event,
    Emitter<SignupState> emit,
  ) {
    emit(NavigateToEmailVerifyScreenState(state));
  }
}
