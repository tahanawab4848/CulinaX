import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/meal_plan_entry.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../services/firestore_service.dart';
import '../services/recipe_engine.dart';

class MealPlannerProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<MealPlanEntry> _entries = [];
  StreamSubscription? _sub;
  String? _userId;

  List<MealPlanEntry> get entries => List.unmodifiable(_entries);

  void bindUser(String? userId) {
    _sub?.cancel();
    _userId = userId;
    if (userId == null) {
      _entries = [];
      notifyListeners();
      return;
    }
    _sub = _firestore.watchMealPlan(userId).listen((list) {
      _entries = list;
      notifyListeners();
    });
  }

  MealPlanEntry? getEntry(int dayIndex, String mealType) {
    try {
      return _entries.firstWhere(
        (e) => e.dayIndex == dayIndex && e.mealType == mealType,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setMeal({
    required int dayIndex,
    required String mealType,
    Recipe? recipe,
  }) async {
    if (_userId == null) return;
    final existing = getEntry(dayIndex, mealType);
    final entry = MealPlanEntry(
      id: existing?.id ?? '',
      userId: _userId!,
      dayIndex: dayIndex,
      mealType: mealType,
      recipeId: recipe?.id,
      recipeName: recipe?.name,
      plannedDate: DateTime.now().add(Duration(days: dayIndex)),
    );
    await _firestore.setMealPlanEntry(entry);
  }

  Future<void> clearMeal(int dayIndex, String mealType) async {
    final existing = getEntry(dayIndex, mealType);
    if (existing != null) {
      await _firestore.deleteMealPlanEntry(existing.id);
    }
  }

  List<Recipe> suggestWeeklyMeals({
    required List<Recipe> recipes,
    required List<PantryItem> pantry,
    bool budgetMode = false,
  }) {
    return RecipeEngine.rankRecipes(
      recipes,
      pantry,
      budgetMode: budgetMode,
    ).map((m) => m.recipe).take(7).toList();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
