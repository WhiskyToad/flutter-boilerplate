import 'package:equatable/equatable.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_preview_entity.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_user_entity.dart';

abstract class ChatUsersEvent extends Equatable {
  const ChatUsersEvent();

  @override
  List<Object?> get props => [];
}

class ChatUsersSubscribedEvent extends ChatUsersEvent {
  const ChatUsersSubscribedEvent();
}

class ChatUsersReceivedEvent extends ChatUsersEvent {
  const ChatUsersReceivedEvent({required this.users});

  final List<ChatUserEntity> users;

  @override
  List<Object?> get props => [users];
}

class ChatPreviewsReceivedEvent extends ChatUsersEvent {
  const ChatPreviewsReceivedEvent({required this.previews});

  final List<ChatPreviewEntity> previews;

  @override
  List<Object?> get props => [previews];
}

class ChatUsersFailedEvent extends ChatUsersEvent {
  const ChatUsersFailedEvent({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ChatUsersFilterChangedEvent extends ChatUsersEvent {
  const ChatUsersFilterChangedEvent({required this.searchQuery});

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

class ChatUsersToggleSpeechAnimationEvent extends ChatUsersEvent {
  const ChatUsersToggleSpeechAnimationEvent({
    required this.shouldAnimateListenIcon,
  });

  final bool shouldAnimateListenIcon;

  @override
  List<Object?> get props => [shouldAnimateListenIcon];
}

class ChatUsersStartSpeechToTextEvent extends ChatUsersEvent {
  const ChatUsersStartSpeechToTextEvent();
}

class ChatUsersStopSpeechToTextEvent extends ChatUsersEvent {
  const ChatUsersStopSpeechToTextEvent();
}

class ChatUsersVoiceInputCompleteEvent extends ChatUsersEvent {
  const ChatUsersVoiceInputCompleteEvent({required this.searchQuery});

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}
