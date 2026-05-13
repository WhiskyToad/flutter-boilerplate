import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/chat/constants/chat_constants.dart';
import 'package:skelter/presentation/chat/data/datasources/chat_remote_datasource.dart';
import 'package:skelter/presentation/chat/data/models/chat_user_model.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_preview_entity.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_text_message_entity.dart';
import 'package:skelter/presentation/chat/domain/entities/chat_user_entity.dart';
import 'package:skelter/presentation/chat/domain/repositories/chat_repository.dart';
import 'package:skelter/utils/typedef.dart';

class ChatRepositoryImpl with ChatRepository {
  const ChatRepositoryImpl(this._remoteDatasource);

  final ChatRemoteDatasource _remoteDatasource;

  @override
  Stream<List<ChatUserEntity>> watchOtherUsers({
    required String currentUserId,
  }) {
    return _remoteDatasource.watchOtherUsers(currentUserId: currentUserId);
  }

  @override
  Stream<List<ChatTextMessageEntity>> watchMessages({required String chatId}) {
    return _remoteDatasource.watchMessages(chatId: chatId);
  }

  @override
  Stream<List<ChatPreviewEntity>> watchMyChats({
    required String currentUserId,
  }) {
    return _remoteDatasource.watchMyChats(currentUserId: currentUserId);
  }

  @override
  ResultVoid sendTextMessage({
    required String senderId,
    required String recipientId,
    required String text,
  }) async {
    try {
      final chatId = buildChatId(senderId, recipientId);
      await _remoteDatasource.sendTextMessage(
        chatId: chatId,
        participants: [senderId, recipientId],
        senderId: senderId,
        text: text,
      );
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e) {
      debugPrint('[ChatRepository] sendTextMessage failed: $e');
      return Left(
        APIFailure.fromException(
          APIException(message: e.toString(), statusCode: 505),
        ),
      );
    }
  }

  @override
  ResultVoid createUserDocument({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      final user = ChatUserModel(
        id: userId,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      await _remoteDatasource.upsertUserDocument(userId: userId, user: user);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e) {
      debugPrint('[ChatRepository] createUserDocument failed: $e');
      return Left(
        APIFailure.fromException(
          APIException(message: e.toString(), statusCode: 505),
        ),
      );
    }
  }

  @override
  ResultVoid deleteUserDocument({required String userId}) async {
    try {
      await _remoteDatasource.deleteUserDocument(userId: userId);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e) {
      debugPrint('[ChatRepository] deleteUserDocument failed: $e');
      return Left(
        APIFailure.fromException(
          APIException(message: e.toString(), statusCode: 505),
        ),
      );
    }
  }
}
