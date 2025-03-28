import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _initialized = false;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Check if user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize the service
  Future<void> initialize() async {
    if (!_initialized) {
      // Check if user is logged in, if not, use anonymous auth
      if (_auth.currentUser == null) {
        try {
          await _auth.signInAnonymously();
          if (kDebugMode) {
            print('Signed in anonymously with user ID: ${currentUserId}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error signing in anonymously: $e');
          }
          rethrow;
        }
      }
      _initialized = true;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If user was previously anonymous, merge their data
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        final anonymousUid = _auth.currentUser!.uid;
        await _mergeAnonymousUserData(anonymousUid, userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // After sign out, sign in anonymously again
      await _auth.signInAnonymously();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
      rethrow;
    }
  }

  // Merge anonymous user data with authenticated user
  Future<void> _mergeAnonymousUserData(String anonymousUid, String authenticatedUid) async {
    // Get all goals from anonymous user
    final goalsSnapshot = await _firestore
        .collection('users')
        .doc(anonymousUid)
        .collection('goals')
        .get();

    // Get all transactions from anonymous user
    final transactionsSnapshot = await _firestore
        .collection('users')
        .doc(anonymousUid)
        .collection('transactions')
        .get();

    // Use a batch to transfer all data
    final batch = _firestore.batch();

    // Transfer goals
    for (final doc in goalsSnapshot.docs) {
      final newDocRef = _firestore
          .collection('users')
          .doc(authenticatedUid)
          .collection('goals')
          .doc(doc.id);

      batch.set(newDocRef, doc.data());
    }

    // Transfer transactions
    for (final doc in transactionsSnapshot.docs) {
      final newDocRef = _firestore
          .collection('users')
          .doc(authenticatedUid)
          .collection('transactions')
          .doc(doc.id);

      batch.set(newDocRef, doc.data());
    }

    // Delete anonymous user data
    for (final doc in goalsSnapshot.docs) {
      final oldDocRef = _firestore
          .collection('users')
          .doc(anonymousUid)
          .collection('goals')
          .doc(doc.id);

      batch.delete(oldDocRef);
    }

    for (final doc in transactionsSnapshot.docs) {
      final oldDocRef = _firestore
          .collection('users')
          .doc(anonymousUid)
          .collection('transactions')
          .doc(doc.id);

      batch.delete(oldDocRef);
    }

    // Commit the batch
    await batch.commit();
  }

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _goalsCollection =>
      _usersCollection.doc(currentUserId).collection('goals');
  CollectionReference get _transactionsCollection =>
      _usersCollection.doc(currentUserId).collection('transactions');

  // Savings Goals CRUD operations
  Stream<List<SavingsGoal>> getSavingsGoals() {
    if (!_initialized) initialize();

    return _goalsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingsGoal.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<SavingsGoal> getSavingsGoalById(String goalId) async {
    if (!_initialized) await initialize();

    DocumentSnapshot doc = await _goalsCollection.doc(goalId).get();
    return SavingsGoal.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    if (!_initialized) await initialize();

    return _goalsCollection.doc(goal.id).set(goal.toMap());
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    if (!_initialized) await initialize();

    return _goalsCollection.doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    if (!_initialized) await initialize();

    // Get all transactions for this goal
    QuerySnapshot transactionSnapshot = await _transactionsCollection
        .where('goalId', isEqualTo: goalId)
        .get();

    // Use a batch to delete all transactions and the goal
    WriteBatch batch = _firestore.batch();

    // Add transaction deletes to batch
    for (var doc in transactionSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Add goal delete to batch
    batch.delete(_goalsCollection.doc(goalId));

    // Commit the batch
    return batch.commit();
  }

  // Transaction operations
  Stream<List<SavingsTransaction>> getTransactions() {
    if (!_initialized) initialize();

    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingsTransaction.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<SavingsTransaction>> getTransactionsForGoal(String goalId) {
    if (!_initialized) initialize();

    return _transactionsCollection
        .where('goalId', isEqualTo: goalId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingsTransaction.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addTransaction(SavingsTransaction transaction) async {
    if (!_initialized) await initialize();

    // Use a transaction to ensure data consistency
    return _firestore.runTransaction((txn) async {
      // Get the current goal
      DocumentReference goalRef = _goalsCollection.doc(transaction.goalId);
      DocumentSnapshot goalDoc = await txn.get(goalRef);

      if (!goalDoc.exists) {
        throw Exception('Goal not found');
      }

      // Create the transaction document
      DocumentReference transactionRef = _transactionsCollection.doc(transaction.id);
      txn.set(transactionRef, transaction.toMap());

      // Update the goal's current amount
      SavingsGoal goal = SavingsGoal.fromMap(
          goalDoc.data() as Map<String, dynamic>, goalDoc.id);

      double newAmount = goal.currentAmount;
      if (transaction.type == TransactionType.deposit) {
        newAmount += transaction.amount;
      } else {
        newAmount -= transaction.amount;

        // Ensure we don't go below zero
        if (newAmount < 0) {
          throw Exception('Insufficient funds');
        }
      }

      // Check if goal is completed
      DateTime? completedAt = goal.completedAt;
      if (newAmount >= goal.targetAmount && goal.completedAt == null) {
        completedAt = DateTime.now();
      } else if (newAmount < goal.targetAmount && goal.completedAt != null) {
        completedAt = null;
      }

      // Update the goal
      txn.update(goalRef, {
        'currentAmount': newAmount,
        'completedAt': completedAt?.millisecondsSinceEpoch,
      });
    });
  }

  // Clean up resources
  void dispose() {
    _initialized = false;
  }
}