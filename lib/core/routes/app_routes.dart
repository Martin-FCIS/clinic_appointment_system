import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/auth/pages/login_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';

class AppRoutes{
  static Map<String, Widget Function(BuildContext)> routes= {
AppRoutesName.loginScreen:(_)=>LoginScreen(),
AppRoutesName.signUpScreen:(_)=>SignUpScreen()
  };
}