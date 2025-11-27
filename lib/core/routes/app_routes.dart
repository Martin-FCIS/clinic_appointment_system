import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/add_doctor_screen.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/doctors_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/login_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/sign_up_screen.dart';
import 'package:clinic_appointment_system/modules/doctor/profile/pages/doctor_profile_screen.dart';
import 'package:flutter/cupertino.dart';

import '../../modules/doctor/home/pages/doctor_home_screen.dart';


class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutesName.loginScreen: (_) => LoginScreen(),
    AppRoutesName.signUpScreen: (_) => SignUpScreen(),
    AppRoutesName.DoctorProfileScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorProfileScreen(userId: id);
    },
    AppRoutesName.DoctorHomeScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorHomeScreen(userId: id);
    },
    AppRoutesName.adminHomeScreen: (_) => AdminHome(),
    AppRoutesName.adminDoctorsScreen: (_) => DoctorsScreen(),
    AppRoutesName.adminAddDoctorScreen: (_) => AddDoctorScreen(),
  };
  }

