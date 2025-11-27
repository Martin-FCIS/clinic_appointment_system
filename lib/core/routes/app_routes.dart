import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/add_doctor_screen.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/doctors_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/login_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/sign_up_screen.dart';
import 'package:clinic_appointment_system/modules/doctor/home/pages/doctor_appointments_screen.dart';
import 'package:clinic_appointment_system/modules/doctor/home/pages/doctor_schedule_screen.dart';
import 'package:flutter/cupertino.dart';

import '../../modules/admin/home/pages/home.dart';
import '../../modules/doctor/home/pages/doctor_home_screen.dart';
import '../../modules/doctor/home/pages/doctor_profile_screen.dart';
import '../../modules/doctor/registration/pages/doctor_registration_screen.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutesName.loginScreen: (_) => LoginScreen(),
    AppRoutesName.signUpScreen: (_) => SignUpScreen(),
    AppRoutesName.DoctorRegistrationScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorRegistrationScreen(userId: id);
    },
    AppRoutesName.DoctorHomeScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorHomeScreen(userId: id);
    },
    AppRoutesName.DoctorAppointmentsScreen: (context) {
      final doctorId = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorAppointmentsScreen(doctorId: doctorId);
    },
    AppRoutesName.DoctorScheduleScreen: (context) {
      final doctorId = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorScheduleScreen(doctorId: doctorId);
    },
    AppRoutesName.DoctorProfileScreen: (context) {
      final userId = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorProfileScreen(userId: userId);
    },
    AppRoutesName.adminHomeScreen: (_) => AdminHome(),
    AppRoutesName.adminDoctorsScreen: (_) => DoctorsScreen(),
    AppRoutesName.adminAddDoctorScreen: (_) => AddDoctorScreen(),
  };
}
