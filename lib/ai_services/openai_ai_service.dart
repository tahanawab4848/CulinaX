import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/ai_config.dart';
import 'ai_provider_interface.dart';

class OpenAiAiService implements AiProviderInterface {
  static const _url = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    List<ChatTurn>? history,
  }) async {
    final key = await AiConfig.getOpenAiKey();
    if (key == null || key.isEmpty) {
      throw AiException('OpenAI API key not set. Add it in Profile → AI Settings.');
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];
    if (history != null) {
      for (final t in history) {
        messages.add({'role': t.role, 'content': t.content});
      }
    }
    messages.add({'role': 'user', 'content': userPrompt});

    final res = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    );

    if (res.statusCode != 200) {
      throw AiException('OpenAI error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiException('No response from OpenAI.');
    }
    final content = choices.first['message']['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw AiException('Empty OpenAI response.');
    }
    return content.trim();
  }
}
