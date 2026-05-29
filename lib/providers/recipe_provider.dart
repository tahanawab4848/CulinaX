import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/pakistani_recipes.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../services/firestore_service.dart';
import '../services/recipe_engine.dart';

class RecipeProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<Recipe> _recipes = [];
  StreamSubscription? _sub;
  List<RecipeMatch> _rankedMatches = [];
  Set<String> _favorites = {};
  String _searchQuery = '';
  String _difficultyFilter = 'All';
  String _cuisineFilter = 'All';
  bool _eidOnly = false;
  bool _leftoverOnly = false;
  bool _budgetMode = false;
  bool _loading = true;

  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<RecipeMatch> get rankedMatches => List.unmodifiable(_rankedMatches);
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  String get difficultyFilter => _difficultyFilter;
  String get cuisineFilter => _cuisineFilter;
  bool get eidOnly => _eidOnly;
  bool get leftoverOnly => _leftoverOnly;
  bool get budgetMode => _budgetMode;

  List<Recipe> get filteredRecipes {
    return _recipes.where((r) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty || r.name.toLowerCase().contains(q);
      final matchesDiff = _difficultyFilter == 'All' ||
          r.difficulty == _difficultyFilter;
      return matchesSearch && matchesDiff;
    }).toList();
  }

  Future<void> init() async {
    if (_recipes.isNotEmpty && !_loading) return; // Already initialized!
    _sub?.cancel();
    _loading = true;
    notifyListeners();
    await _loadFavorites();
    // Run image migration once to fix broken Firestore imageUrls
    _patchImageUrls();

    // Listen to Firestore recipes. If empty or fails (e.g. permission/network issues), 
    // we gracefully fall back to local Pakistani recipes. Bypasses client-side seeding 
    // to prevent write permission blocks.
    _sub = _firestore.watchRecipes().listen((list) {
      _recipes = list.isEmpty ? kPakistaniRecipes : list;
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Firestore watchRecipes failed, using local fallback: $e');
      _recipes = kPakistaniRecipes;
      _loading = false;
      notifyListeners();
    });
  }

  /// One-time migration: patches stale Firestore imageUrls to local asset paths.
  Future<void> _patchImageUrls() async {
    const migrationKey = 'image_migration_v1_done';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(migrationKey) == true) return; // Already ran
    try {
      await _firestore.patchRecipeImages({
        'sindhi_biryani':  'assets/images/sindhi_biryani.png',
        'sajji_balochi':   'assets/images/balochi_sajji.png',
        'rogan_josh':      'assets/images/kashmiri_rogan_josh.png',
        'sheer_khurma':    'assets/images/sheer_khurma.png',
        'chana_chaat':     'assets/images/chana_chaat.png',
        'chapli_kebab':    'assets/images/chapli_kebab.png',
      });
      await prefs.setBool(migrationKey, true);
      debugPrint('Image URL migration completed successfully.');
    } catch (e) {
      debugPrint('Image URL migration failed (will retry next launch): $e');
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = (prefs.getStringList('favorites') ?? []).toSet();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }

  bool isFavorite(String recipeId) => _favorites.contains(recipeId);

  Future<void> toggleFavorite(String recipeId) async {
    if (_favorites.contains(recipeId)) {
      _favorites.remove(recipeId);
    } else {
      _favorites.add(recipeId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setDifficultyFilter(String d) {
    _difficultyFilter = d;
    notifyListeners();
  }

  void setCuisineFilter(String c) {
    _cuisineFilter = c;
    _eidOnly = c == 'Eid Special';
    _leftoverOnly = c == 'Leftover';
    notifyListeners();
  }

  void setBudgetMode(bool v) {
    _budgetMode = v;
    notifyListeners();
  }

  void rankForPantry(List<PantryItem> pantry) {
    _rankedMatches = RecipeEngine.rankRecipes(
      filteredRecipes,
      pantry,
      budgetMode: _budgetMode,
      cuisineFilter: _cuisineFilter,
      eidOnly: _eidOnly,
      leftoverOnly: _leftoverOnly,
    );
  }

  RecipeMatch? getMatch(Recipe recipe, List<PantryItem> pantry) {
    return RecipeEngine.scoreRecipe(recipe, pantry);
  }

  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => _favorites.contains(r.id)).toList();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
