import 'package:skelter/presentation/chat/domain/entities/chat_text_message_entity.dart';
import 'package:skelter/utils/typedef.dart';

class ChatTextMessageModel extends ChatTextMessageEntity {
  const ChatTextMessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.text,
    required super.createdAt,
  });

  factory ChatTextMessageModel.fromMap(DataMap map, String id, String chatId) {
    return ChatTextMessageModel(
      id: id,
      chatId: chatId,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  static DataMap toCreateMap({required String senderId, required String text}) {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
