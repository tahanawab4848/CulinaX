/// Converts desi measurements to standard metric for internal logic.
class MeasurementConverter {
  static const Map<String, double> toGrams = {
    'piece': 1.0,
    'chutki': 0.5,
    'pinch': 0.5,
    'katori': 150,
    'pao': 250,
    'cup': 240,
    'tablespoon': 15,
    'tbsp': 15,
    'teaspoon': 5,
    'tsp': 5,
    'gram': 1,
    'g': 1,
    'kg': 1000,
    'ml': 1,
    'liter': 1000,
    'l': 1000,
  };

  static double toStandardGrams(double amount, String unit) {
    final key = unit.trim().toLowerCase();
    final factor = toGrams[key] ?? 1;
    return amount * factor;
  }

  static String formatDesi(double grams) {
    if (grams < 2) return '${grams.toStringAsFixed(1)} chutki';
    if (grams < 20) return '${(grams / 5).toStringAsFixed(1)} tsp';
    if (grams < 80) return '${(grams / 15).toStringAsFixed(1)} tbsp';
    if (grams < 200) return '${(grams / 150).toStringAsFixed(1)} katori';
    return '${(grams / 1000).toStringAsFixed(2)} kg';
  }

  static const List<String> desiUnits = [
    'piece',
    'chutki',
    'katori',
    'pao',
    'cup',
    'tablespoon',
    'teaspoon',
    'gram',
    'kg',
    'ml',
    'liter',
  ];
}
