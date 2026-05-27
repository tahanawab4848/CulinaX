import '../core/ai_config.dart';
import '../models/ai_generated_recipe.dart';
import '../models/pantry_context.dart';
import '../models/recipe.dart';
import 'ai_provider_interface.dart';
import 'gemini_ai_service.dart';
import 'openai_ai_service.dart';

/// Generative AI layer — sits above rule-based engine.
class AiChefService {
  static const _systemBase = '''
You are CulinaX AI Chef — a Pakistani cooking assistant for students and home cooks.
You help with desi cuisine: Punjabi, Sindhi, Balochi, Kashmiri dishes, hostel meals, Eid food.
Respond warmly. Support English and Urdu (Roman Urdu is fine).
Be practical, budget-aware, and waste-reducing.
When pantry data is provided, use it — do not invent items the user does not have unless suggesting what to buy.
Keep answers concise unless generating a full recipe.
''';

  Future<AiProviderInterface> _provider() async {
    final type = await AiConfig.getProviderType();
    if (type == AiProviderType.openai) return OpenAiAiService();
    return GeminiAiService();
  }

  Future<String> chat({
    required String userMessage,
    required PantryContext context,
    List<ChatTurn>? history,
  }) async {
    final ai = await _provider();
    return ai.complete(
      systemPrompt: '$_systemBase\n\n${context.toPromptBlock()}',
      userPrompt: userMessage,
      history: history,
    );
  }

  Future<AiGeneratedRecipe> generateRecipe({
    required PantryContext context,
    String? mealType,
    String? extraPrompt,
  }) async {
    final ai = await _provider();
    final prompt = '''
Generate ONE Pakistani recipe as valid JSON only (no markdown outside JSON):
{
  "name": "...",
  "description": "...",
  "ingredients": ["..."],
  "steps": ["..."],
  "cookingTimeMinutes": 30,
  "servings": 4,
  "difficulty": "Easy|Medium|Hard",
  "cuisineType": "Punjabi|Sindhi|...",
  "tips": "optional tip"
}
Meal type: ${mealType ?? 'any'}
${extraPrompt ?? ''}
Prefer ingredients from pantry. Budget mode: ${context.budgetMode}.
''';

    final raw = await ai.complete(
      systemPrompt: _systemBase,
      userPrompt: '${context.toPromptBlock()}\n\n$prompt',
    );

    final parsed = AiGeneratedRecipe.tryParseJson(raw);
    if (parsed != null) return parsed;

    return AiGeneratedRecipe(
      name: 'Custom Pakistani Dish',
      description: raw.length > 200 ? '${raw.substring(0, 200)}...' : raw,
      ingredients: context.pantryItems.take(6).toList(),
      steps: ['Follow AI guidance above.', 'Season to taste.', 'Serve hot.'],
      cookingTimeMinutes: 30,
      cuisineType: context.cuisinePreference,
      tips: 'Could not parse structured JSON; showing raw AI output in description.',
    );
  }

  Future<String> explainRecommendation({
    required PantryContext context,
    required Recipe recipe,
    required double matchPercent,
    required List<String> missing,
    required List<String> available,
  }) async {
    final ai = await _provider();
    return ai.complete(
      systemPrompt: _systemBase,
      userPrompt: '''
Explain WHY this recipe is recommended (2-4 short bullet reasons in English, then one Urdu summary line).

Recipe: ${recipe.name}
Match: ${matchPercent.round()}%
Available: ${available.join(', ')}
Missing: ${missing.isEmpty ? 'none' : missing.join(', ')}
Budget mode: ${context.budgetMode}
Expiring items: ${context.expiringItems.map((e) => e.name).join(', ')}

Format:
REASONS:
- reason 1
- reason 2
URDU: one line summary
''',
    );
  }

  Future<String> suggestSubstitutions({
    required String ingredient,
    required PantryContext context,
  }) async {
    final ai = await _provider();
    return ai.complete(
      systemPrompt: _systemBase,
      userPrompt: '''
Suggest 2-3 Pakistani/desi substitutes for: $ingredient
Pantry available: ${context.pantryItems.join(', ')}
Give substitutes from pantry first if possible. Brief English + Urdu names.
''',
    );
  }

  Future<String> cookingGuidance({
    required Recipe recipe,
    required int stepIndex,
    required PantryContext context,
  }) async {
    final ai = await _provider();
    final step = stepIndex < recipe.steps.length
        ? recipe.steps[stepIndex]
        : recipe.steps.last;
    return ai.complete(
      systemPrompt: _systemBase,
      userPrompt: '''
Recipe: ${recipe.name}
Step ${stepIndex + 1}: $step
Explain this step for a beginner (tips, safety, desi technique). Keep under 120 words.
''',
    );
  }

  Future<String> recommendMeals({
    required PantryContext context,
    required String mealType,
  }) async {
    final ai = await _provider();
    return ai.complete(
      systemPrompt: _systemBase,
      userPrompt: '''
${context.toPromptBlock()}

Suggest 3 ${mealType} ideas (Pakistani / hostel-friendly if budget mode).
For each: name, 1-line why, use expiring items when relevant.
Support chai-time snacks if meal type is snack.
''',
    );
  }
}
