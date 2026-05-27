import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double matchPercent;
  final int missingCount;
  final bool isFullMatch;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.matchPercent,
    required this.missingCount,
    required this.isFullMatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: D.card(r: 20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                recipe.imageUrl.startsWith('assets/')
                    ? Image.asset(
                        recipe.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: C.dark4,
                          child: const Icon(Icons.restaurant, color: C.white20),
                        ),
                      )
                    : Image.network(
                        recipe.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: C.dark4,
                          child: const Icon(Icons.restaurant, color: C.white20),
                        ),
                      ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFullMatch ? C.g600 : C.dark1.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${matchPercent.round()}%',
                      style: T.sub(12, c: C.white),
                    ),
                  ),
                ),
                if (isFullMatch)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: C.g500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('READY', style: T.lbl(c: C.white).copyWith(fontSize: 9)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: T.head(16)),
                  const SizedBox(height: 6),
                  Text(
                    recipe.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: T.body(13, c: C.white40),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _chip(Icons.timer, '${recipe.cookingTime}m', C.t400),
                      const SizedBox(width: 8),
                      _chip(Icons.flag, recipe.difficulty, C.a400),
                      const SizedBox(width: 8),
                      _chip(Icons.place, recipe.cuisineType, C.v400),
                      const Spacer(),
                      if (missingCount > 0)
                        Text(
                          '$missingCount missing',
                          style: T.sub(11, c: C.a400),
                        ),
                      if (recipe.isBudgetFriendly)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('💰', style: TextStyle(fontSize: 14)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: T.lbl(c: color).copyWith(fontSize: 9, letterSpacing: 0)),
        ],
      ),
    );
  }
}
