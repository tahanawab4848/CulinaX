class Recipe {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int cookingTime;
  final int servings;
  final String difficulty;
  final String cuisineType;
  final List<String> ingredients;
  final List<String> steps;
  final bool isEidSpecial;
  final bool isBudgetFriendly;
  final bool isLeftoverRecipe;
  final double estimatedCost;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    this.servings = 4,
    required this.difficulty,
    required this.cuisineType,
    required this.ingredients,
    required this.steps,
    this.isEidSpecial = false,
    this.isBudgetFriendly = false,
    this.isLeftoverRecipe = false,
    this.estimatedCost = 0,
  });

  // Legacy compatibility
  int get idInt => id.hashCode;
  String get title => name;
  int get cookingTimeMinutes => cookingTime;
  List<String> get ingredientsRequired => ingredients;

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      name: map['name'] as String? ?? map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      cookingTime: (map['cookingTime'] as num?)?.toInt() ??
          (map['cookingTimeMinutes'] as num?)?.toInt() ??
          30,
      servings: (map['servings'] as num?)?.toInt() ?? 4,
      difficulty: map['difficulty'] as String? ?? 'Easy',
      cuisineType: map['cuisineType'] as String? ?? 'Punjabi',
      ingredients: List<String>.from(
        map['ingredients'] ?? map['ingredientsRequired'] ?? [],
      ),
      steps: List<String>.from(map['steps'] ?? []),
      isEidSpecial: map['isEidSpecial'] as bool? ?? false,
      isBudgetFriendly: map['isBudgetFriendly'] as bool? ?? false,
      isLeftoverRecipe: map['isLeftoverRecipe'] as bool? ?? false,
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'cookingTime': cookingTime,
        'servings': servings,
        'difficulty': difficulty,
        'cuisineType': cuisineType,
        'ingredients': ingredients,
        'steps': steps,
        'isEidSpecial': isEidSpecial,
        'isBudgetFriendly': isBudgetFriendly,
        'isLeftoverRecipe': isLeftoverRecipe,
        'estimatedCost': estimatedCost,
      };

  Recipe copyWith({int? servings}) => Recipe(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        cookingTime: cookingTime,
        servings: servings ?? this.servings,
        difficulty: difficulty,
        cuisineType: cuisineType,
        ingredients: ingredients,
        steps: steps,
        isEidSpecial: isEidSpecial,
        isBudgetFriendly: isBudgetFriendly,
        isLeftoverRecipe: isLeftoverRecipe,
        estimatedCost: estimatedCost,
      );
}

class RecipeMatch {
  final Recipe recipe;
  final double matchPercent;
  final List<String> available;
  final List<String> missing;
  final List<String> substitutions;

  const RecipeMatch({
    required this.recipe,
    required this.matchPercent,
    required this.available,
    required this.missing,
    this.substitutions = const [],
  });

  bool get isFullMatch => matchPercent >= 99.9;
}
