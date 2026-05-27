import 'package:flutter/foundation.dart';

import '../ai_services/ai_chef_service.dart';
import '../ai_services/ai_provider_interface.dart';
import '../core/ai_config.dart';
import '../models/ai_generated_recipe.dart';
import '../models/ai_interaction.dart';
import '../models/pantry_context.dart';
import '../models/recipe.dart';
import '../repositories/ai_repository.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}

class AiChefProvider extends ChangeNotifier {
  final AiChefService _chef = AiChefService();
  final AiRepository _repo = AiRepository();

  final List<AiChatMessage> _messages = [];
  final List<ChatTurn> _history = [];
  bool _loading = false;
  bool _apiConfigured = false;
  String? _error;
  AiGeneratedRecipe? _lastGeneratedRecipe;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  bool get apiConfigured => _apiConfigured;
  String? get error => _error;
  AiGeneratedRecipe? get lastGeneratedRecipe => _lastGeneratedRecipe;

  AiChefProvider() {
    _init();
  }

  Future<void> _init() async {
    _apiConfigured = await AiConfig.isConfigured();
    _messages.add(
      AiChatMessage(
        text: _apiConfigured
            ? 'Assalam o Alaikum! I am your AI Chef — powered by Gemini/OpenAI.\nAsk about recipes, pantry, substitutions, or meal ideas.'
            : 'AI Chef needs an API key. Go to Profile → AI Settings to add your Gemini or OpenAI key.',
        isUser: false,
        time: DateTime.now(),
        isError: !_apiConfigured,
      ),
    );
    notifyListeners();
  }

  Future<void> refreshApiStatus() async {
    _apiConfigured = await AiConfig.isConfigured();
    notifyListeners();
  }

  Future<void> sendMessage(String input, PantryContext context, {String? userId}) async {
    if (input.trim().isEmpty) return;

    _messages.add(
      AiChatMessage(text: input.trim(), isUser: true, time: DateTime.now()),
    );
    _history.add(ChatTurn(role: 'user', content: input.trim()));
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (!await AiConfig.isConfigured()) {
        throw AiException('Configure API key in Profile → AI Settings');
      }
      final reply = await _chef.chat(
        userMessage: input,
        context: context,
        history: _history.length > 10 ? _history.sublist(_history.length - 10) : _history,
      );
      _history.add(ChatTurn(role: 'assistant', content: reply));
      _messages.add(
        AiChatMessage(text: reply, isUser: false, time: DateTime.now()),
      );
      if (userId != null) {
        await _repo.saveInteraction(AiInteraction(
          id: '',
          userId: userId,
          type: 'chat',
          userMessage: input,
          aiResponse: reply,
          createdAt: DateTime.now(),
        ));
      }
    } catch (e) {
      _error = e.toString();
      _messages.add(
        AiChatMessage(
          text: _friendlyError(e),
          isUser: false,
          time: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<AiGeneratedRecipe?> generateRecipe(
    PantryContext context, {
    String? mealType,
    String? extraPrompt,
    String? userId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final recipe = await _chef.generateRecipe(
        context: context,
        mealType: mealType,
        extraPrompt: extraPrompt,
      );
      _lastGeneratedRecipe = recipe;
      if (userId != null) {
        await _repo.saveInteraction(AiInteraction(
          id: '',
          userId: userId,
          type: 'recipe_generate',
          userMessage: extraPrompt ?? 'Generate recipe',
          aiResponse: recipe.name,
          createdAt: DateTime.now(),
        ));
      }
      return recipe;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> getSubstitutions(String ingredient, PantryContext context) async {
    _loading = true;
    notifyListeners();
    try {
      return await _chef.suggestSubstitutions(
        ingredient: ingredient,
        context: context,
      );
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> getStepGuidance({
    required Recipe recipe,
    required int stepIndex,
    required PantryContext context,
  }) async {
    try {
      return await _chef.cookingGuidance(
        recipe: recipe,
        stepIndex: stepIndex,
        context: context,
      );
    } catch (e) {
      return 'Tip: Follow the step carefully. Add spices gradually. — $e';
    }
  }

  Future<String?> getMealRecommendations(
    PantryContext context,
    String mealType,
  ) async {
    _loading = true;
    notifyListeners();
    try {
      return await _chef.recommendMeals(context: context, mealType: mealType);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _history.clear();
    _init();
  }

  /// Converts raw API errors into a clean, user-friendly single line message.
  String _friendlyError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('quota') || raw.contains('rate') || raw.contains('429') || raw.contains('limit')) {
      return '⏳ Daily AI quota reached. Please wait a few minutes and try again, or generate a fresh API key at aistudio.google.com/apikey and update it in your Run Configuration.';
    }
    if (raw.contains('api key') || raw.contains('invalid') || raw.contains('401') || raw.contains('403')) {
      return '🔑 Invalid or missing API key. Add a valid Gemini key via Android Studio Run Configuration: --dart-define=GEMINI_API_KEY=your_key';
    }
    if (raw.contains('network') || raw.contains('socket') || raw.contains('timeout') || raw.contains('connection')) {
      return '📡 No internet connection. Please check your network and try again.';
    }
    return '⚠️ AI Chef is temporarily unavailable. Please try again in a moment.';
  }
}
