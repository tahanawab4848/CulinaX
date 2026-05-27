import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  FirebaseStorage? get _storageInstance {
    try {
      return FirebaseStorage.instance;
    } catch (_) {
      return null;
    }
  }

  /// Uploads a recipe image and returns the download URL.
  Future<String?> uploadRecipeImage(String recipeId, File file) async {
    try {
      final storage = _storageInstance;
      if (storage == null) {
        debugPrint('Firebase Storage not available in Offline Mode.');
        return null;
      }
      final ref = storage.ref().child('recipes').child('$recipeId.jpg');
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage upload failed: $e');
      return null;
    }
  }

  /// Uploads a profile photo and returns the download URL.
  Future<String?> uploadProfilePhoto(String userId, File file) async {
    try {
      final storage = _storageInstance;
      if (storage == null) {
        debugPrint('Firebase Storage not available in Offline Mode.');
        return null;
      }
      final ref = storage.ref().child('profiles').child('$userId.jpg');
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage profile upload failed: $e');
      return null;
    }
  }
}
