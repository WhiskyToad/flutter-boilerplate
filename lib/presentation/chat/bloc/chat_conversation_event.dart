import 'package:equatable/equatable.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_text_message_entity.dart';

abstract class ChatConversationEvent extends Equatable {
  const ChatConversationEvent();

  @override
  List<Object?> get props => [];
}

class ChatConversationSubscribedEvent extends ChatConversationEvent {
  const ChatConversationSubscribedEvent();
}

class ChatConversationMessagesReceivedEvent extends ChatConversationEvent {
  const ChatConversationMessagesReceivedEvent({required this.messages});

  final List<ChatTextMessageEntity> messages;

  @override
  List<Object?> get props => [messages];
}

class ChatConversationMessagesFailedEvent extends ChatConversationEvent {
  const ChatConversationMessagesFailedEvent({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ChatConversationSendMessageEvent extends ChatConversationEvent {
  const ChatConversationSendMessageEvent({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];
}

class ChatConversationDraftChangedEvent extends ChatConversationEvent {
  const ChatConversationDraftChangedEvent({required this.draft});

  final String draft;

  @override
  List<Object?> get props => [draft];
}
