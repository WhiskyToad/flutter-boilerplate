import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/presentation/chat/constants/chat_constants.dart';
import 'package:skelter/presentation/chat/data/models/chat_preview_model.dart';
import 'package:skelter/presentation/chat/data/models/chat_text_message_model.dart';
import 'package:skelter/presentation/chat/data/models/chat_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  ChatRemoteDatasourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<ChatUserModel>> watchOtherUsers({required String currentUserId}) {
    return _client
        .from(kChatUsersCollection)
        .stream(primaryKey: ['id'])
        .map(
          (rows) => rows
              .where((row) => row['id'] != currentUserId)
              .map((row) => ChatUserModel.fromMap(row, row['id'].toString()))
              .toList(),
        );
  }

  @override
  Stream<List<ChatTextMessageModel>> watchMessages({required String chatId}) {
    return _client
        .from(kChatMessagesSubcollection)
        .stream(primaryKey: ['id'])
        .eq('chatId', chatId)
        .order('createdAt', ascending: false)
        .map(
          (rows) => rows
              .map(
                (row) => ChatTextMessageModel.fromMap(
                  row,
                  row['id'].toString(),
                  chatId,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<ChatPreviewModel>> watchMyChats({required String currentUserId}) {
    return _client
        .from(kChatsCollection)
        .stream(primaryKey: ['id'])
        .map(
          (rows) =>
              rows
                  .where((row) {
                    final participants = row['participants'];
                    return participants is List &&
                        participants.contains(currentUserId);
                  })
                  .map(
                    (row) => ChatPreviewModel.fromMap(
                      row,
                      row['id'].toString(),
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
      final now = DateTime.now().toIso8601String();
      await _client.from(kChatsCollection).upsert({
        'id': chatId,
        'participants': participants,
        'lastMessage': text,
        'lastMessageAt': now,
      });

      await _client.from(kChatMessagesSubcollection).insert({
        'chatId': chatId,
        ...ChatTextMessageModel.toCreateMap(senderId: senderId, text: text),
      });
    } on PostgrestException catch (e) {
      throw APIException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
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
      await _client
          .from(kChatUsersCollection)
          .upsert({'id': userId, ...user.toCreateMap()});
    } on PostgrestException catch (e) {
      throw APIException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  @override
  Future<void> deleteUserDocument({required String userId}) async {
    try {
      await _client.from(kChatUsersCollection).delete().eq('id', userId);
    } on PostgrestException catch (e) {
      throw APIException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }
}
