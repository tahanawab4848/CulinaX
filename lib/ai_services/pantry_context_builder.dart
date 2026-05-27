import '../models/pantry_context.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../services/recipe_engine.dart';

class PantryContextBuilder {
  static PantryContext build({
    required List<PantryItem> pantryItems,
    required List<Recipe> recipes,
    required bool budgetMode,
    required String cuisinePreference,
    required String diet,
    String mealTimeHint = 'any',
    String? cuisineFilter,
    bool eidOnly = false,
    bool leftoverOnly = false,
  }) {
    final active = pantryItems.where((i) => !i.isUsed && i.quantity > 0).toList();
    final now = DateTime.now();

    final expiring = active
        .where((i) => i.expiryDate != null)
        .map((i) {
          final days = i.expiryDate!.difference(now).inDays;
          return ExpiringItemInfo(name: i.itemName, daysLeft: days);
        })
        .where((e) => e.daysLeft >= 0 && e.daysLeft <= 3)
        .toList();

    final lowStock = active
        .where((i) => i.isLowStock)
        .map((i) => LowStockItemInfo(name: i.itemName))
        .toList();

    final ranked = RecipeEngine.rankRecipes(
      recipes,
      active,
      budgetMode: budgetMode,
      cuisineFilter: cuisineFilter,
      eidOnly: eidOnly,
      leftoverOnly: leftoverOnly,
    );

    final summaries = ranked.take(5).map((m) {
      return RecipeMatchSummary(
        recipeName: m.recipe.name,
        matchPercent: m.matchPercent,
        missing: m.missing,
        available: m.available,
      );
    }).toList();

    return PantryContext(
      pantryItems: active.map((i) => i.itemName).toList(),
      expiringItems: expiring,
      lowStockItems: lowStock,
      topMatches: summaries,
      budgetMode: budgetMode,
      cuisinePreference: cuisinePreference,
      diet: diet,
      mealTimeHint: mealTimeHint,
      recipeCount: recipes.length,
    );
  }
}
