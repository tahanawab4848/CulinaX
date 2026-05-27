import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ai_services/pantry_context_builder.dart';
import '../models/pantry_context.dart';
import '../core/theme.dart';
import '../models/recipe.dart';
import '../providers/ai_chef_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/grocery_provider.dart';
import '../providers/hybrid_recommendation_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/desi_substitutions.dart';
import 'cooking_mode_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final RecipeMatch? match;

  const RecipeDetailScreen({super.key, required this.recipe, this.match});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _servings = 4;
  String? _aiExplanation;
  bool _loadingExplanation = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
  }

  PantryContext _context() {
    final pantry = context.read<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    return PantryContextBuilder.build(
      pantryItems: pantry.activeItems,
      recipes: recipes.recipes,
      budgetMode: recipes.budgetMode,
      cuisinePreference:
          auth.profile?.preferences.cuisinePreference ?? 'Punjabi',
      diet: auth.profile?.preferences.diet ?? 'None',
    );
  }

  Future<void> _loadAiExplanation(RecipeMatch match) async {
    setState(() => _loadingExplanation = true);
    final pantry = context.read<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    final hybrid = await context.read<HybridRecommendationProvider>().explainOne(
          match: match,
          pantry: pantry.activeItems,
          recipes: recipes.recipes,
          budgetMode: recipes.budgetMode,
          cuisinePreference:
              auth.profile?.preferences.cuisinePreference ?? 'Punjabi',
          diet: auth.profile?.preferences.diet ?? 'None',
        );
    if (mounted) {
      setState(() {
        _aiExplanation = hybrid?.aiExplanation;
        _loadingExplanation = false;
      });
    }
  }

  Future<void> _aiSubstitute(String ingredient) async {
    final text = await context.read<AiChefProvider>().getSubstitutions(
          ingredient,
          _context(),
        );
    if (!mounted || text == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.dark3,
        title: Text('AI Substitutes for $ingredient', style: T.head(16)),
        content: SingleChildScrollView(child: Text(text, style: T.body(14))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _aiStepHelp(int index) async {
    final text = await context.read<AiChefProvider>().getStepGuidance(
          recipe: widget.recipe,
          stepIndex: index,
          context: _context(),
        );
    if (!mounted || text == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: C.dark3,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Step ${index + 1} Guide', style: T.head(16, c: C.v400)),
            const SizedBox(height: 12),
            Text(text, style: T.body(14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final match = widget.match ??
        recipes.getMatch(widget.recipe, pantry.activeItems);
    final isMatch = match?.isFullMatch ?? false;

    return Scaffold(
      backgroundColor: C.dark2,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: C.dark3,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.recipe.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          widget.recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: C.dark4),
                        )
                      : Image.network(
                          widget.recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: C.dark4),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xF0030A06)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(widget.recipe.difficulty, C.a500),
                      const SizedBox(width: 8),
                      _Badge('${widget.recipe.cookingTime} min', C.t500),
                      const SizedBox(width: 8),
                      _Badge(widget.recipe.cuisineType, C.v500),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.recipe.name, style: T.hero(26)),
                  const SizedBox(height: 8),
                  Text(widget.recipe.description, style: T.body(15)),
                  const SizedBox(height: 16),
                  if (match != null) ...[
                    _MatchBanner(match: match),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _loadingExplanation
                          ? null
                          : () => _loadAiExplanation(match),
                      icon: _loadingExplanation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('AI: Why this recipe?'),
                    ),
                    if (_aiExplanation != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: D.glow(C.v500, r: 14),
                        child: Text(_aiExplanation!, style: T.body(13)),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Servings', style: T.sub(14)),
                      const Spacer(),
                      IconButton(
                        onPressed: _servings > 1
                            ? () => setState(() => _servings--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_servings', style: T.head(18)),
                      IconButton(
                        onPressed: () => setState(() => _servings++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Ingredients', style: T.head(18)),
                  const SizedBox(height: 10),
                  ...widget.recipe.ingredients.map((ing) {
                    final has = match?.available.contains(ing) ?? false;
                    final subs = DesiSubstitutions.getSubstitutes(ing);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: D.card(r: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                has ? Icons.check_circle : Icons.cancel_outlined,
                                color: has ? C.g500 : C.a500,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(ing, style: T.sub(14))),
                              if (!has)
                                IconButton(
                                  icon: const Icon(Icons.psychology, size: 18, color: C.v400),
                                  onPressed: () => _aiSubstitute(ing),
                                  tooltip: 'AI substitutes',
                                ),
                            ],
                          ),
                          if (subs.isNotEmpty && !has)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 26),
                              child: Text(
                                'Rule-based: ${subs.join(', ')}',
                                style: T.body(11, c: C.t400),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Text('Steps', style: T.head(18)),
                  const SizedBox(height: 10),
                  ...widget.recipe.steps.asMap().entries.map(
                        (e) => GestureDetector(
                          onTap: () => _aiStepHelp(e.key),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: C.g700,
                                  child: Text('${e.key + 1}', style: T.sub(11)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(e.value, style: T.body(14))),
                                const Icon(Icons.psychology_outlined,
                                    size: 16, color: C.v400),
                              ],
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await context.read<GroceryProvider>().generateFromRecipes(
                              [widget.recipe],
                              pantry.activeItems,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added missing items to grocery list'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Add to Grocery'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => recipes.toggleFavorite(widget.recipe.id),
                        icon: Icon(
                          recipes.isFavorite(widget.recipe.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: C.r400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CookingModeScreen(
                            recipe: widget.recipe,
                            servings: _servings,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(isMatch ? 'Start AI Guided Cooking' : 'Cook Anyway'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: T.lbl(c: color).copyWith(fontSize: 10)),
    );
  }
}

class _MatchBanner extends StatelessWidget {
  final RecipeMatch match;
  const _MatchBanner({required this.match});

  @override
  Widget build(BuildContext context) {
    final color = match.isFullMatch ? C.g500 : C.a500;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${match.matchPercent.round()}% match (rule-based)',
            style: T.sub(15, c: color),
          ),
          if (match.missing.isNotEmpty)
            Text(
              'Missing: ${match.missing.join(', ')}',
              style: T.body(12, c: C.white40),
            ),
        ],
      ),
    );
  }
}
