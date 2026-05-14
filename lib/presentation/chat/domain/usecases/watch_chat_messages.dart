import 'package:skelter/presentation/chat/domain/entities/chat_text_message_entity.dart';
import 'package:skelter/presentation/chat/domain/repositories/chat_repository.dart';

class WatchChatMessages {
  const WatchChatMessages(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatTextMessageEntity>> call({required String chatId}) =>
      _repository.watchMessages(chatId: chatId);
}
