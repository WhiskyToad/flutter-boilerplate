import 'package:skelter/presentation/chat/domain/entities/chat_user_entity.dart';
import 'package:skelter/presentation/chat/domain/repositories/chat_repository.dart';

class WatchOtherUsers {
  const WatchOtherUsers(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatUserEntity>> call({required String currentUserId}) =>
      _repository.watchOtherUsers(currentUserId: currentUserId);
}
