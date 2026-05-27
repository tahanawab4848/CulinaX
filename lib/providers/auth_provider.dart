import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  User? _user;
  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;
  String? get userId => _user?.uid;

  AuthProvider() {
    _user = _auth.currentUser;
    if (_user != null) _loadProfile();
    _auth.authStateChanges.listen((u) async {
      _user = u;
      if (u != null) {
        await _loadProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    _profile = await _firestore.getUserProfile(_user!.uid);
    notifyListeners();
  }

  Future<bool> signUp(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.signUp(
        email: email,
        password: password,
        name: name,
      );
      _user = cred.user;
      final profile = UserProfile(
        userId: _user!.uid,
        name: name,
        email: email,
      );
      await _firestore.createUserProfile(profile);
      _profile = profile;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign up failed';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signIn(email: email, password: password);
      _user = _auth.currentUser;
      await _loadProfile();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login failed';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences prefs) async {
    if (_user == null) return;
    await _firestore.updateUserPreferences(_user!.uid, prefs);
    _profile = _profile?.copyWith(preferences: prefs) ??
        UserProfile(userId: _user!.uid, name: '', email: '', preferences: prefs);
    notifyListeners();
  }
}
