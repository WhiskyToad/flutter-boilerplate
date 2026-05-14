import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_text_message_entity.dart';

enum ChatConversationStatus { initial, loading, loaded, failure }

/// Sentinel used by [ChatConversationState.copyWith] to distinguish "argument
/// not supplied" from "argument explicitly set to null" for nullable fields.
const Object _kChatConversationStateUnset = Object();

class ChatConversationState extends Equatable {
  const ChatConversationState({
    this.status = ChatConversationStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.draft = '',
    this.isSending = false,
  });

  const ChatConversationState.initial()
    : status = ChatConversationStatus.initial,
      messages = const [],
      errorMessage = null,
      draft = '',
      isSending = false;

  @visibleForTesting
  const ChatConversationState.test({
    this.status = ChatConversationStatus.loaded,
    this.messages = const [],
    this.errorMessage,
    this.draft = '',
    this.isSending = false,
  });

  final ChatConversationStatus status;
  final List<ChatTextMessageEntity> messages;
  final String? errorMessage;
  final String draft;
  final bool isSending;

  bool get canSend => draft.trim().isNotEmpty && !isSending;

  ChatConversationState copyWith({
    ChatConversationStatus? status,
    List<ChatTextMessageEntity>? messages,
    Object? errorMessage = _kChatConversationStateUnset,
    String? draft,
    bool? isSending,
  }) {
    return ChatConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: identical(errorMessage, _kChatConversationStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
      draft: draft ?? this.draft,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage, draft, isSending];
}
