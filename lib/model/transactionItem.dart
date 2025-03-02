class TransactionItem {
  final int keyID;
  final String title;
  final double amount;
  final DateTime? date;
  final double? points; // ใช้ points เท่ากับราคา (บวกสำหรับซื้อ, ลบสำหรับแลก)
  final String? imagePath;

  TransactionItem({
    required this.keyID,
    required this.title,
    required this.amount,
    this.date,
    this.points, // คะแนนเท่ากับราคา (บวก/ลบ)
    this.imagePath,
  });

  TransactionItem copyWith({
    int? keyID,
    String? title,
    double? amount,
    DateTime? date,
    double? points,
    String? imagePath,
  }) {
    return TransactionItem(
      keyID: keyID ?? this.keyID,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      points: points ?? this.points,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}