/// Maps ML Kit image labels → pantry ingredient names (English + Urdu aliases).
class IngredientHint {
  final String nameEn;
  final String nameUr;
  final String category;
  final String icon;

  const IngredientHint(this.nameEn, this.nameUr, this.category, this.icon);
}

class IngredientLabelMap {
  static const Map<String, IngredientHint> labelToIngredient = {
    'tomato': IngredientHint('Tomato', 'Tomato', 'Vegetable', '🍅'),
    'tomatoes': IngredientHint('Tomato', 'Tomato', 'Vegetable', '🍅'),
    'onion': IngredientHint('Onion', 'Pyaz', 'Vegetable', '🧅'),
    'garlic': IngredientHint('Garlic', 'Lehsan', 'Spice', '🧄'),
    'potato': IngredientHint('Potato', 'Aloo', 'Vegetable', '🥔'),
    'potatoes': IngredientHint('Potato', 'Aloo', 'Vegetable', '🥔'),
    'rice': IngredientHint('Basmati Rice', 'Chawal', 'Grain', '🍚'),
    'egg': IngredientHint('Eggs', 'Anday', 'Protein', '🥚'),
    'eggs': IngredientHint('Eggs', 'Anday', 'Protein', '🥚'),
    'chicken': IngredientHint('Chicken', 'Murgh', 'Protein', '🍗'),
    'meat': IngredientHint('Mutton', 'Gosht', 'Protein', '🥩'),
    'beef': IngredientHint('Beef', 'Beef', 'Protein', '🥩'),
    'milk': IngredientHint('Milk', 'Doodh', 'Dairy', '🥛'),
    'cheese': IngredientHint('Cheese', 'Paneer', 'Dairy', '🧀'),
    'bread': IngredientHint('Bread', 'Roti', 'Staple', '🍞'),
    'flour': IngredientHint('Atta', 'Atta', 'Staple', '🌾'),
    'wheat': IngredientHint('Atta', 'Atta', 'Staple', '🌾'),
    'spice': IngredientHint('Garam Masala', 'Masala', 'Spice', '🌶️'),
    'pepper': IngredientHint('Black Pepper', 'Kali Mirch', 'Spice', '🌶️'),
    'carrot': IngredientHint('Carrot', 'Gajar', 'Vegetable', '🥕'),
    'spinach': IngredientHint('Spinach', 'Palak', 'Vegetable', '🥬'),
    'lemon': IngredientHint('Lemon', 'Nimbu', 'Vegetable', '🍋'),
    'yogurt': IngredientHint('Yogurt', 'Dahi', 'Dairy', '🥛'),
    'butter': IngredientHint('Butter', 'Makhan', 'Dairy', '🧈'),
    'oil': IngredientHint('Cooking Oil', 'Tel', 'Staple', '🫒'),
    'lentil': IngredientHint('Masoor Daal', 'Daal', 'Grain', '🫘'),
    'lentils': IngredientHint('Masoor Daal', 'Daal', 'Grain', '🫘'),
    'bean': IngredientHint('Chickpeas', 'Chana', 'Grain', '🫘'),
    'chickpea': IngredientHint('Chickpeas', 'Chana', 'Grain', '🫘'),
    'fish': IngredientHint('Fish', 'Machli', 'Protein', '🐟'),
    'vegetable': IngredientHint('Mixed Vegetables', 'Sabzi', 'Vegetable', '🥬'),
    'fruit': IngredientHint('Fruit', 'Phal', 'Other', '🍎'),
    'ginger': IngredientHint('Ginger', 'Adrak', 'Spice', '🫚'),
    'chili': IngredientHint('Green Chili', 'Hari Mirch', 'Spice', '🌶️'),
    'pepper vegetable': IngredientHint('Bell Pepper', 'Shimla Mirch', 'Vegetable', '🫑'),
  };

  static IngredientHint? matchLabel(String label) {
    final key = label.trim().toLowerCase();
    if (labelToIngredient.containsKey(key)) {
      return labelToIngredient[key];
    }
    for (final entry in labelToIngredient.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }
}

class DetectedIngredient {
  final String nameEn;
  final String nameUr;
  final String category;
  final String icon;
  final double confidence;

  const DetectedIngredient({
    required this.nameEn,
    required this.nameUr,
    required this.category,
    required this.icon,
    required this.confidence,
  });
}
