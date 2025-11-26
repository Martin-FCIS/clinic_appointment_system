class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final int role; // 1:Admin, 2:Doctor, 3:Patient

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}