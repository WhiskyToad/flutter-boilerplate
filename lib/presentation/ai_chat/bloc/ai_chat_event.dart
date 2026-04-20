import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();
}

class SendMessageEvent extends AiChatEvent {
  const SendMessageEvent({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

class StreamResponseChunkEvent extends AiChatEvent {
  const StreamResponseChunkEvent({required this.chunk});

  final String chunk;

  @override
  List<Object> get props => [chunk];
}

class StreamResponseCompleteEvent extends AiChatEvent {
  const StreamResponseCompleteEvent();

  @override
  List<Object> get props => [];
}

class StreamResponseErrorEvent extends AiChatEvent {
  const StreamResponseErrorEvent({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class StopGenerationEvent extends AiChatEvent {
  const StopGenerationEvent();

  @override
  List<Object> get props => [];
}

class ClearChatEvent extends AiChatEvent {
  const ClearChatEvent();

  @override
  List<Object> get props => [];
}
