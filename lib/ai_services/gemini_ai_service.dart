import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/ai_config.dart';
import 'ai_provider_interface.dart';

class GeminiAiService implements AiProviderInterface {
  static const _model = 'gemini-1.5-flash';

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    List<ChatTurn>? history,
  }) async {
    final key = await AiConfig.getGeminiKey();
    if (key == null || key.isEmpty) {
      throw AiException('Gemini API key not set.');
    }

    final model = GenerativeModel(
      model: _model,
      apiKey: key,
      systemInstruction: Content.system(systemPrompt),
    );

    final contents = <Content>[];
    if (history != null) {
      for (final turn in history) {
        if (turn.role == 'user') {
          contents.add(Content.text(turn.content));
        } else {
          contents.add(Content.model([TextPart(turn.content)]));
        }
      }
    }
    contents.add(Content.text(userPrompt));

    final response = await model.generateContent(contents);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw AiException('Empty response from Gemini.');
    }
    return text;
  }
}
