class LedgerEntry {
  final int? id;
  final String description;
  final double amount;
  final String type; // Income or Expense
  final String category;
  final String currency;
  final DateTime date;

  LedgerEntry({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.currency,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'amount': amount,
        'type': type,
        'category': category,
        'currency': currency,
        'date': date.toIso8601String(),
      };

  factory LedgerEntry.fromMap(Map<String, dynamic> map) => LedgerEntry(
        id: map['id'],
        description: map['description'],
        amount: map['amount'],
        type: map['type'],
        category: map['category'],
        currency: map['currency'],
        date: DateTime.parse(map['date']),
      );
}
