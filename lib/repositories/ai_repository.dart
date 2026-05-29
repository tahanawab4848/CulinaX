import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ai_interaction.dart';

class AiRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _ai => _db.collection('ai_interactions');

  Future<void> saveInteraction(AiInteraction interaction) async {
    if (interaction.id.isEmpty) {
      await _ai.add(interaction.toMap());
    } else {
      await _ai.doc(interaction.id).set(interaction.toMap());
    }
  }

  Stream<List<AiInteraction>> watchHistory(String userId, {int limit = 30}) {
    return _ai
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AiInteraction.fromFirestore(d)).toList());
  }

  Future<void> saveFavoriteRecipe(String userId, String recipeId) async {
    await _db.collection('users').doc(userId).set({
      'favoriteRecipes': FieldValue.arrayUnion([recipeId]),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavoriteRecipe(String userId, String recipeId) async {
    await _db.collection('users').doc(userId).set({
      'favoriteRecipes': FieldValue.arrayRemove([recipeId]),
    }, SetOptions(merge: true));
  }
}
