import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/hybrid_recommendation_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import '../services/notification_service.dart';
import '../widgets/ai_explanation_card.dart';
import 'ai_chef_screen.dart';
import 'ai_recipe_generator_screen.dart';
import 'recipe_detail_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHybrid());
  }

  void _loadHybrid() {
    final pantry = context.read<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    recipes.rankForPantry(pantry.activeItems);
    context.read<HybridRecommendationProvider>().refresh(
          recipes: recipes.recipes,
          pantry: pantry.activeItems,
          budgetMode: recipes.budgetMode,
          cuisinePreference:
              auth.profile?.preferences.cuisinePreference ?? 'Punjabi',
          diet: auth.profile?.preferences.diet ?? 'None',
          limit: 3,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pantry = context.watch<PantryProvider>();
    final recipes = context.watch<RecipeProvider>();
    final hybrid = context.watch<HybridRecommendationProvider>();

    recipes.rankForPantry(pantry.activeItems);
    final topMatch = recipes.rankedMatches.isNotEmpty
        ? recipes.rankedMatches.first
        : null;

    return Scaffold(
      backgroundColor: C.dark2,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadHybrid(),
          color: C.g500,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HYBRID AI PANTRY', style: T.lbl(c: C.g400)),
                                Text(
                                  'Salam, ${auth.profile?.name ?? auth.user?.displayName ?? 'Chef'}',
                                  style: T.hero(24),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.auto_awesome, color: C.v400),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AiChefScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: D.heroCard(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('What Can I Cook?', style: T.head(17)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: C.v500.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Rules + AI',
                                    style: T.lbl(c: C.v400).copyWith(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              topMatch != null
                                  ? '${topMatch.matchPercent.round()}% match — ${topMatch.recipe.name}'
                                  : 'Add pantry items for smart suggestions',
                              style: T.body(13, c: C.white40),
                            ),
                            if (topMatch != null) ...[
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: () {
                                  NotificationService().notifyCookSuggestion(
                                    topMatch.recipe.name,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailScreen(
                                        recipe: topMatch.recipe,
                                        match: topMatch,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Cook Now'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickBtn(
                              icon: Icons.psychology,
                              label: 'AI Chef',
                              color: C.v500,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AiChefScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickBtn(
                              icon: Icons.restaurant_menu,
                              label: 'AI Recipe',
                              color: C.t500,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AiRecipeGeneratorScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _StatCard(
                            label: 'Pantry',
                            value: '${pantry.activeItems.length}',
                            icon: Icons.kitchen,
                            color: C.g500,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Expiring',
                            value: '${pantry.expiringSoon.length}',
                            icon: Icons.warning_amber,
                            color: C.a500,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Recipes',
                            value: '${recipes.recipes.length}',
                            icon: Icons.restaurant,
                            color: C.t500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('AI Smart Picks', style: T.head(16)),
                          if (hybrid.loading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: C.v400,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step 1: Rule-based score → Step 2: AI explains why',
                        style: T.body(11, c: C.white40),
                      ),
                    ],
                  ),
                ),
              ),
              if (hybrid.recommendations.isEmpty && !hybrid.loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Text(
                      'Add pantry items to see hybrid recommendations',
                      style: T.body(14, c: C.white40),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final rec = hybrid.recommendations[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                      child: AiExplanationCard(
                        recommendation: rec,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(
                              recipe: rec.match.recipe,
                              match: rec.match,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: hybrid.recommendations.length,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: D.glow(color, r: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: T.head(20, c: color)),
            Text(label, style: T.lbl()),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: D.glow(color, r: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: T.sub(13, c: color)),
          ],
        ),
      ),
    );
  }
}
