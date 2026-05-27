import '../models/hybrid_recommendation.dart';
import '../models/pantry_context.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../services/recipe_engine.dart';
import 'ai_chef_service.dart';
import 'pantry_context_builder.dart';

/// STEP 1: Rule-based scoring. STEP 2: AI explanations.
class HybridRecommendationService {
  final AiChefService _aiChef = AiChefService();

  List<RecipeMatch> computeMatches({
    required List<Recipe> recipes,
    required List<PantryItem> pantry,
    bool budgetMode = false,
    String? cuisineFilter,
    bool eidOnly = false,
    bool leftoverOnly = false,
  }) {
    return RecipeEngine.rankRecipes(
      recipes,
      pantry,
      budgetMode: budgetMode,
      cuisineFilter: cuisineFilter,
      eidOnly: eidOnly,
      leftoverOnly: leftoverOnly,
    );
  }

  Future<HybridRecommendation> enrichWithExplanation({
    required RecipeMatch match,
    required PantryContext context,
  }) async {
    try {
      final explanation = await _aiChef.explainRecommendation(
        context: context,
        recipe: match.recipe,
        matchPercent: match.matchPercent,
        missing: match.missing,
        available: match.available,
      );
      final reasons = _parseReasons(explanation);
      return HybridRecommendation(
        match: match,
        aiExplanation: explanation,
        aiReasons: reasons,
      );
    } catch (e) {
      return HybridRecommendation(
        match: match,
        aiExplanation: _fallbackExplanation(match, context),
        aiReasons: _fallbackReasons(match, context),
        explanationError: e.toString(),
      );
    }
  }

  Future<List<HybridRecommendation>> buildHybridList({
    required List<Recipe> recipes,
    required List<PantryItem> pantry,
    required PantryContext context,
    int limit = 5,
    bool fetchAiExplanations = true,
  }) async {
    final matches = computeMatches(
      recipes: recipes,
      pantry: pantry,
      budgetMode: context.budgetMode,
    ).take(limit).toList();

    if (!fetchAiExplanations) {
      return matches
          .map((m) => HybridRecommendation(
                match: m,
                aiExplanation: _fallbackExplanation(m, context),
                aiReasons: _fallbackReasons(m, context),
              ))
          .toList();
    }

    final results = <HybridRecommendation>[];
    for (final m in matches) {
      results.add(await enrichWithExplanation(match: m, context: context));
    }
    return results;
  }

  List<String> _parseReasons(String text) {
    final lines = text.split('\n');
    final reasons = <String>[];
    var inReasons = false;
    for (final line in lines) {
      if (line.toUpperCase().contains('REASON')) inReasons = true;
      if (line.toUpperCase().startsWith('URDU')) break;
      if (inReasons && line.trim().startsWith('-')) {
        reasons.add(line.trim().replaceFirst('-', '').trim());
      }
    }
    if (reasons.isEmpty && text.isNotEmpty) {
      return [text.split('\n').first.trim()];
    }
    return reasons;
  }

  String _fallbackExplanation(RecipeMatch match, PantryContext ctx) {
    final buf = StringBuffer('Recommended by pantry rules: ');
    buf.write('${match.matchPercent.round()}% ingredient match. ');
    if (match.missing.isEmpty) {
      buf.write('You have all ingredients. ');
    } else {
      buf.write('Missing: ${match.missing.join(", ")}. ');
    }
    if (ctx.expiringItems.isNotEmpty) {
      buf.write('Use ${ctx.expiringItems.first.name} soon. ');
    }
    if (ctx.budgetMode) buf.write('Budget-friendly option.');
    return buf.toString();
  }

  List<String> _fallbackReasons(RecipeMatch match, PantryContext ctx) {
    final r = <String>[
      '${match.matchPercent.round()}% of ingredients available',
    ];
    if (match.missing.isEmpty) r.add('All ingredients in pantry');
    if (ctx.budgetMode && match.recipe.isBudgetFriendly) {
      r.add('Budget mode — affordable meal');
    }
    if (ctx.expiringItems.isNotEmpty) {
      r.add('Uses expiring: ${ctx.expiringItems.first.name}');
    }
    if (match.recipe.cookingTime <= 30) r.add('Quick to cook');
    return r;
  }
}
