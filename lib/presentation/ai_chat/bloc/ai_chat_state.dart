import 'package:equatable/equatable.dart';
import 'package:skelter/presentation/ai_chat/model/ai_chat_message.dart';

class AiChatState with EquatableMixin {
  const AiChatState({
    required this.messages,
    this.isGenerating = false,
    this.errorMessage,
  });

  const AiChatState.initial()
    : messages = const [],
      isGenerating = false,
      errorMessage = null;

  final List<AiChatMessage> messages;
  final bool isGenerating;
  final String? errorMessage;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isGenerating,
    Object? errorMessage = _sentinel,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => [messages, isGenerating, errorMessage];
}
