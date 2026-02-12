enum TransactionType { income, expense }

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name, // Store as string 'income' or 'expense'
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () =>
            TransactionType.expense, // Default to expense for old data
      ),
    );
  }
}
