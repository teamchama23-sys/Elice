class Investment {
  final int? id;
  final String name;
  final String type; // Stock, Crypto, Bond, Fund, Other
  final double quantity;
  final double purchasePrice;
  final double currentPrice;
  final String currency;
  final DateTime purchaseDate;

  Investment({
    this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
    required this.currency,
    required this.purchaseDate,
  });

  double get costBasis => quantity * purchasePrice;
  double get currentValue => quantity * currentPrice;
  double get gainLoss => currentValue - costBasis;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'quantity': quantity,
        'purchasePrice': purchasePrice,
        'currentPrice': currentPrice,
        'currency': currency,
        'purchaseDate': purchaseDate.toIso8601String(),
      };

  factory Investment.fromMap(Map<String, dynamic> map) => Investment(
        id: map['id'],
        name: map['name'],
        type: map['type'],
        quantity: map['quantity'],
        purchasePrice: map['purchasePrice'],
        currentPrice: map['currentPrice'],
        currency: map['currency'],
        purchaseDate: DateTime.parse(map['purchaseDate']),
      );
}
