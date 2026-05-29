import 'package:shared_preferences/shared_preferences.dart';

enum AiProviderType { gemini, openai, groq }

/// API keys via Profile settings or --dart-define=GEMINI_API_KEY=xxx
class AiConfig {
  static const geminiDefineKey = 'GEMINI_API_KEY';
  static const openAiDefineKey = 'OPENAI_API_KEY';
  static const groqDefineKey = 'GROQ_API_KEY';
  
  static const prefsGeminiKey = 'gemini_api_key';
  static const prefsOpenAiKey = 'openai_api_key';
  static const prefsGroqKey = 'groq_api_key';
  
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

  static Future<String?> getGroqKey() async {
    const fromEnv = String.fromEnvironment(groqDefineKey);
    if (fromEnv.isNotEmpty) return fromEnv;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString(prefsGroqKey);
    if (local != null && local.isNotEmpty) return local;
    return null; // Removed hard‑coded Groq API key
  }

  static Future<void> saveGeminiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsGeminiKey, key.trim());
  }

  static Future<void> saveOpenAiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsOpenAiKey, key.trim());
  }

  static Future<void> saveGroqKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsGroqKey, key.trim());
  }

  static Future<AiProviderType> getProviderType() async {
    return AiProviderType.groq;
  }

  static Future<void> setProviderType(AiProviderType type) async {
    // No-op to preserve forced Groq configuration
  }

  static Future<bool> isConfigured() async {
    final k = await getGroqKey();
    return k != null && k.isNotEmpty;
  }
}
