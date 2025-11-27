import 'package:clinic_appointment_system/core/routes/app_routes.dart';
import 'package:clinic_appointment_system/modules/admin/home/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      home: AdminHome(),
    );
  }
}
