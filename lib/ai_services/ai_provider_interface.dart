/// Abstraction for Gemini / OpenAI generative backends.
abstract class AiProviderInterface {
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    List<ChatTurn>? history,
  });
}

class ChatTurn {
  final String role;
  final String content;
  const ChatTurn({required this.role, required this.content});
}

class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => message;
}
