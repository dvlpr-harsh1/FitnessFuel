import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessfuel/view/auth/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AuthController extends ChangeNotifier {
  final String _uid = '';
  String get uid => _uid;
  // Controls Create Account toggle
  bool _isCreateAccountPage = false;
  bool get isCreateAccountPage => _isCreateAccountPage;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Firebase Auth and Firestore references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _firestoreCol = FirebaseFirestore.instance
      .collection('Admin');

  /// Toggle between login and create account screens
  void toggleCreateAccountPage() {
    _isCreateAccountPage = !_isCreateAccountPage;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LogInPage()),
    );
  }

  /// Create a new Admin account
  Future<bool> createAdmin({
    required String email,
    required String pass,
  }) async {
    _setLoading(true);

    try {
      // Sign out any currently logged-in user
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      await _firestoreCol.doc(userCred.user!.uid).set({
        'email': email,
        'pass': pass,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setError("Something went wrong");
      return false;
    }
  }

  /// Admin Login
  Future<bool> adminLogin({required String email, required String pass}) async {
    _setLoading(true);

    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final doc = await _firestoreCol.doc(userCred.user!.uid).get();
      if (!doc.exists) {
        _setError("Not an admin account");
        await _auth.signOut();
        return false;
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setError("Something went wrong");
      return false;
    }
  }

  // === Utility Methods ===

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _handleAuthError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      _setError("Email already in use. Please login.");
    } else if (e.code == 'invalid-email') {
      _setError("Invalid email address.");
    } else if (e.code == 'weak-password') {
      _setError("Password should be at least 6 characters.");
    } else if (e.code == 'user-not-found') {
      _setError("No user found for that email.");
    } else if (e.code == 'wrong-password') {
      _setError("Incorrect password.");
    } else {
      _setError(e.message ?? "Unknown error");
    }
  }
}
