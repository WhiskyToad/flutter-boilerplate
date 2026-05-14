import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_preview_entity.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_user_entity.dart';

enum ChatUsersStatus { initial, loading, loaded, failure }

/// Sentinel used by [ChatUsersState.copyWith] to distinguish "argument not
/// supplied" from "argument explicitly set to null" for nullable fields.
const Object _kChatUsersStateUnset = Object();

class ChatUsersState extends Equatable {
  const ChatUsersState({
    this.status = ChatUsersStatus.initial,
    this.users = const [],
    this.chatPreviews = const {},
    this.errorMessage,
    this.searchQuery = '',
    this.shouldAnimateListenIcon = false,
  });

  const ChatUsersState.initial()
    : status = ChatUsersStatus.initial,
      users = const [],
      chatPreviews = const {},
      errorMessage = null,
      searchQuery = '',
      shouldAnimateListenIcon = false;

  @visibleForTesting
  const ChatUsersState.test({
    this.status = ChatUsersStatus.loaded,
    this.users = const [],
    this.chatPreviews = const {},
    this.errorMessage,
    this.searchQuery = '',
    this.shouldAnimateListenIcon = false,
  });

  final ChatUsersStatus status;
  final List<ChatUserEntity> users;

  /// Last-message previews keyed by the other participant's user id. Used to
  /// render the chat list with last-message text + "X ago" timestamps and to
  /// sort recent conversations first.
  final Map<String, ChatPreviewEntity> chatPreviews;

  final String? errorMessage;
  final String searchQuery;
  final bool shouldAnimateListenIcon;

  /// Users filtered by the current search query (case-insensitive contains
  /// match on display name), then sorted: users with an active conversation
  /// appear first (most recent message at the top), then users without a
  /// conversation in alphabetical order.
  List<ChatUserEntity> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();
    final matched = query.isEmpty
        ? List<ChatUserEntity>.from(users)
        : users
              .where((user) => user.name.toLowerCase().contains(query))
              .toList();
    matched.sort((a, b) {
      final previewA = chatPreviews[a.id];
      final previewB = chatPreviews[b.id];
      if (previewA != null && previewB != null) {
        return previewB.lastMessageAt.compareTo(previewA.lastMessageAt);
      }
      if (previewA != null) return -1;
      if (previewB != null) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return matched;
  }

  ChatUsersState copyWith({
    ChatUsersStatus? status,
    List<ChatUserEntity>? users,
    Map<String, ChatPreviewEntity>? chatPreviews,
    Object? errorMessage = _kChatUsersStateUnset,
    String? searchQuery,
    bool? shouldAnimateListenIcon,
  }) {
    return ChatUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      chatPreviews: chatPreviews ?? this.chatPreviews,
      errorMessage: identical(errorMessage, _kChatUsersStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      shouldAnimateListenIcon:
          shouldAnimateListenIcon ?? this.shouldAnimateListenIcon,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    chatPreviews,
    errorMessage,
    searchQuery,
    shouldAnimateListenIcon,
  ];
}
