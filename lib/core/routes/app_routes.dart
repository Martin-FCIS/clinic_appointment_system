import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/add_doctor_screen.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/doctors_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/login_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';

import '../../modules/admin/home/pages/home.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutesName.loginScreen: (_) => LoginScreen(),
    AppRoutesName.signUpScreen: (_) => SignUpScreen(),
    AppRoutesName.adminHomeScreen: (_) => AdminHome(),
    AppRoutesName.adminDoctorsScreen: (_) => DoctorsScreen(),
    AppRoutesName.adminAddDoctorScreen: (_) => AddDoctorScreen(),
  };
}
