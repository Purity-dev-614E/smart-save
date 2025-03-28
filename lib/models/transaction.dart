enum TransactionType { deposit, withdrawal }

class SavingsTransaction {
  final String id;
  final String goalId;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;

  SavingsTransaction({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory SavingsTransaction.fromMap(Map<String, dynamic> map, String documentId) {
    return SavingsTransaction(
      id: documentId,
      goalId: map['goalId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] == 'deposit'
          ? TransactionType.deposit
          : TransactionType.withdrawal,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      note: map['note'],
    );
  }
}