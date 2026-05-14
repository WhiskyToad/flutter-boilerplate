import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_preview_entity.dart';
import 'package:skelter/utils/typedef.dart';

class ChatPreviewModel extends ChatPreviewEntity {
  const ChatPreviewModel({
    required super.chatId,
    required super.otherUserId,
    required super.lastMessage,
    required super.lastMessageAt,
  });

  /// Returns null if the chat document lacks the expected participants list,
  /// the timestamp, or the current user isn't actually one of the two
  /// participants (in which case the doc shouldn't have been returned by the
  /// `arrayContains` query — defensive guard).
  static ChatPreviewModel? fromMap(
    DataMap map,
    String chatId,
    String currentUserId,
  ) {
    final rawParticipants = map['participants'];
    if (rawParticipants is! List) return null;
    final participants = rawParticipants.whereType<String>().toList();
    if (!participants.contains(currentUserId)) return null;
    final otherUserId = participants.firstWhere(
      (uid) => uid != currentUserId,
      orElse: () => '',
    );
    if (otherUserId.isEmpty) return null;

    final rawTimestamp = map['lastMessageAt'];
    if (rawTimestamp is! Timestamp) return null;

    return ChatPreviewModel(
      chatId: chatId,
      otherUserId: otherUserId,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageAt: rawTimestamp.toDate(),
    );
  }
}
