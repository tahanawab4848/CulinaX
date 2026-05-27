import 'pantry_item.dart';
import 'recipe.dart';

/// Structured snapshot passed to the AI layer (built from rule-based data).
class PantryContext {
  final List<String> pantryItems;
  final List<ExpiringItemInfo> expiringItems;
  final List<LowStockItemInfo> lowStockItems;
  final List<RecipeMatchSummary> topMatches;
  final bool budgetMode;
  final String cuisinePreference;
  final String diet;
  final String mealTimeHint;
  final int recipeCount;

  const PantryContext({
    this.pantryItems = const [],
    this.expiringItems = const [],
    this.lowStockItems = const [],
    this.topMatches = const [],
    this.budgetMode = false,
    this.cuisinePreference = 'Punjabi',
    this.diet = 'None',
    this.mealTimeHint = 'any',
    this.recipeCount = 0,
  });

  String toPromptBlock() {
    final buf = StringBuffer();
    buf.writeln('=== PANTRY (rule-based snapshot) ===');
    if (pantryItems.isEmpty) {
      buf.writeln('Pantry is empty.');
    } else {
      buf.writeln('Items: ${pantryItems.join(", ")}');
    }
    if (expiringItems.isNotEmpty) {
      buf.writeln('Expiring soon (≤3 days):');
      for (final e in expiringItems) {
        buf.writeln('  - ${e.name} (${e.daysLeft} days left)');
      }
    }
    if (lowStockItems.isNotEmpty) {
      buf.writeln('Low stock: ${lowStockItems.map((e) => e.name).join(", ")}');
    }
    buf.writeln('Budget mode: $budgetMode');
    buf.writeln('Cuisine preference: $cuisinePreference');
    buf.writeln('Diet: $diet');
    buf.writeln('Meal time context: $mealTimeHint');
    if (topMatches.isNotEmpty) {
      buf.writeln('Top rule-based recipe matches:');
      for (final m in topMatches.take(5)) {
        buf.writeln(
          '  - ${m.recipeName}: ${m.matchPercent.round()}% match, '
          'missing: ${m.missing.join(", ").isEmpty ? "none" : m.missing.join(", ")}',
        );
      }
    }
    return buf.toString();
  }
}

class ExpiringItemInfo {
  final String name;
  final int daysLeft;
  const ExpiringItemInfo({required this.name, required this.daysLeft});
}

class LowStockItemInfo {
  final String name;
  const LowStockItemInfo({required this.name});
}

class RecipeMatchSummary {
  final String recipeName;
  final double matchPercent;
  final List<String> missing;
  final List<String> available;
  const RecipeMatchSummary({
    required this.recipeName,
    required this.matchPercent,
    required this.missing,
    required this.available,
  });
}
