import 'package:skelter/presentation/chat/domain/entities/chat_preview_entity.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_text_message_entity.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_user_entity.dart';
import 'package:skelter/utils/typedef.dart';

mixin ChatRepository {
  /// Streams every registered user except [currentUserId]. Emits whenever the
  /// underlying Supabase table changes.
  Stream<List<ChatUserEntity>> watchOtherUsers({required String currentUserId});

  /// Streams the message history of [chatId] in descending creation order
  /// (newest first), suitable for a reversed [ListView].
  Stream<List<ChatTextMessageEntity>> watchMessages({required String chatId});

  /// Streams chat summaries (last message + timestamp) for every chat the
  /// current user is a participant in, sorted recent-first.
  Stream<List<ChatPreviewEntity>> watchMyChats({required String currentUserId});

  /// Sends a single text [text] from [senderId] to [recipientId]. Creates the
  /// chat document on first send and updates its `lastMessage`/`lastMessageAt`
  /// metadata so a future inbox-style listing can sort by recency.
  ResultVoid sendTextMessage({
    required String senderId,
    required String recipientId,
    required String text,
  });

  /// Upserts the current user's profile document in the `users` collection so
  /// they can be discovered by other participants. Called once per signup.
  ResultVoid createUserDocument({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
  });

  /// Removes the user's profile document so they no longer appear in other
  /// participants' chat directories. Must be called while the user is still
  /// authenticated — RLS policies require `request.auth.uid == userId`.
  ResultVoid deleteUserDocument({required String userId});
}
