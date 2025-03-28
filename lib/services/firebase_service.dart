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