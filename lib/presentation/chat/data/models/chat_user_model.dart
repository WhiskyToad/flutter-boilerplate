import 'package:skelter/presentation/chat/domain/entities/chat_user_entity.dart';
import 'package:skelter/utils/typedef.dart';

class ChatUserModel extends ChatUserEntity {
  const ChatUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
  });

  factory ChatUserModel.fromMap(DataMap map, String id) {
    final rawPhoto = (map['photoUrl'] as String?)?.trim();
    return ChatUserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: (rawPhoto == null || rawPhoto.isEmpty) ? null : rawPhoto,
    );
  }

  DataMap toCreateMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
