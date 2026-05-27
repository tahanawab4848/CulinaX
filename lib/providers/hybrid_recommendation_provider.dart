import 'package:flutter/foundation.dart';

import '../ai_services/hybrid_recommendation_service.dart';
import '../ai_services/pantry_context_builder.dart';
import '../models/hybrid_recommendation.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';

class HybridRecommendationProvider extends ChangeNotifier {
  final HybridRecommendationService _service = HybridRecommendationService();

  List<HybridRecommendation> _recommendations = [];
  bool _loading = false;
  bool _aiExplanationsEnabled = false;
  String? _error;

  List<HybridRecommendation> get recommendations => List.unmodifiable(_recommendations);
  bool get loading => _loading;
  bool get aiExplanationsEnabled => _aiExplanationsEnabled;
  String? get error => _error;

  void setAiExplanations(bool enabled) {
    _aiExplanationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> refresh({
    required List<Recipe> recipes,
    required List<PantryItem> pantry,
    required bool budgetMode,
    required String cuisinePreference,
    required String diet,
    String? cuisineFilter,
    bool eidOnly = false,
    bool leftoverOnly = false,
    int limit = 5,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final context = PantryContextBuilder.build(
        pantryItems: pantry,
        recipes: recipes,
        budgetMode: budgetMode,
        cuisinePreference: cuisinePreference,
        diet: diet,
        cuisineFilter: cuisineFilter,
        eidOnly: eidOnly,
        leftoverOnly: leftoverOnly,
      );

      _recommendations = await _service.buildHybridList(
        recipes: recipes,
        pantry: pantry,
        context: context,
        limit: limit,
        fetchAiExplanations: _aiExplanationsEnabled,
      );
    } catch (e) {
      _error = e.toString();
      final context = PantryContextBuilder.build(
        pantryItems: pantry,
        recipes: recipes,
        budgetMode: budgetMode,
        cuisinePreference: cuisinePreference,
        diet: diet,
      );
      final matches = _service.computeMatches(
        recipes: recipes,
        pantry: pantry,
        budgetMode: budgetMode,
        cuisineFilter: cuisineFilter,
      );
      _recommendations = matches.take(limit).map((m) {
        return HybridRecommendation(
          match: m,
          aiExplanation: 'Rule-based match ${m.matchPercent.round()}%',
          aiReasons: ['${m.matchPercent.round()}% ingredients available'],
        );
      }).toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<HybridRecommendation?> explainOne({
    required RecipeMatch match,
    required List<PantryItem> pantry,
    required List<Recipe> recipes,
    required bool budgetMode,
    required String cuisinePreference,
    required String diet,
  }) async {
    final context = PantryContextBuilder.build(
      pantryItems: pantry,
      recipes: recipes,
      budgetMode: budgetMode,
      cuisinePreference: cuisinePreference,
      diet: diet,
    );
    return _service.enrichWithExplanation(match: match, context: context);
  }
}
