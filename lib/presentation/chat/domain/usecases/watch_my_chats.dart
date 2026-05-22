import 'package:skelter/presentation/chat/domain/entities/chat_preview_entity.dart';
import 'package:skelter/presentation/chat/domain/repositories/chat_repository.dart';

class WatchMyChats {
  const WatchMyChats(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatPreviewEntity>> call({required String currentUserId}) =>
      _repository.watchMyChats(currentUserId: currentUserId);
}
