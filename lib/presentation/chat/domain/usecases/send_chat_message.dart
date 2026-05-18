import 'package:equatable/equatable.dart';
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/chat/domain/repositories/chat_repository.dart';
import 'package:skelter/utils/typedef.dart';

class SendChatMessage with UseCaseWithParams<void, SendChatMessageParams> {
  const SendChatMessage(this._repository);

  final ChatRepository _repository;

  @override
  ResultVoid call(SendChatMessageParams params) => _repository.sendTextMessage(
    senderId: params.senderId,
    recipientId: params.recipientId,
    text: params.text,
  );
}

class SendChatMessageParams extends Equatable {
  const SendChatMessageParams({
    required this.senderId,
    required this.recipientId,
    required this.text,
  });

  final String senderId;
  final String recipientId;
  final String text;

  @override
  List<Object?> get props => [senderId, recipientId, text];
}
