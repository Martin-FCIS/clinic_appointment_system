class Doctor {
  final int? id;
  final int userId;      // Foreign Key
  final String specialty;
  final double price;
  // ممكن نضيف اسم الدكتور هنا للعرض فقط لو عملنا JOIN في الاستعلام

  Doctor({
    this.id,
    required this.userId,
    required this.specialty,
    required this.price,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'specialty': specialty,
      'price': price,
    };
  }
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      userId: map['userId'],
      specialty: map['specialty'],
      price: map['price'],
    );
  }
}