import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/ai_config.dart';
import 'ai_provider_interface.dart';

/// Groq API implementation — OpenAI-compatible, completely free tier.
/// Free tier: 14,400 requests/day · 500,000 tokens/day · ~1s response time.
/// Models: llama-3.3-70b-versatile (default), llama-3.1-8b-instant (faster)
class GroqAiService implements AiProviderInterface {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    List<ChatTurn>? history,
  }) async {
    final key = await AiConfig.getGroqKey();
    if (key == null || key.isEmpty) {
      throw AiException('Groq API key not set. Get a free key at console.groq.com');
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (history != null) {
      for (final turn in history) {
        messages.add({'role': turn.role, 'content': turn.content});
      }
    }

    messages.add({'role': 'user', 'content': userPrompt});

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 1024,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['choices']?[0]?['message']?['content'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw AiException('Empty response from Groq.');
      }
      return text.trim();
    }

    // Parse Groq error message
    try {
      final err = jsonDecode(response.body);
      final msg = err['error']?['message'] ?? 'Unknown Groq error';
      throw AiException(_friendlyGroqError(response.statusCode, msg));
    } catch (e) {
      if (e is AiException) rethrow;
      throw AiException('Groq API error ${response.statusCode}');
    }
  }

  String _friendlyGroqError(int code, String raw) {
    if (code == 429) {
      return '⏳ Groq rate limit reached. Wait a moment and try again. '
          '(Free tier: 30 req/min, 14,400 req/day)';
    }
    if (code == 401) {
      return '🔑 Invalid Groq API key. Get a free key at console.groq.com';
    }
    if (code == 503 || code == 500) {
      return '📡 Groq servers are temporarily busy. Try again in a moment.';
    }
    return '⚠️ Groq error ($code): $raw';
  }
}
