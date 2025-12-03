import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dashboard_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _repo = ClinicRepository.getInstance();

  int usersCount = 0;
  int doctorsCount = 0;
  int patientsCount = 0;
  int pendingDoctors = 0;
  int appointments = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    usersCount = await _repo.getUsersCount();
    doctorsCount = await _repo.getDoctorsCount();
    patientsCount = await _repo.getPatientsCount();
    pendingDoctors = await _repo.getPendingDoctorsCount();
    appointments = await _repo.getPendingAppointmentsCount();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              children: [
                DashboardCard(
                  title: "Total Users",
                  value: usersCount,
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: "Doctors",
                  value: doctorsCount,
                  icon: Icons.medical_services,
                  color: Colors.green,
                ),
                DashboardCard(
                  title: "Patients",
                  value: patientsCount,
                  icon: Icons.person,
                  color: Colors.orange,
                ),
                DashboardCard(
                  title: "Pending Doctors",
                  value: pendingDoctors,
                  icon: Icons.pending_actions,
                  color: Colors.red,
                ),
                DashboardCard(
                    title: 'Appointments',
                    value: appointments,
                    color: Colors.purple,
                    icon: FontAwesomeIcons.calendarCheck),
              ],
            ),
          );
  }
}
