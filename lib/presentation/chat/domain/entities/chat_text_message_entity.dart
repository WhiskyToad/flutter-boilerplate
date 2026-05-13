import 'package:equatable/equatable.dart';

class ChatTextMessageEntity extends Equatable {
  const ChatTextMessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, chatId, senderId, text, createdAt];
}
