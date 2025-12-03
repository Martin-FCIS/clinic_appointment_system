class Doctor {
  final int? id;
  final int userId;
  final String specialty;
  final double price;
  final String status;

  Doctor(
      {this.id,
      required this.userId,
      required this.specialty,
      required this.price,
      this.status = "pending"});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'specialty': specialty,
      'price': price,
      'status': status
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
        id: map['id'],
        userId: map['userId'],
        specialty: map['specialty'],
        price: map['price'],
        status: map['status'] ?? 'pending');
  }
}
