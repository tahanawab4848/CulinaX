import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth? get _authInstance {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _isFirebaseAvailable {
    try {
      final auth = _authInstance;
      return auth != null;
    } catch (_) {
      return false;
    }
  }

  // ── Mock Authentication for Demo/Offline Mode ─────────────────────────────
  static final _mockAuthChanges = StreamController<User?>.broadcast();
  static User? _mockUser;

  User? get currentUser => _isFirebaseAvailable ? _authInstance!.currentUser : _mockUser;

  Stream<User?> get authStateChanges {
    if (_isFirebaseAvailable) {
      return _authInstance!.authStateChanges();
    } else {
      Timer(const Duration(milliseconds: 100), () {
        _mockAuthChanges.add(_mockUser);
      });
      return _mockAuthChanges.stream;
    }
  }

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_isFirebaseAvailable) {
      final cred = await _authInstance!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      return cred;
    } else {
      _mockUser = MockUser(
        uid: 'mock_user_123',
        email: email.trim(),
        displayName: name,
      );
      _mockAuthChanges.add(_mockUser);
      return MockUserCredential(_mockUser);
    }
  }

  Future<dynamic> signIn({
    required String email,
    required String password,
  }) async {
    if (_isFirebaseAvailable) {
      return await _authInstance!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } else {
      _mockUser = MockUser(
        uid: 'mock_user_123',
        email: email.trim(),
        displayName: 'Demo Chef',
      );
      _mockAuthChanges.add(_mockUser);
      return MockUserCredential(_mockUser);
    }
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      await _authInstance!.signOut();
    } else {
      _mockUser = null;
      _mockAuthChanges.add(null);
    }
  }

  String? get userId => _isFirebaseAvailable ? _authInstance!.currentUser?.uid : (_mockUser?.uid ?? 'mock_user_123');
  String get displayName => _isFirebaseAvailable
      ? (_authInstance!.currentUser?.displayName ?? _authInstance!.currentUser?.email ?? 'User')
      : (_mockUser?.displayName ?? 'Demo Chef');
}

// ── Mock Helper Classes to simulate Firebase Auth objects offline ──────────
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  MockUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  @override
  final User? user;

  MockUserCredential(this.user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
