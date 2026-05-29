import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = context.watch<RecipeProvider>();
    final pantry = context.watch<PantryProvider>();

    recipes.rankForPantry(pantry.activeItems);
    final ranked = recipes.rankedMatches;

    return Scaffold(
      backgroundColor: C.dark2,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RECIPES', style: T.lbl(c: C.g400)),
                  Text('Pakistani Kitchen', style: T.head(20)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: recipes.setSearchQuery,
                    style: T.body(14, c: C.white),
                    decoration: const InputDecoration(
                      hintText: 'Search biryani, daal, nihari…',
                      prefixIcon: Icon(Icons.search, color: C.g400),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: AppConstants.cuisines.map((c) {
                  final sel = recipes.cuisineFilter == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c, style: T.sub(12)),
                      selected: sel,
                      onSelected: (_) => recipes.setCuisineFilter(c),
                      backgroundColor: C.card,
                      selectedColor: C.g700,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: AppConstants.difficulties.map((d) {
                  final sel = recipes.difficultyFilter == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: sel,
                      onSelected: (_) => recipes.setDifficultyFilter(d),
                    ),
                  );
                }).toList(),
              ),
            ),
            SwitchListTile(
              title: Text('Budget Cooking Mode', style: T.sub(14)),
              subtitle: Text('Student / hostel friendly', style: T.body(12, c: C.white40)),
              value: recipes.budgetMode,
              activeThumbColor: C.g500,
              onChanged: recipes.setBudgetMode,
            ),
            Expanded(
              child: recipes.loading
                  ? const Center(child: CircularProgressIndicator(color: C.g500))
                  : ranked.isEmpty
                      ? Center(child: Text('No recipes found', style: T.head(18)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: ranked.length,
                          itemBuilder: (ctx, i) {
                            final m = ranked[i];
                            return RecipeCard(
                              recipe: m.recipe,
                              matchPercent: m.matchPercent,
                              missingCount: m.missing.length,
                              isFullMatch: m.isFullMatch,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    recipe: m.recipe,
                                    match: m,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
