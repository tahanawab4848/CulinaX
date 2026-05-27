import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/meal_planner_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<MealPlannerProvider>();
    final recipes = context.watch<RecipeProvider>();
    final pantry = context.watch<PantryProvider>();

    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MEAL PLAN', style: T.lbl(c: C.t400)),
            Text('Weekly Planner', style: T.head(18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              final suggested = planner.suggestWeeklyMeals(
                recipes: recipes.recipes,
                pantry: pantry.activeItems,
                budgetMode: recipes.budgetMode,
              );
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: C.dark3,
                  title: Text('AI Suggestions', style: T.head(18)),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: suggested
                          .map((r) => ListTile(
                                title: Text(r.name, style: T.sub(14)),
                                subtitle: Text(
                                  '${r.cuisineType} · ${r.cookingTime} min',
                                  style: T.body(12, c: C.white40),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.weekDays.length,
        itemBuilder: (ctx, dayIndex) {
          return Card(
            color: C.card,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.weekDays[dayIndex], style: T.head(16, c: C.g400)),
                  const SizedBox(height: 8),
                  ...AppConstants.mealTypes.map((meal) {
                    final entry = planner.getEntry(dayIndex, meal);
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        meal == 'Breakfast'
                            ? Icons.wb_sunny_outlined
                            : meal == 'Lunch'
                                ? Icons.lunch_dining
                                : Icons.dinner_dining,
                        color: C.white40,
                        size: 20,
                      ),
                      title: Text(meal, style: T.lbl()),
                      subtitle: Text(
                        entry?.recipeName ?? 'Tap to assign',
                        style: T.sub(13, c: entry != null ? C.white : C.white40),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: C.white20),
                      onTap: () => _pickRecipe(context, dayIndex, meal),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _pickRecipe(BuildContext context, int dayIndex, String mealType) {
    final recipes = context.read<RecipeProvider>().recipes;
    showModalBottomSheet(
      context: context,
      backgroundColor: C.dark3,
      builder: (ctx) => ListView.builder(
        itemCount: recipes.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return ListTile(
              leading: const Icon(Icons.clear, color: C.r400),
              title: Text('Clear meal', style: T.sub(14, c: C.r400)),
              onTap: () async {
                await context.read<MealPlannerProvider>().clearMeal(dayIndex, mealType);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            );
          }
          final r = recipes[i - 1];
          return ListTile(
            title: Text(r.name, style: T.sub(14)),
            subtitle: Text('${r.cookingTime} min · ${r.difficulty}', style: T.body(12, c: C.white40)),
            onTap: () async {
              await context.read<MealPlannerProvider>().setMeal(
                    dayIndex: dayIndex,
                    mealType: mealType,
                    recipe: r,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }
}
