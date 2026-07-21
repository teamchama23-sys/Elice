class SavingsGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? targetDate;

  SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.targetDate,
  });

  double get progressPercent =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1) * 100;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'currency': currency,
        'targetDate': targetDate?.toIso8601String(),
      };

  factory SavingsGoal.fromMap(Map<String, dynamic> map) => SavingsGoal(
        id: map['id'],
        name: map['name'],
        targetAmount: map['targetAmount'],
        currentAmount: map['currentAmount'],
        currency: map['currency'],
        targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      );
}
