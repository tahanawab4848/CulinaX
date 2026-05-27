import 'dart:convert';
import 'recipe.dart';

class AiGeneratedRecipe {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final int cookingTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisineType;
  final String? tips;

  const AiGeneratedRecipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.cookingTimeMinutes = 30,
    this.servings = 4,
    this.difficulty = 'Easy',
    this.cuisineType = 'Pakistani',
    this.tips,
  });

  Recipe toRecipe({String? id}) => Recipe(
        id: id ?? 'ai_${name.hashCode}',
        name: name,
        description: description,
        imageUrl:
            'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
        cookingTime: cookingTimeMinutes,
        servings: servings,
        difficulty: difficulty,
        cuisineType: cuisineType,
        ingredients: ingredients,
        steps: steps,
        isBudgetFriendly: difficulty == 'Easy',
      );

  static AiGeneratedRecipe? tryParseJson(String raw) {
    try {
      var text = raw.trim();
      if (text.contains('```')) {
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}');
        if (start >= 0 && end > start) text = text.substring(start, end + 1);
      }
      final map = jsonDecode(text) as Map<String, dynamic>;
      return AiGeneratedRecipe(
        name: map['name'] as String? ?? 'AI Recipe',
        description: map['description'] as String? ?? '',
        ingredients: List<String>.from(map['ingredients'] ?? []),
        steps: List<String>.from(map['steps'] ?? []),
        cookingTimeMinutes: (map['cookingTimeMinutes'] as num?)?.toInt() ?? 30,
        servings: (map['servings'] as num?)?.toInt() ?? 4,
        difficulty: map['difficulty'] as String? ?? 'Easy',
        cuisineType: map['cuisineType'] as String? ?? 'Pakistani',
        tips: map['tips'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
