import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/services/ai/gemini_constants.dart';
import 'package:skelter/utils/app_flavor_env.dart';

class GeminiChatSession {
  GeminiChatSession._(this._service, this._systemInstruction);

  final GeminiService _service;
  final String _systemInstruction;

  Stream<String> sendMessage(String message) async* {
    yield await _service.generateContent(
      prompt: '$_systemInstruction\n\n$message',
    );
  }
}

class GeminiService {
  GeminiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  bool _isInitialized = false;

  void initialize() {
    final apiKey = AppConfig.getGeminiApiKey();
    if (apiKey.isEmpty) {
      debugPrint('[Gemini] GEMINI_API_KEY not configured');
      _isInitialized = false;
      return;
    }
    _isInitialized = true;
    debugPrint('[Gemini] REST Gemini Service initialized');
  }

  Future<String> generateContent({
    required String prompt,
    Duration? timeout,
  }) async {
    final apiKey = AppConfig.getGeminiApiKey();
    if (!_isInitialized || apiKey.isEmpty) {
      throw Exception('Gemini API key not configured.');
    }

    try {
      final response = await _dio
          .post<Map<String, dynamic>>(
            'https://generativelanguage.googleapis.com/v1beta/models/'
            '${GeminiConstants.geminiProModel}:generateContent',
            queryParameters: {'key': apiKey},
            data: {
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': GeminiConstants.temperature,
                'maxOutputTokens': GeminiConstants.maxOutputTokens,
                'topP': GeminiConstants.topP,
                'topK': GeminiConstants.topK,
                'stopSequences': ['\n\n---\n\n', 'END_OF_DESCRIPTION'],
              },
            },
          )
          .timeout(timeout ?? GeminiConstants.apiTimeout);

      final candidates = response.data?['candidates'] as List?;
      final firstCandidate = candidates == null || candidates.isEmpty
          ? null
          : candidates.first;
      final content = firstCandidate is Map ? firstCandidate['content'] : null;
      final parts = content is Map ? content['parts'] as List? : null;
      final firstPart = parts == null || parts.isEmpty ? null : parts.first;
      final text = firstPart is Map ? firstPart['text']?.toString() : null;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }
      return text;
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  Future<String> generateContentWithImages({
    required String prompt,
    required List<String> imageUrls,
    Duration? timeout,
  }) async {
    return generateContent(prompt: prompt, timeout: timeout);
  }

  Stream<String> generateContentStream({required String prompt}) async* {
    yield await generateContent(prompt: prompt);
  }

  GeminiChatSession createChatSession(String systemInstruction) {
    return GeminiChatSession._(this, systemInstruction);
  }

  void dispose() {
    _isInitialized = false;
  }
}
