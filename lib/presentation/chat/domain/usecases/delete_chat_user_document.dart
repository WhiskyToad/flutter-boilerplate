import 'package:equatable/equatable.dart';
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/chat/domain/repositories/chat_repository.dart';
import 'package:skelter/utils/typedef.dart';

class DeleteChatUserDocument
    with UseCaseWithParams<void, DeleteChatUserDocumentParams> {
  const DeleteChatUserDocument(this._repository);

  final ChatRepository _repository;

  @override
  ResultVoid call(DeleteChatUserDocumentParams params) =>
      _repository.deleteUserDocument(userId: params.userId);
}

class DeleteChatUserDocumentParams extends Equatable {
  const DeleteChatUserDocumentParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}
