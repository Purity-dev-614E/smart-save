import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Deposits'),
              Tab(text: 'Withdrawals'),
            ],
          ),
        ),
        body: Consumer<SavingsProvider>(
          builder: (context, provider, child) {
            final allTransactions = provider.transactions;
            final deposits = allTransactions
                .where((t) => t.type == TransactionType.deposit)
                .toList();
            final withdrawals = allTransactions
                .where((t) => t.type == TransactionType.withdrawal)
                .toList();

            return TabBarView(
              children: [
                _buildTransactionList(context, allTransactions, provider),
                _buildTransactionList(context, deposits, provider),
                _buildTransactionList(context, withdrawals, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<SavingsTransaction> transactions,
    SavingsProvider provider,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final goal = provider.goals.firstWhere(
          (g) => g.id == transaction.goalId,
          orElse: () => SavingsGoal(
            id: '',
            name: 'Unknown Goal',
            targetAmount: 0,
            createdAt: DateTime.now(),
          ),
        );
        
        final goalName = goal.name;
        
        return TransactionListItem(
          transaction: transaction,
          goalName: goalName,
        );
      },
    );
  }
}