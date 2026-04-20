import 'package:equatable/equatable.dart';

enum AiChatRole { user, assistant }

class AiChatMessage extends Equatable {
  const AiChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  final AiChatRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  bool get isUser => role == AiChatRole.user;

  AiChatMessage copyWith({
    AiChatRole? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return AiChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [role, content, timestamp, isStreaming];
}
