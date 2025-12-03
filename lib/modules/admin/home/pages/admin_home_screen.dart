import 'package:clinic_appointment_system/modules/admin/home/widgets/admin_dashboard.dart';
import 'package:clinic_appointment_system/modules/admin/home/widgets/custom_admin_drawer.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Admin Dash Board",
            style: TextStyle(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      drawer:
          CustomAdminDrawer(name: 'System Admin', email: 'admin@clinic.com'),
      body: AdminDashboard(),
    );
  }
}
