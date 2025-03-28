import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';

class SavingsProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<SavingsGoal> _goals = [];
  List<SavingsTransaction> _transactions = [];
  bool _isLoading = false;

  List<SavingsGoal> get goals => _goals;
  List<SavingsTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.initialize();
      _listenToGoals();
      _listenToTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing SavingsProvider: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to goals from Firebase
  void _listenToGoals() {
    _firebaseService.getSavingsGoals().listen((goals) {
      _goals = goals;
      notifyListeners();
    });
  }

  // Listen to transactions from Firebase
  void _listenToTransactions() {
    _firebaseService.getTransactions().listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    });
  }

  // Create a new savings goal
  Future<void> createSavingsGoal(String name, double targetAmount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final goal = SavingsGoal(
        id: const Uuid().v4(),
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0,
        createdAt: DateTime.now(),
      );

      await _firebaseService.addSavingsGoal(goal);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating savings goal: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a contribution to a savings goal
  Future<void> addContribution(String goalId, double amount, [String? note]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = SavingsTransaction(
        id: const Uuid().v4(),
        goalId: goalId,
        amount: amount,
        type: TransactionType.deposit,
        date: DateTime.now(),
        note: note,
      );

      await _firebaseService.addTransaction(transaction);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding contribution: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Make a withdrawal from a savings goal
  Future<void> makeWithdrawal(String goalId, double amount, [String? note]) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the goal
      final goal = _goals.firstWhere((g) => g.id == goalId);

      // Check if withdrawal is possible
      if (amount > goal.currentAmount) {
        throw Exception('Withdrawal amount exceeds available balance');
      }

      final transaction = SavingsTransaction(
        id: const Uuid().v4(),
        goalId: goalId,
        amount: amount,
        type: TransactionType.withdrawal,
        date: DateTime.now(),
        note: note,
      );

      await _firebaseService.addTransaction(transaction);
    } catch (e) {
      if (kDebugMode) {
        print('Error making withdrawal: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a savings goal
  Future<void> deleteSavingsGoal(String goalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteSavingsGoal(goalId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting savings goal: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get transactions for a specific goal
  List<SavingsTransaction> getTransactionsForGoal(String goalId) {
    return _transactions.where((t) => t.goalId == goalId).toList();
  }
}