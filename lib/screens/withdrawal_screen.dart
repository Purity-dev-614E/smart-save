import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../models/savings_goal.dart';
import '../widgets/amount_input.dart';

class WithdrawalScreen extends StatefulWidget {
  final String goalId;

  const WithdrawalScreen({
    Key? key,
    required this.goalId,
  }) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _amountError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validateAndSubmit(SavingsGoal goal) {
    setState(() {
      _amountError = null;
    });

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _amountError = 'Please enter an amount';
      });
      return;
    }

    double? amount;
    try {
      amount = double.parse(amountText);
      if (amount <= 0) {
        setState(() {
          _amountError = 'Amount must be greater than zero';
        });
        return;
      }

      if (amount > goal.currentAmount) {
        setState(() {
          _amountError = 'Amount exceeds available balance';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _amountError = 'Please enter a valid amount';
      });
      return;
    }

    _submitWithdrawal(amount);
  }

  Future<void> _submitWithdrawal(double amount) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<SavingsProvider>(context, listen: false);
      await provider.makeWithdrawal(
        widget.goalId,
        amount,
        _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making withdrawal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Withdrawal'),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          final goal = provider.goals.firstWhere(
            (g) => g.id == widget.goalId,
            orElse: () => SavingsGoal(
              id: '',
              name: 'Unknown Goal',
              targetAmount: 0,
              createdAt: DateTime.now(),
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdrawing from:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Available balance: ${currencyFormat.format(goal.currentAmount)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              AmountInput(
                controller: _amountController,
                label: 'Withdrawal Amount',
                hint: 'How much would you like to withdraw?',
                errorText: _amountError,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'e.g., Emergency, Planned Purchase',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _validateAndSubmit(goal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Make Withdrawal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}