import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/presentation/profile/bloc/profile_event.dart';
import 'package:skelter/presentation/profile/bloc/profile_state.dart';
import 'package:skelter/services/firebase_auth_services.dart';
import 'package:skelter/shared_pref/prefs.dart';
import 'package:skelter/utils/cache_manager.dart';
import 'package:skelter/utils/haptic_feedback_util.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
    : super(
        ProfileState.initial(
          name: 'Jessica Fernandes',
          email: 'jessica@gmail.com',
        ),
      ) {
    _setupEventListener();
  }

  @override
  void onTransition(Transition<ProfileEvent, ProfileState> transition) {
    super.onTransition(transition);
    debugPrint('Transition: $transition');
  }

  void _setupEventListener() {
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<UpdateSubscriptionStatusEvent>(_onUpdateSubscriptionStatusEvent);
    on<SignOutEvent>(_onSignOutEvent);
  }

  void _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        name: event.name,
        email: event.email,
        isProUser: event.isProUser,
      ),
    );
  }

  void _onUpdateSubscriptionStatusEvent(
    UpdateSubscriptionStatusEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(isProUser: event.isSubscribed));
  }

  void _onSignOutEvent(SignOutEvent event, Emitter<ProfileState> emit) async {
    try {
      await Prefs.clear();
      await sl<CacheManager>().clearCachedApiResponse();
      await FirebaseAuthService().signOut();
      await HapticFeedbackUtil.light();
      emit(SignOutState());
    } catch (e) {
      debugPrint('Error signing out: $e');
      await HapticFeedbackUtil.error();
      emit(SignOutErrorState(errorMessage: e.toString()));
    }
  }
}
