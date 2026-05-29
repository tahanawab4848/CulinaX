import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_list.dart';
import '../models/meal_plan_entry.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');
  CollectionReference get _pantry => _db.collection('pantry_items');
  CollectionReference get _recipes => _db.collection('recipes');
  CollectionReference get _grocery => _db.collection('grocery_list');
  CollectionReference get _mealPlans => _db.collection('meal_plans');

  // ── User ──────────────────────────────────────────────────────────────────
  Future<void> createUserProfile(UserProfile profile) async {
    await _users.doc(profile.userId).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(userId, doc.data() as Map<String, dynamic>);
  }

  Future<void> updateUserPreferences(
    String userId,
    UserPreferences prefs,
  ) async {
    await _users.doc(userId).set(
      {'preferences': prefs.toMap()},
      SetOptions(merge: true),
    );
  }

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(userId, doc.data() as Map<String, dynamic>);
    });
  }

  // ── Pantry ────────────────────────────────────────────────────────────────
  Stream<List<PantryItem>> watchPantry(String userId) {
    return _pantry
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PantryItem.fromFirestore(d)).toList());
  }

  Future<void> addPantryItem(PantryItem item) async {
    await _pantry.add(item.toMap());
  }

  Future<void> updatePantryItem(PantryItem item) async {
    await _pantry.doc(item.id).update(item.toMap());
  }

  Future<void> deletePantryItem(String id) async {
    await _pantry.doc(id).delete();
  }

  // ── Recipes ─────────────────────────────────────────────────────────────────
  Stream<List<Recipe>> watchRecipes() {
    return _recipes.snapshots().map((snap) =>
        snap.docs.map((d) => Recipe.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<List<Recipe>> getRecipesOnce() async {
    final snap = await _recipes.get();
    return snap.docs
        .map((d) => Recipe.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> seedRecipes(List<Recipe> recipes) async {
    final batch = _db.batch();
    for (final r in recipes) {
      final ref = _recipes.doc(r.id);
      batch.set(ref, r.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<bool> recipesCollectionEmpty() async {
    final snap = await _recipes.limit(1).get();
    return snap.docs.isEmpty;
  }

  /// Patches only the imageUrl field for specific recipes.
  /// Used as a one-time migration to fix broken image URLs.
  Future<void> patchRecipeImages(Map<String, String> idToImageUrl) async {
    final batch = _db.batch();
    for (final entry in idToImageUrl.entries) {
      batch.update(_recipes.doc(entry.key), {'imageUrl': entry.value});
    }
    await batch.commit();
  }

  // ── Grocery ───────────────────────────────────────────────────────────────
  Stream<GroceryListDoc?> watchGroceryList(String userId) {
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
  }

  Future<void> saveGroceryList(GroceryListDoc doc) async {
    if (doc.id.isEmpty) {
      await _grocery.add(doc.toMap());
    } else {
      await _grocery.doc(doc.id).set(doc.toMap());
    }
  }

  // ── Meal plans ──────────────────────────────────────────────────────────────
  Stream<List<MealPlanEntry>> watchMealPlan(String userId) {
    return _mealPlans
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MealPlanEntry.fromMap(
                  d.id,
                  d.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  Future<void> setMealPlanEntry(MealPlanEntry entry) async {
    if (entry.id.isEmpty) {
      await _mealPlans.add(entry.toMap());
    } else {
      await _mealPlans.doc(entry.id).update(entry.toMap());
    }
  }

  Future<void> deleteMealPlanEntry(String id) async {
    await _mealPlans.doc(id).delete();
  }
}
