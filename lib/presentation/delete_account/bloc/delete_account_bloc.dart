import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/presentation/chat/domain/usecases/delete_chat_user_document.dart';
import 'package:skelter/presentation/delete_account/bloc/delete_account_event.dart';
import 'package:skelter/presentation/delete_account/bloc/delete_account_state.dart';
import 'package:skelter/presentation/delete_account/constants/delete_account_constants.dart';
import 'package:skelter/services/firebase_auth_services.dart';
import 'package:skelter/services/performance_monitoring_service.dart';
import 'package:skelter/utils/extensions/primitive_types_extensions.dart';
import 'package:skelter/utils/haptic_feedback_util.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final FirebaseAuthService _firebaseAuthService = sl();
  final PerformanceMonitoringService _performanceService = sl();

  DeleteAccountBloc() : super(const DeleteAccountState.initial()) {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    on<DeleteReasonSelectedEvent>(_onReasonSelectedEvent);
    on<DeleteOtherReasonTextChangedEvent>(_onOtherReasonTextChangedEvent);
    on<DeleteAccountSubmittedEvent>(_onDeleteAccountSubmittedEvent);
  }

  void _onReasonSelectedEvent(
    DeleteReasonSelectedEvent event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(
      DeleteAccountInputUpdatedState(
        state,
        selectedReason: event.reason,
        otherReasonText: state.otherReasonText,
      ),
    );
  }

  void _onOtherReasonTextChangedEvent(
    DeleteOtherReasonTextChangedEvent event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(
      DeleteAccountInputUpdatedState(
        state,
        selectedReason: state.selectedReason,
        otherReasonText: event.text,
      ),
    );
  }

  Future<void> _onDeleteAccountSubmittedEvent(
    DeleteAccountSubmittedEvent event,
    Emitter<DeleteAccountState> emit,
  ) async {
    _performanceService.startTrace(kTraceDeleteAccount);
    emit(state.copyWith(isLoading: true));

    var hasErrorOccurred = false;

    // Remove the user's chat directory document BEFORE deleting the auth
    // user. Firestore rules require `request.auth.uid == userId` for delete,
    // which fails once the auth user is gone. Best-effort: log on failure
    // (e.g. transient network) but proceed with auth deletion regardless —
    // the user's intent is to remove their account, and a stale chat doc is
    // a smaller harm than a partial deletion the user can't retry.
    final currentUser = _firebaseAuthService.getCurrentUser();
    if (currentUser != null) {
      final result = await sl<DeleteChatUserDocument>()(
        DeleteChatUserDocumentParams(userId: currentUser.uid),
      );
      result.fold(
        (failure) => debugPrint(
          '[DeleteAccount] chat user doc delete failed: ${failure.message}',
        ),
        (_) => debugPrint('[DeleteAccount] chat user doc deleted'),
      );
    }

    await _firebaseAuthService.deleteCurrentUser(
      onError: (error, {stackTrace}) async {
        hasErrorOccurred = true;
        _performanceService.putAttribute(
          kTraceDeleteAccount,
          kTraceAttrError,
          error.truncate(100),
        );
        await HapticFeedbackUtil.error();
        final user = _firebaseAuthService.getCurrentUser();
        final providerList =
            user?.providerData.map((p) => p.providerId).toList() ?? [];

        if (error == kFirebaseAuthRequiresRecentLogin ||
            error == kEmailPasswordReAuthRequired) {
          if (providerList.contains(kProviderPassword)) {
            emit(state.copyWith(isLoading: false, errorMessage: error));
            emit(DeleteAccountReAuthEmailPasswordRequiredState(state));
          } else if (providerList.contains(kProviderGoogle)) {
            emit(state.copyWith(isLoading: false, errorMessage: error));
            emit(DeleteAccountReAuthGoogleRequiredState(state));
          } else {
            emit(state.copyWith(isLoading: false, errorMessage: error));
            emit(DeleteAccountFailureState(state));
          }
        } else if (error == kPhoneAuthRequired) {
          emit(state.copyWith(isLoading: false, errorMessage: error));
          emit(DeleteAccountReAuthPhoneRequiredState(state));
        } else {
          emit(state.copyWith(isLoading: false, errorMessage: error));
          emit(DeleteAccountFailureState(state));
        }
      },
    );

    if (!hasErrorOccurred) {
      _performanceService.putAttribute(
        kTraceDeleteAccount,
        kTraceAttrSuccess,
        true,
      );
      emit(state.copyWith(isLoading: false));
      await HapticFeedbackUtil.success();
      emit(DeleteAccountSuccessState(state));
    }

    _performanceService.stopTrace(kTraceDeleteAccount);
  }
}
