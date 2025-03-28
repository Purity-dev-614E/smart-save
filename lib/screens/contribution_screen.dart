import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../models/savings_goal.dart';
import '../widgets/amount_input.dart';

class ContributionScreen extends StatefulWidget {
  final String goalId;

  const ContributionScreen({
    Key? key,
    required this.goalId,
  }) : super(key: key);

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
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

  void _validateAndSubmit() {
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
    } catch (e) {
      setState(() {
        _amountError = 'Please enter a valid amount';
      });
      return;
    }

    _submitContribution(amount);
  }

  Future<void> _submitContribution(double amount) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<SavingsProvider>(context, listen: false);
      await provider.addContribution(
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
            content: Text('Error adding contribution: ${e.toString()}'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contribution'),
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
                        'Contributing to:',
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
                    ],
                  ),
                ),
              ),
              AmountInput(
                controller: _amountController,
                label: 'Contribution Amount',
                hint: 'How much would you like to add?',
                errorText: _amountError,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'e.g., Bonus, Gift, Salary',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Contribution',
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