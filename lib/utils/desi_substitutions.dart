/// Rule-based desi ingredient substitution map.
class DesiSubstitutions {
  static const Map<String, List<String>> substitutions = {
    'yogurt': ['cream', 'dahi', 'sour cream'],
    'dahi': ['yogurt', 'cream'],
    'cream': ['yogurt', 'milk + butter'],
    'atta': ['whole wheat flour', 'maida', 'flour'],
    'maida': ['atta', 'flour'],
    'ghee': ['butter', 'oil'],
    'butter': ['ghee', 'oil'],
    'basmati rice': ['sela rice', 'regular rice', 'chawal'],
    'chicken': ['mutton', 'beef', 'paneer'],
    'mutton': ['chicken', 'beef'],
    'coriander': ['parsley', 'dhania'],
    'green chili': ['red chili powder', 'black pepper'],
    'tomato': ['tomato paste', 'ketchup'],
    'onion': ['shallot', 'leek'],
    'garlic': ['garlic powder', 'hing'],
    'lemon': ['vinegar', 'tamarind'],
    'tamarind': ['lemon', 'vinegar'],
    'cumin': ['caraway', 'jeera powder'],
    'garam masala': ['all spice mix', 'chai masala'],
    'paneer': ['tofu', 'cheese'],
    'besan': ['gram flour', 'maida'],
    'oil': ['ghee', 'butter'],
  };

  static List<String> getSubstitutes(String ingredient) {
    final key = ingredient.trim().toLowerCase();
    for (final entry in substitutions.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return [];
  }

  static bool canSubstitute(String required, String available) {
    final req = required.trim().toLowerCase();
    final avail = available.trim().toLowerCase();
    if (req == avail || req.contains(avail) || avail.contains(req)) {
      return true;
    }
    final subs = getSubstitutes(required);
    return subs.any(
      (s) => avail.contains(s.toLowerCase()) || s.toLowerCase().contains(avail),
    );
  }
}
