import 'package:equatable/equatable.dart';

/// A one-to-one chat summary, keyed by the [otherUserId] participant from the
/// current user's perspective. Used to render the chat list with last-message
/// previews and "X ago" timestamps.
class ChatPreviewEntity extends Equatable {
  const ChatPreviewEntity({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final DateTime lastMessageAt;

  @override
  List<Object?> get props => [chatId, otherUserId, lastMessage, lastMessageAt];
}
