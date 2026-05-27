import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../utils/desi_substitutions.dart';

/// Rule-based recipe intelligence: matching, ranking, missing detection.
class RecipeEngine {
  static Set<String> _normalizePantryNames(List<PantryItem> items) {
    return items
        .where((i) => !i.isUsed && i.quantity > 0)
        .map((i) => i.normalizedName)
        .toSet();
  }

  static bool _hasIngredient(String required, Set<String> pantry) {
    final req = required.trim().toLowerCase();
    for (final p in pantry) {
      if (p == req || p.contains(req) || req.contains(p)) return true;
      if (DesiSubstitutions.canSubstitute(required, p)) return true;
    }
    return false;
  }

  static RecipeMatch scoreRecipe(Recipe recipe, List<PantryItem> pantry) {
    final pantryNames = _normalizePantryNames(pantry);
    final available = <String>[];
    final missing = <String>[];
    final substitutions = <String>[];

    for (final ing in recipe.ingredients) {
      if (_hasIngredient(ing, pantryNames)) {
        available.add(ing);
      } else {
        missing.add(ing);
        final subs = DesiSubstitutions.getSubstitutes(ing);
        final foundSub = subs.where((s) => _hasIngredient(s, pantryNames)).toList();
        if (foundSub.isNotEmpty) {
          substitutions.add('$ing → ${foundSub.first}');
        }
      }
    }

    final total = recipe.ingredients.isEmpty ? 1 : recipe.ingredients.length;
    final effectiveAvailable = available.length +
        substitutions.length * 0.5;
    final percent = (effectiveAvailable / total * 100).clamp(0.0, 100.0);

    return RecipeMatch(
      recipe: recipe,
      matchPercent: percent,
      available: available,
      missing: missing,
      substitutions: substitutions,
    );
  }

  static List<RecipeMatch> rankRecipes(
    List<Recipe> recipes,
    List<PantryItem> pantry, {
    bool budgetMode = false,
    String? cuisineFilter,
    bool eidOnly = false,
    bool leftoverOnly = false,
  }) {
    var filtered = recipes.where((r) {
      if (eidOnly && !r.isEidSpecial) return false;
      if (leftoverOnly && !r.isLeftoverRecipe) return false;
      if (budgetMode && !r.isBudgetFriendly) return false;
      if (cuisineFilter != null &&
          cuisineFilter != 'All' &&
          cuisineFilter != 'Budget' &&
          cuisineFilter != 'Leftover' &&
          cuisineFilter != 'Eid Special' &&
          r.cuisineType != cuisineFilter) {
        return false;
      }
      if (cuisineFilter == 'Eid Special' && !r.isEidSpecial) return false;
      if (cuisineFilter == 'Budget' && !r.isBudgetFriendly) return false;
      if (cuisineFilter == 'Leftover' && !r.isLeftoverRecipe) return false;
      return true;
    }).toList();

    final matches = filtered.map((r) => scoreRecipe(r, pantry)).toList();
    matches.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    return matches;
  }

  static List<String> generateGroceryList(
    List<Recipe> selectedRecipes,
    List<PantryItem> pantry,
  ) {
    final pantryNames = _normalizePantryNames(pantry);
    final missing = <String>{};
    for (final recipe in selectedRecipes) {
      for (final ing in recipe.ingredients) {
        if (!_hasIngredient(ing, pantryNames)) {
          missing.add(ing);
        }
      }
    }
    return missing.toList()..sort();
  }

  static List<Recipe> suggestMeals({
    required List<Recipe> recipes,
    required List<PantryItem> pantry,
    required String mealType,
    bool budgetMode = false,
    int maxMinutes = 60,
  }) {
    final ranked = rankRecipes(recipes, pantry, budgetMode: budgetMode);
    return ranked
        .where((m) => m.recipe.cookingTime <= maxMinutes)
        .map((m) => m.recipe)
        .take(5)
        .toList();
  }
}
