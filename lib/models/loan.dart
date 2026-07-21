class Loan {
  final int? id;
  final String name;
  final double principal;
  final double interestRate; // annual %
  final double emiAmount;
  final int totalMonths;
  final int monthsPaid;
  final String currency;
  final DateTime startDate;

  Loan({
    this.id,
    required this.name,
    required this.principal,
    required this.interestRate,
    required this.emiAmount,
    required this.totalMonths,
    required this.monthsPaid,
    required this.currency,
    required this.startDate,
  });

  double get remainingBalance {
    final paid = emiAmount * monthsPaid;
    final remaining = principal - paid;
    return remaining < 0 ? 0 : remaining;
  }

  double get progressPercent =>
      totalMonths == 0 ? 0 : (monthsPaid / totalMonths).clamp(0, 1) * 100;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'principal': principal,
        'interestRate': interestRate,
        'emiAmount': emiAmount,
        'totalMonths': totalMonths,
        'monthsPaid': monthsPaid,
        'currency': currency,
        'startDate': startDate.toIso8601String(),
      };

  factory Loan.fromMap(Map<String, dynamic> map) => Loan(
        id: map['id'],
        name: map['name'],
        principal: map['principal'],
        interestRate: map['interestRate'],
        emiAmount: map['emiAmount'],
        totalMonths: map['totalMonths'],
        monthsPaid: map['monthsPaid'],
        currency: map['currency'],
        startDate: DateTime.parse(map['startDate']),
      );
}
