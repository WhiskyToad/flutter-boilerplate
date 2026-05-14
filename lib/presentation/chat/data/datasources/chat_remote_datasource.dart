import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/presentation/chat/constants/chat_constants.dart';
import 'package:skelter/presentation/chat/data/models/chat_preview_model.dart';
import 'package:skelter/presentation/chat/data/models/chat_text_message_model.dart';
import 'package:skelter/presentation/chat/data/models/chat_user_model.dart';

mixin ChatRemoteDatasource {
  Stream<List<ChatUserModel>> watchOtherUsers({required String currentUserId});

  Stream<List<ChatTextMessageModel>> watchMessages({required String chatId});

  Stream<List<ChatPreviewModel>> watchMyChats({required String currentUserId});

  Future<void> sendTextMessage({
    required String chatId,
    required List<String> participants,
    required String senderId,
    required String text,
  });

  Future<void> upsertUserDocument({
    required String userId,
    required ChatUserModel user,
  });

  Future<void> deleteUserDocument({required String userId});
}

class ChatRemoteDatasourceImpl with ChatRemoteDatasource {
  ChatRemoteDatasourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ChatUserModel>> watchOtherUsers({required String currentUserId}) {
    return _firestore
        .collection(kChatUsersCollection)
        .snapshots()
        .map(
          (snap) => snap.docs
              .where((doc) => doc.id != currentUserId)
              .map((doc) => ChatUserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<ChatTextMessageModel>> watchMessages({required String chatId}) {
    return _firestore
        .collection(kChatsCollection)
        .doc(chatId)
        .collection(kChatMessagesSubcollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) =>
                    ChatTextMessageModel.fromMap(doc.data(), doc.id, chatId),
              )
              .toList(),
        );
  }

  @override
  Stream<List<ChatPreviewModel>> watchMyChats({required String currentUserId}) {
    // Client-side sort by lastMessageAt keeps the query free of a compound
    // index requirement. Chats per user are expected to be in the tens, not
    // thousands, so the sort cost is negligible.
    return _firestore
        .collection(kChatsCollection)
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map(
                    (doc) => ChatPreviewModel.fromMap(
                      doc.data(),
                      doc.id,
                      currentUserId,
                    ),
                  )
                  .whereType<ChatPreviewModel>()
                  .toList()
                ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt)),
        );
  }

  @override
  Future<void> sendTextMessage({
    required String chatId,
    required List<String> participants,
    required String senderId,
    required String text,
  }) async {
    try {
      final chatDoc = _firestore.collection(kChatsCollection).doc(chatId);
      final messagesRef = chatDoc.collection(kChatMessagesSubcollection);

      final batch = _firestore.batch();
      batch.set(chatDoc, {
        'participants': participants,
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final newMessageRef = messagesRef.doc();
      batch.set(
        newMessageRef,
        ChatTextMessageModel.toCreateMap(senderId: senderId, text: text),
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Failed to send message',
        statusCode: int.tryParse(e.code) ?? 500,
      );
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  @override
  Future<void> upsertUserDocument({
    required String userId,
    required ChatUserModel user,
  }) async {
    try {
      await _firestore
          .collection(kChatUsersCollection)
          .doc(userId)
          .set(user.toCreateMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Failed to upsert user document',
        statusCode: int.tryParse(e.code) ?? 500,
      );
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  @override
  Future<void> deleteUserDocument({required String userId}) async {
    try {
      await _firestore.collection(kChatUsersCollection).doc(userId).delete();
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Failed to delete user document',
        statusCode: int.tryParse(e.code) ?? 500,
      );
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }
}
