class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; 
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'Pengeluaran',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}