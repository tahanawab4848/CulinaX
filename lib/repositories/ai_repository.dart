import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_interaction.dart';

class AiRepository {
  FirebaseFirestore? get _firestoreInstance {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _isFirebaseAvailable {
    try {
      final db = _firestoreInstance;
      return db != null;
    } catch (_) {
      return false;
    }
  }

  // Mock Interaction Storage for Offline/Demo Mode
  static final _mockInteractions = <String, List<AiInteraction>>{};
  static final _historyController = StreamController<List<AiInteraction>>.broadcast();
  static final _mockFavorites = <String, Set<String>>{};

  CollectionReference get _ai => _firestoreInstance!.collection('ai_interactions');

  Future<void> saveInteraction(AiInteraction interaction) async {
    if (_isFirebaseAvailable) {
      if (interaction.id.isEmpty) {
        await _ai.add(interaction.toMap());
      } else {
        await _ai.doc(interaction.id).set(interaction.toMap());
      }
    } else {
      final list = _mockInteractions[interaction.userId] ?? [];
      var active = interaction;
      if (interaction.id.isEmpty) {
        active = AiInteraction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: interaction.userId,
          type: interaction.type,
          prompt: interaction.prompt,
          response: interaction.response,
          createdAt: interaction.createdAt,
        );
      }
      list.insert(0, active); // Add newest first
      _mockInteractions[interaction.userId] = list;
      _historyController.add(list);
    }
  }

  Stream<List<AiInteraction>> watchHistory(String userId, {int limit = 30}) {
    if (_isFirebaseAvailable) {
      return _ai
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => AiInteraction.fromFirestore(d)).toList());
    } else {
      Timer(const Duration(milliseconds: 100), () {
        final list = _mockInteractions[userId] ?? [];
        _historyController.add(list.take(limit).toList());
      });
      return _historyController.stream;
    }
  }

  Future<void> saveFavoriteRecipe(String userId, String recipeId) async {
    if (_isFirebaseAvailable) {
      await _firestoreInstance!.collection('users').doc(userId).set({
        'favoriteRecipes': FieldValue.arrayUnion([recipeId]),
      }, SetOptions(merge: true));
    } else {
      final set = _mockFavorites[userId] ?? {};
      set.add(recipeId);
      _mockFavorites[userId] = set;
    }
  }

  Future<void> removeFavoriteRecipe(String userId, String recipeId) async {
    if (_isFirebaseAvailable) {
      await _firestoreInstance!.collection('users').doc(userId).set({
        'favoriteRecipes': FieldValue.arrayRemove([recipeId]),
      }, SetOptions(merge: true));
    } else {
      final set = _mockFavorites[userId] ?? {};
      set.remove(recipeId);
      _mockFavorites[userId] = set;
    }
  }
}
