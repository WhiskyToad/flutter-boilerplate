import 'package:flutter/foundation.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/presentation/product_detail/data/models/ai_product_description_model.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/services/ai/gemini_service.dart';

abstract class AIProductDescriptionRemoteDataSource {
  Future<AIProductDescriptionModel> generateProductDescription({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  });


  Stream<String> generateProductDescriptionStream({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  });
}

class AIProductDescriptionRemoteDataSourceImpl
    implements AIProductDescriptionRemoteDataSource {
  AIProductDescriptionRemoteDataSourceImpl(this._geminiService);

  final GeminiService _geminiService;

  @override
  Future<AIProductDescriptionModel> generateProductDescription({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  }) async {
    try {
      debugPrint('[AI DataSource] Building prompt...');
      final prompt = _buildPrompt(
        productDetail: productDetail,
        userOrderHistory: userOrderHistory,
      );

      debugPrint('[AI DataSource] Calling Gemini service...');
      final generatedText = await _geminiService.generateContent(
        prompt: prompt,
      );

      debugPrint('[AI DataSource] Creating model from response...');
      return AIProductDescriptionModel.fromGeneratedText(
        productId: productDetail.id,
        generatedText: generatedText,
        isPersonalized: userOrderHistory != null && userOrderHistory.isNotEmpty,
      );
    } catch (e) {
      debugPrint('[AI DataSource] ERROR: $e');
      throw APIException(
        message: 'Failed to generate AI description: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Stream<String> generateProductDescriptionStream({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  }) async* {
    try {
      final prompt = _buildPrompt(
        productDetail: productDetail,
        userOrderHistory: userOrderHistory,
      );

      final stream = _geminiService.generateContentStream(prompt: prompt);

      await for (final chunk in stream) {
        yield chunk;
      }
    } catch (e) {
      throw APIException(
        message: 'Failed to generate AI description stream: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  String _buildPrompt({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  }) {
    final buffer = StringBuffer();

    // Add system instruction as part of the prompt
    buffer.writeln(
      'You are an expert product description writer for an e-commerce'
      ' platform.',
    );
    buffer.writeln(
      'Your task is to create compelling, accurate, and personalized product'
      ' descriptions.',
    );
    buffer.writeln(
      'Focus on highlighting key features, benefits, and value propositions.',
    );
    buffer.writeln('Use professional yet friendly tone.');
    buffer.writeln();

    buffer.writeln('Generate a compelling product description based on:');
    buffer.writeln();
    buffer.writeln('Product Details:');
    buffer.writeln('- Title: ${productDetail.title}');
    buffer.writeln('- Category: ${productDetail.category}');
    buffer.writeln('- Price: \$${productDetail.price.toStringAsFixed(2)}');
    buffer.writeln('- Rating: ${productDetail.rating}/5.0');
    buffer.writeln('- Current Description: ${productDetail.description}');
    buffer.writeln();

    // Add image count information
    if (productDetail.productImages.isNotEmpty) {
      buffer.writeln(
        '- Product Images: '
        '${productDetail.productImages.length} variations available',
      );
      buffer.writeln();
    }

    // Add personalization based on order history
    if (userOrderHistory != null && userOrderHistory.isNotEmpty) {
      buffer.writeln('User Purchase History:');
      buffer.writeln(
        'The user has previously ordered from categories: '
        '${userOrderHistory.join(", ")}',
      );
      buffer.writeln(
        'Please personalize the description to align with their interests.',
      );
      buffer.writeln();
    }

    buffer.writeln('Requirements:');
    buffer.writeln('1. Create an engaging, professional description');
    buffer.writeln(
      '2. Highlight key features, benefits, and value proposition',
    );
    buffer.writeln('3. Use the price point to emphasize value');
    buffer.writeln('4. Reference the high rating if applicable (>4.0)');
    buffer.writeln('5. Keep it concise (3-5 paragraphs)');
    buffer.writeln('6. Use friendly yet professional tone');
    if (userOrderHistory != null && userOrderHistory.isNotEmpty) {
      buffer.writeln('7. Subtly connect to user\'s past purchase preferences');
    }
    buffer.writeln();
    buffer.writeln(
      'Generate only the product description without any prefix or meta-text.',
    );

    return buffer.toString();
  }
}
