import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/appointments/admin_appointments_screen.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/doctors/add_doctor_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/login_screen.dart';
import 'package:clinic_appointment_system/modules/auth/pages/sign_up_screen.dart';
import 'package:clinic_appointment_system/modules/doctor/authorization/doctor_home_proxy.dart';
import 'package:clinic_appointment_system/modules/doctor/home/pages/doctor_appointments_screen.dart';
import 'package:clinic_appointment_system/modules/doctor/home/pages/doctor_schedule_screen.dart';
import 'package:clinic_appointment_system/modules/patient/home/pages/patient_appointments_screen.dart';
import 'package:clinic_appointment_system/modules/patient/home/pages/patient_booking_screen.dart';
import 'package:clinic_appointment_system/modules/patient/home/pages/patient_home_screen.dart';
import 'package:flutter/cupertino.dart';

import '../../modules/admin/home/pages/admin_home_screen.dart';
import '../../modules/admin/home/pages/doctors/doctor_details_screen.dart';
import '../../modules/admin/home/pages/doctors/doctors_screen.dart';
import '../../modules/admin/home/pages/specialty/admin_specialty_screen.dart';
import '../../modules/doctor/home/pages/doctor_home_screen.dart';
import '../../modules/doctor/home/pages/doctor_profile_screen.dart';
import '../../modules/doctor/registration/pages/doctor_registration_screen.dart';
import '../../modules/patient/home/pages/patient_profile_screen.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutesName.loginScreen: (_) => LoginScreen(),
    AppRoutesName.signUpScreen: (_) => SignUpScreen(),
    AppRoutesName.doctorRegistrationScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorRegistrationScreen(userId: id);
    },
    AppRoutesName.doctorProxy: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorHomeProxy(userId: id);
    },
    AppRoutesName.doctorHomeScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorHomeScreen(userId: id);
    },
    AppRoutesName.doctorAppointmentsScreen: (context) {
      final doctorId = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorAppointmentsScreen(doctorId: doctorId);
    },
    AppRoutesName.doctorScheduleScreen: (context) {
      final doctorId = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorScheduleScreen(doctorId: doctorId);
    },
    AppRoutesName.doctorProfileScreen: (context) {
      final userId = ModalRoute.of(context)!.settings.arguments as int;
      return DoctorProfileScreen(userId: userId);
    },
    AppRoutesName.patientHomeScreen: (context) {
      final userId = ModalRoute.of(context)!.settings.arguments as int;
      return PatientHomeScreen(userId: userId);
    },
    AppRoutesName.patientProfileScreen: (context) {
      final userId = ModalRoute.of(context)!.settings.arguments as int;
      return PatientProfileScreen(userId: userId);
    },
    AppRoutesName.patientAppointmentsScreen: (context) {
      final patientId = ModalRoute.of(context)!.settings.arguments as int;
      return PatientAppointmentsScreen(patientId: patientId);
    },
    AppRoutesName.patientBookingScreen: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PatientBookingScreen(
        patientId: args['patientId'],
        doctor: args['doctor'],
        doctorName: args['doctorName'],
      );
    },
    AppRoutesName.adminHomeScreen: (_) => AdminHome(),
    AppRoutesName.adminDoctorsScreen: (_) => DoctorsScreen(),
    AppRoutesName.adminAddDoctorScreen: (_) => AddDoctorScreen(),
    AppRoutesName.adminDoctorDetailsScreen: (context) {
      final settings = ModalRoute.of(context)!.settings;
      final doctorId = settings.arguments as int;
      return DoctorDetailScreen(doctorId: doctorId);
    },
    AppRoutesName.adminAppointmentsScreen: (_) => AdminAppointmentsScreen(),
    AppRoutesName.adminSpecialtyScreen: (_) => AdminSpecialtyScreen(),
  };
}
