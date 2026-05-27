import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/ai_generated_recipe.dart';

class AiRecipeCard extends StatelessWidget {
  final AiGeneratedRecipe recipe;
  final VoidCallback? onOpen;
  final VoidCallback? onSave;

  const AiRecipeCard({
    super.key,
    required this.recipe,
    this.onOpen,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: D.glow(C.v500, r: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: C.v600.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: C.v400, size: 16),
                const SizedBox(width: 8),
                Text('AI GENERATED', style: T.lbl(c: C.v400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, style: T.head(18)),
                const SizedBox(height: 6),
                Text(recipe.description, style: T.body(13, c: C.white70)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip('${recipe.cookingTimeMinutes}m'),
                    _chip(recipe.difficulty),
                    _chip(recipe.cuisineType),
                    _chip('${recipe.servings} servings'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${recipe.ingredients.length} ingredients · ${recipe.steps.length} steps',
                  style: T.body(12, c: C.white40),
                ),
                if (recipe.tips != null) ...[
                  const SizedBox(height: 8),
                  Text('💡 ${recipe.tips}', style: T.body(12, c: C.t400)),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (onOpen != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onOpen,
                          child: const Text('View Recipe'),
                        ),
                      ),
                    if (onSave != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onSave,
                        icon: const Icon(Icons.bookmark_add_outlined, color: C.a400),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: C.card2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: T.lbl().copyWith(fontSize: 9)),
    );
  }
}
