import 'package:skelter/presentation/ai_chat/model/ai_chat_message.dart';

final _sampleTimestamp = DateTime(2026, 4, 21, 10, 30);

final sampleAiChatMessages = <AiChatMessage>[
  AiChatMessage(
    role: AiChatRole.user,
    content: 'What are your best deals today?',
    timestamp: _sampleTimestamp,
  ),
  AiChatMessage(
    role: AiChatRole.assistant,
    content:
        'Here are a few highlights from our catalog '
        'that are worth a look today.',
    timestamp: _sampleTimestamp.add(const Duration(seconds: 2)),
  ),
  AiChatMessage(
    role: AiChatRole.user,
    content: 'Can I see my cart?',
    timestamp: _sampleTimestamp.add(const Duration(seconds: 30)),
  ),
  AiChatMessage(
    role: AiChatRole.assistant,
    content: 'Sure — here is a shortcut to your cart.',
    timestamp: _sampleTimestamp.add(const Duration(seconds: 32)),
  ),
];

final sampleAiChatMessagesWithError = <AiChatMessage>[
  AiChatMessage(
    role: AiChatRole.user,
    content: 'Tell me about the latest smartphones.',
    timestamp: _sampleTimestamp,
  ),
];
