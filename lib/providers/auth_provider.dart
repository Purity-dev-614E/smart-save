import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isAnonymous = true;

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAnonymous => _isAnonymous;
  User? get currentUser => _firebaseService.currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAuthenticating => _status == AuthStatus.authenticating;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      await _firebaseService.initialize();
      
      // Listen to auth state changes
      _firebaseService.authStateChanges.listen((User? user) {
        if (user != null) {
          _isAnonymous = user.isAnonymous;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
          _isAnonymous = true;
        }
        notifyListeners();
      });
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error initializing AuthProvider: $e');
      }
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<void> signUp(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.signUp(email, password);
      _status = AuthStatus.authenticated;
      _isAnonymous = false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _handleAuthError(e);
      if (kDebugMode) {
        print('Error signing up: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.signIn(email, password);
      _status = AuthStatus.authenticated;
      _isAnonymous = false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _handleAuthError(e);
      if (kDebugMode) {
        print('Error signing in: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      _status = AuthStatus.authenticated; // We're authenticated anonymously after sign out
      _isAnonymous = true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _handleAuthError(e);
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.resetPassword(email);
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  // Handle Firebase Auth errors and return user-friendly messages
  String _handleAuthError(dynamic error) {
    String errorMessage = 'An error occurred. Please try again.';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This operation is not allowed.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your connection.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later.';
          break;
        default:
          errorMessage = 'Error: ${error.message}';
      }
    }
    
    return errorMessage;
  }
}