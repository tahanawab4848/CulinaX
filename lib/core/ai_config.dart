import 'package:shared_preferences/shared_preferences.dart';

enum AiProviderType { gemini, openai }

/// API keys via Profile settings or --dart-define=GEMINI_API_KEY=xxx
class AiConfig {
  static const geminiDefineKey = 'GEMINI_API_KEY';
  static const openAiDefineKey = 'OPENAI_API_KEY';
  static const prefsGeminiKey = 'gemini_api_key';
  static const prefsOpenAiKey = 'openai_api_key';
  static const prefsProviderKey = 'ai_provider_type';

  static Future<String?> getGeminiKey() async {
    const fromEnv = String.fromEnvironment(geminiDefineKey);
    if (fromEnv.isNotEmpty) return fromEnv;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsGeminiKey);
  }

  static Future<String?> getOpenAiKey() async {
    const fromEnv = String.fromEnvironment(openAiDefineKey);
    if (fromEnv.isNotEmpty) return fromEnv;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsOpenAiKey);
  }

  static Future<void> saveGeminiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsGeminiKey, key.trim());
  }

  static Future<void> saveOpenAiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsOpenAiKey, key.trim());
  }

  static Future<AiProviderType> getProviderType() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(prefsProviderKey) ?? 'gemini';
    return v == 'openai' ? AiProviderType.openai : AiProviderType.gemini;
  }

  static Future<void> setProviderType(AiProviderType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsProviderKey,
      type == AiProviderType.openai ? 'openai' : 'gemini',
    );
  }

  static Future<bool> isConfigured() async {
    final type = await getProviderType();
    if (type == AiProviderType.openai) {
      final k = await getOpenAiKey();
      return k != null && k.isNotEmpty;
    }
    final k = await getGeminiKey();
    return k != null && k.isNotEmpty;
  }
}
