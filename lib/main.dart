import 'package:clinic_appointment_system/core/routes/app_routes.dart';
import 'package:clinic_appointment_system/modules/auth/pages/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      home: LoginScreen(),
    );
  }
}
