import 'package:clinic_appointment_system/models/user_model.dart';

enum RoleType { ADMIN, DOCTOR, PATIENT }

class UserFactory {
  static User createUser(
      {required String name,
      required String email,
      required String password,
      required RoleType role}) {
    int roleId;
    switch (role) {
      case RoleType.ADMIN:
        roleId=1;
        break;
      case RoleType.DOCTOR:
        roleId=2;
        break;

      case RoleType.PATIENT:
        roleId=3;
        break;
    }
    return User(name: name, email: email, password: password, role: roleId);
  }
}
