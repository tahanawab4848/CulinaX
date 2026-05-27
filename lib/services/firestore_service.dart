import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_list.dart';
import '../models/meal_plan_entry.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';
import '../data/pakistani_recipes.dart';

class FirestoreService {
  FirebaseFirestore? get _firestoreInstance {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // ── Mock Database for Offline/Demo Mode ────────────────────────────────────
  static final _mockUsers = <String, UserProfile>{};
  static final _mockPantryItems = <String, PantryItem>{};
  static final _mockRecipes = <String, Recipe>{};
  static final _mockGroceryLists = <String, GroceryListDoc>{};
  static final _mockMealPlans = <String, MealPlanEntry>{};

  // Stream Controllers to notify listeners of local modifications
  static final _pantryController = StreamController<List<PantryItem>>.broadcast();
  static final _recipeController = StreamController<List<Recipe>>.broadcast();
  static final _groceryController = StreamController<GroceryListDoc?>.broadcast();
  static final _mealPlanController = StreamController<List<MealPlanEntry>>.broadcast();
  static final _userProfileController = StreamController<UserProfile?>.broadcast();

  // Helper to check if Firebase is initialized and usable
  bool get _isFirebaseAvailable {
    try {
      final db = _firestoreInstance;
      return db != null;
    } catch (_) {
      return false;
    }
  }

  CollectionReference get _users => _firestoreInstance!.collection('users');
  CollectionReference get _pantry => _firestoreInstance!.collection('pantry_items');
  CollectionReference get _recipes => _firestoreInstance!.collection('recipes');
  CollectionReference get _grocery => _firestoreInstance!.collection('grocery_list');
  CollectionReference get _mealPlans => _firestoreInstance!.collection('meal_plans');

  // ── User ──────────────────────────────────────────────────────────────────
  Future<void> createUserProfile(UserProfile profile) async {
    if (_isFirebaseAvailable) {
      await _users.doc(profile.userId).set(profile.toMap(), SetOptions(merge: true));
    } else {
      _mockUsers[profile.userId] = profile;
      _userProfileController.add(profile);
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    if (_isFirebaseAvailable) {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromMap(userId, doc.data() as Map<String, dynamic>);
    } else {
      if (!_mockUsers.containsKey(userId)) {
        _mockUsers[userId] = UserProfile(userId: userId, name: 'Demo Chef', email: 'demo@culinax.com');
      }
      return _mockUsers[userId];
    }
  }

  Future<void> updateUserPreferences(
    String userId,
    UserPreferences prefs,
  ) async {
    if (_isFirebaseAvailable) {
      await _users.doc(userId).set(
        {'preferences': prefs.toMap()},
        SetOptions(merge: true),
      );
    } else {
      final profile = _mockUsers[userId] ?? UserProfile(userId: userId, name: 'Demo Chef', email: 'demo@culinax.com');
      final updated = profile.copyWith(preferences: prefs);
      _mockUsers[userId] = updated;
      _userProfileController.add(updated);
    }
  }

  Stream<UserProfile?> watchUserProfile(String userId) {
    if (_isFirebaseAvailable) {
      return _users.doc(userId).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserProfile.fromMap(userId, doc.data() as Map<String, dynamic>);
      });
    } else {
      // Return local stream
      Timer(const Duration(milliseconds: 100), () {
        final profile = _mockUsers[userId] ?? UserProfile(userId: userId, name: 'Demo Chef', email: 'demo@culinax.com');
        _userProfileController.add(profile);
      });
      return _userProfileController.stream;
    }
  }

  // ── Pantry ────────────────────────────────────────────────────────────────
  Stream<List<PantryItem>> watchPantry(String userId) {
    if (_isFirebaseAvailable) {
      return _pantry
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => PantryItem.fromFirestore(d)).toList());
    } else {
      Timer(const Duration(milliseconds: 100), () {
        _pantryController.add(_mockPantryItems.values.where((i) => i.userId == userId).toList());
      });
      return _pantryController.stream;
    }
  }

  Future<void> addPantryItem(PantryItem item) async {
    if (_isFirebaseAvailable) {
      await _pantry.add(item.toMap());
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      // We need to copy with the generated ID since mock items don't have Firestore-generated doc IDs.
      final itemWithId = PantryItem(
        id: id,
        userId: item.userId,
        itemName: item.itemName,
        quantity: item.quantity,
        unit: item.unit,
        expiryDate: item.expiryDate,
        category: item.category,
        isUsed: item.isUsed,
        icon: item.icon,
      );
      _mockPantryItems[id] = itemWithId;
      _pantryController.add(_mockPantryItems.values.where((i) => i.userId == item.userId).toList());
    }
  }

  Future<void> updatePantryItem(PantryItem item) async {
    if (_isFirebaseAvailable) {
      await _pantry.doc(item.id).update(item.toMap());
    } else {
      _mockPantryItems[item.id] = item;
      _pantryController.add(_mockPantryItems.values.where((i) => i.userId == item.userId).toList());
    }
  }

  Future<void> deletePantryItem(String id) async {
    if (_isFirebaseAvailable) {
      await _pantry.doc(id).delete();
    } else {
      final item = _mockPantryItems.remove(id);
      if (item != null) {
        _pantryController.add(_mockPantryItems.values.where((i) => i.userId == item.userId).toList());
      }
    }
  }

  // ── Recipes ─────────────────────────────────────────────────────────────────
  Stream<List<Recipe>> watchRecipes() {
    if (_isFirebaseAvailable) {
      return _recipes.snapshots().map((snap) =>
          snap.docs.map((d) => Recipe.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
    } else {
      Timer(const Duration(milliseconds: 100), () {
        if (_mockRecipes.isEmpty) {
          for (final r in kPakistaniRecipes) {
            _mockRecipes[r.id] = r;
          }
        }
        _recipeController.add(_mockRecipes.values.toList());
      });
      return _recipeController.stream;
    }
  }

  Future<List<Recipe>> getRecipesOnce() async {
    if (_isFirebaseAvailable) {
      final snap = await _recipes.get();
      return snap.docs
          .map((d) => Recipe.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList();
    } else {
      if (_mockRecipes.isEmpty) {
        for (final r in kPakistaniRecipes) {
          _mockRecipes[r.id] = r;
        }
      }
      return _mockRecipes.values.toList();
    }
  }

  Future<void> seedRecipes(List<Recipe> recipes) async {
    if (_isFirebaseAvailable) {
      final batch = _firestoreInstance!.batch();
      for (final r in recipes) {
        final ref = _recipes.doc(r.id);
        batch.set(ref, r.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    } else {
      for (final r in recipes) {
        _mockRecipes[r.id] = r;
      }
      _recipeController.add(_mockRecipes.values.toList());
    }
  }

  Future<bool> recipesCollectionEmpty() async {
    if (_isFirebaseAvailable) {
      final snap = await _recipes.limit(1).get();
      return snap.docs.isEmpty;
    } else {
      return _mockRecipes.isEmpty;
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    if (_isFirebaseAvailable) {
      await _recipes.doc(recipe.id).set(recipe.toMap());
    } else {
      _mockRecipes[recipe.id] = recipe;
      _recipeController.add(_mockRecipes.values.toList());
    }
  }

  Future<void> patchRecipeImages(Map<String, String> idToImageUrl) async {
    if (_isFirebaseAvailable) {
      final batch = _firestoreInstance!.batch();
      for (final entry in idToImageUrl.entries) {
        batch.update(_recipes.doc(entry.key), {'imageUrl': entry.value});
      }
      await batch.commit();
    } else {
      for (final entry in idToImageUrl.entries) {
        if (_mockRecipes.containsKey(entry.key)) {
          final r = _mockRecipes[entry.key]!;
          _mockRecipes[entry.key] = r.copyWith(); // triggers change
        }
      }
      _recipeController.add(_mockRecipes.values.toList());
    }
  }

  // ── Grocery ───────────────────────────────────────────────────────────────
  Stream<GroceryListDoc?> watchGroceryList(String userId) {
    if (_isFirebaseAvailable) {
      return _grocery
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
        if (snap.docs.isEmpty) return null;
        if (snap.docs.length > 1) {
          final docs = snap.docs.map((d) => GroceryListDoc.fromFirestore(d)).toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs.first;
        }
        return GroceryListDoc.fromFirestore(snap.docs.first);
      });
    } else {
      Timer(const Duration(milliseconds: 100), () {
        final list = _mockGroceryLists.values.where((g) => g.userId == userId).toList();
        if (list.isEmpty) {
          _groceryController.add(null);
        } else {
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _groceryController.add(list.first);
        }
      });
      return _groceryController.stream;
    }
  }

  Future<void> saveGroceryList(GroceryListDoc doc) async {
    if (_isFirebaseAvailable) {
      if (doc.id.isEmpty) {
        await _grocery.add(doc.toMap());
      } else {
        await _grocery.doc(doc.id).set(doc.toMap());
      }
    } else {
      var activeDoc = doc;
      if (doc.id.isEmpty) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        activeDoc = GroceryListDoc(
          id: id,
          userId: doc.userId,
          items: doc.items,
          createdAt: doc.createdAt,
        );
      }
      _mockGroceryLists[activeDoc.id] = activeDoc;
      _groceryController.add(activeDoc);
    }
  }

  // ── Meal plans ──────────────────────────────────────────────────────────────
  Stream<List<MealPlanEntry>> watchMealPlan(String userId) {
    if (_isFirebaseAvailable) {
      return _mealPlans
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => MealPlanEntry.fromMap(
                    d.id,
                    d.data() as Map<String, dynamic>,
                  ))
              .toList());
    } else {
      Timer(const Duration(milliseconds: 100), () {
        _mealPlanController.add(_mockMealPlans.values.where((m) => m.userId == userId).toList());
      });
      return _mealPlanController.stream;
    }
  }

  Future<void> setMealPlanEntry(MealPlanEntry entry) async {
    if (_isFirebaseAvailable) {
      if (entry.id.isEmpty) {
        await _mealPlans.add(entry.toMap());
      } else {
        await _mealPlans.doc(entry.id).update(entry.toMap());
      }
    } else {
      var activeEntry = entry;
      if (entry.id.isEmpty) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        activeEntry = MealPlanEntry(
          id: id,
          userId: entry.userId,
          dayIndex: entry.dayIndex,
          mealType: entry.mealType,
          recipeId: entry.recipeId,
          recipeName: entry.recipeName,
          plannedDate: entry.plannedDate,
        );
      }
      _mockMealPlans[activeEntry.id] = activeEntry;
      _mealPlanController.add(_mockMealPlans.values.where((m) => m.userId == entry.userId).toList());
    }
  }

  Future<void> deleteMealPlanEntry(String id) async {
    if (_isFirebaseAvailable) {
      await _mealPlans.doc(id).delete();
    } else {
      final entry = _mockMealPlans.remove(id);
      if (entry != null) {
        _mealPlanController.add(_mockMealPlans.values.where((m) => m.userId == entry.userId).toList());
      }
    }
  }
}
