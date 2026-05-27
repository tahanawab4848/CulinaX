import 'recipe.dart';

/// Rule-based score + AI-generated explanation.
class HybridRecommendation {
  final RecipeMatch match;
  final String aiExplanation;
  final List<String> aiReasons;
  final bool explanationLoading;
  final String? explanationError;

  const HybridRecommendation({
    required this.match,
    this.aiExplanation = '',
    this.aiReasons = const [],
    this.explanationLoading = false,
    this.explanationError,
  });

  HybridRecommendation copyWith({
    String? aiExplanation,
    List<String>? aiReasons,
    bool? explanationLoading,
    String? explanationError,
  }) {
    return HybridRecommendation(
      match: match,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      aiReasons: aiReasons ?? this.aiReasons,
      explanationLoading: explanationLoading ?? this.explanationLoading,
      explanationError: explanationError,
    );
  }
}
