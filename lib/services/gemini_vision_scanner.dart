import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/ai_config.dart';
import '../data/ingredient_label_map.dart';

/// Uses either Gemini 1.5 Flash or Groq Llama 3.2 Vision depending on the active provider.
/// Falls back gracefully to on-device ML Kit if both fail or quota is exceeded.
class GeminiVisionScanner {
  static const _geminiModel = 'gemini-1.5-flash';
  static const _groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  static const _prompt = '''
You are a food ingredient identifier for a Pakistani cooking app.

Identify the single primary/dominant raw food ingredient, vegetable, fruit, meat, dairy product, grain, or lentil visible in this image. We only want the specific name of this one main item.

Return ONLY a valid JSON array containing exactly ONE item. No explanations, no markdown, just the JSON array.

Each item must have these exact keys:
- "nameEn": English ingredient name (specific, e.g. "Tomato" or "Garlic")
- "nameUr": Urdu/Pakistani name (e.g. "Tamatar" or "Lehsan")
- "category": exactly one of these: Vegetable, Fruit, Protein, Dairy, Grain, Lentil, Spice, Herb, Oil & Fat, Condiment, Nut & Dry Fruit, Sweetener, Beverage
- "icon": one relevant emoji
- "confidence": 1.0

Example output:
[
  {"nameEn":"Tomato","nameUr":"Tamatar","category":"Vegetable","icon":"🍅","confidence":1.0}
]

Important rules:
- Identify ONLY the single primary/dominant food item in the image.
- Do NOT list background objects, plates, bowls, utensils, tables, or packaging.
- Pakistani/desi ingredients must use their specific name (e.g. "Masoor Daal" or "Kashmiri Lal Mirch").
''';

  /// Returns detected ingredients or throws an exception.
  Future<List<DetectedIngredient>> scan(File imageFile) async {
    final type = await AiConfig.getProviderType();

    if (type == AiProviderType.groq) {
      return _scanWithGroq(imageFile);
    } else {
      return _scanWithGemini(imageFile);
    }
  }

  Future<List<DetectedIngredient>> _scanWithGemini(File imageFile) async {
    final key = await AiConfig.getGeminiKey();
    if (key == null || key.isEmpty) {
      throw Exception('No Gemini API key configured.');
    }

    final model = GenerativeModel(model: _geminiModel, apiKey: key);
    final imageBytes = await imageFile.readAsBytes();
    final mimeType = _mimeType(imageFile.path);

    final response = await model.generateContent([
      Content.multi([
        TextPart(_prompt),
        DataPart(mimeType, imageBytes),
      ])
    ]);

    final text = response.text?.trim() ?? '';
    return _parseResults(text);
  }

  Future<List<DetectedIngredient>> _scanWithGroq(File imageFile) async {
    final key = await AiConfig.getGroqKey();
    if (key == null || key.isEmpty) {
      throw Exception('No Groq API key configured.');
    }

    final imageBytes = await imageFile.readAsBytes();
    final mimeType = _mimeType(imageFile.path);
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      },
      body: jsonEncode({
        'model': _groqModel,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _prompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          }
        ],
        'temperature': 0.2,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['choices']?[0]?['message']?['content'] as String?;
      return _parseResults(text ?? '');
    } else {
      throw Exception('Groq Vision API Error: ${response.statusCode} ${response.body}');
    }
  }

  List<DetectedIngredient> _parseResults(String text) {
    if (text.isEmpty) return [];

    // Extract JSON array from response (handles extra text/markdown wrapper)
    final jsonMatch = RegExp(r'\[[\s\S]*?\]').firstMatch(text);
    if (jsonMatch == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonMatch.group(0)!);
      final results = <DetectedIngredient>[];

      for (final item in jsonList) {
        try {
          results.add(DetectedIngredient(
            nameEn: (item['nameEn'] as String?) ?? 'Unknown',
            nameUr: (item['nameUr'] as String?) ?? '',
            category: _validateCategory(item['category'] as String?),
            icon: (item['icon'] as String?) ?? '🍽️',
            confidence: ((item['confidence'] as num?) ?? 1.0).toDouble(),
          ));
        } catch (_) {
          // skip malformed entries
        }
      }

      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      return results.isNotEmpty ? [results.first] : [];
    } catch (_) {
      return [];
    }
  }

  String _validateCategory(String? raw) {
    const valid = {
      'Vegetable', 'Fruit', 'Protein', 'Dairy', 'Grain', 'Lentil',
      'Spice', 'Herb', 'Oil & Fat', 'Condiment', 'Nut & Dry Fruit',
      'Sweetener', 'Beverage',
    };
    return (raw != null && valid.contains(raw)) ? raw : 'Other';
  }

  String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      default: return 'image/jpeg';
    }
  }
}
