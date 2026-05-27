import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/hybrid_recommendation.dart';

class AiExplanationCard extends StatelessWidget {
  final HybridRecommendation recommendation;
  final VoidCallback? onTap;

  const AiExplanationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = recommendation.match;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: D.glow(C.g500, r: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: C.g500.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${m.matchPercent.round()}%',
                    style: T.sub(13, c: C.g400),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(m.recipe.name, style: T.head(15)),
                ),
                const Icon(Icons.auto_awesome, color: C.v400, size: 18),
              ],
            ),
            if (recommendation.aiReasons.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('WHY AI RECOMMENDS', style: T.lbl(c: C.v400)),
              const SizedBox(height: 6),
              ...recommendation.aiReasons.take(4).map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: C.g400)),
                          Expanded(child: Text(r, style: T.body(12))),
                        ],
                      ),
                    ),
                  ),
            ] else if (recommendation.aiExplanation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                recommendation.aiExplanation,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: T.body(12, c: C.white70),
              ),
            ],
            if (recommendation.explanationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Rule-based only (AI offline)',
                  style: T.body(11, c: C.a400),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
