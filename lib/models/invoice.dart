class Invoice {
  final int? id;
  final String clientName;
  final String description;
  final double amount;
  final String currency;
  final DateTime issueDate;
  final DateTime dueDate;
  final String status; // Draft, Sent, Paid, Overdue

  Invoice({
    this.id,
    required this.clientName,
    required this.description,
    required this.amount,
    required this.currency,
    required this.issueDate,
    required this.dueDate,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientName': clientName,
        'description': description,
        'amount': amount,
        'currency': currency,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'status': status,
      };

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
        id: map['id'],
        clientName: map['clientName'],
        description: map['description'],
        amount: map['amount'],
        currency: map['currency'],
        issueDate: DateTime.parse(map['issueDate']),
        dueDate: DateTime.parse(map['dueDate']),
        status: map['status'],
      );
}
