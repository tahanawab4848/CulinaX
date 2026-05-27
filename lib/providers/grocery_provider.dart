import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/grocery_list.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../services/firestore_service.dart';
import '../services/recipe_engine.dart';

class GroceryProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  GroceryListDoc? _current;
  StreamSubscription? _sub;
  String? _userId;

  List<GroceryItem> get items => _current?.items ?? [];
  int get checkedCount => items.where((i) => i.checked).length;

  void bindUser(String? userId) {
    _sub?.cancel();
    _userId = userId;
    if (userId == null) {
      _current = null;
      notifyListeners();
      return;
    }
    _sub = _firestore.watchGroceryList(userId).listen((doc) {
      _current = doc;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Firestore watchGroceryList failed: $e');
    });
  }

  Future<void> generateFromRecipes(
    List<Recipe> recipes,
    List<PantryItem> pantry,
  ) async {
    if (_userId == null) return;
    final missing = RecipeEngine.generateGroceryList(recipes, pantry);
    final groceryItems =
        missing.map((m) => GroceryItem(name: m)).toList();
    final doc = GroceryListDoc(
      id: _current?.id ?? '',
      userId: _userId!,
      items: groceryItems,
      createdAt: DateTime.now(),
    );
    _current = doc;
    notifyListeners();
    try {
      await _firestore.saveGroceryList(doc);
    } catch (e) {
      debugPrint('Firestore saveGroceryList failed: $e');
    }
  }

  Future<void> addItem(String name) async {
    if (_userId == null) return;
    final existing = List<GroceryItem>.from(items);
    if (existing.any((e) => e.name.toLowerCase() == name.toLowerCase())) {
      return;
    }
    existing.add(GroceryItem(name: name));
    final doc = GroceryListDoc(
      id: _current?.id ?? '',
      userId: _userId!,
      items: existing,
      createdAt: _current?.createdAt ?? DateTime.now(),
    );
    _current = doc;
    notifyListeners();
    try {
      await _firestore.saveGroceryList(doc);
    } catch (e) {
      debugPrint('Firestore addItem failed: $e');
    }
  }

  Future<void> toggleItem(int index) async {
    final list = List<GroceryItem>.from(items);
    if (index < 0 || index >= list.length) return;
    list[index] = list[index].copyWith(checked: !list[index].checked);
    await _save(list);
  }

  Future<void> removeItem(int index) async {
    final list = List<GroceryItem>.from(items);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await _save(list);
  }

  Future<void> _save(List<GroceryItem> list) async {
    if (_userId == null) return;
    final doc = GroceryListDoc(
      id: _current?.id ?? '',
      userId: _userId!,
      items: list,
      createdAt: _current?.createdAt ?? DateTime.now(),
    );
    _current = doc;
    notifyListeners();
    try {
      await _firestore.saveGroceryList(doc);
    } catch (e) {
      debugPrint('Firestore _save failed: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
