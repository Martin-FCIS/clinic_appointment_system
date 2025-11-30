import 'package:clinic_appointment_system/modules/doctor/home/pages/doctor_home_screen.dart';
import 'package:flutter/material.dart';

import '../../../models/doctor_model.dart';
import '../../../repositories/clinic_repository.dart';

class DoctorHomeProxy extends StatefulWidget {
  final int userId;

  const DoctorHomeProxy({super.key, required this.userId});

  @override
  State<DoctorHomeProxy> createState() => _DoctorHomeProxyState();
}

class _DoctorHomeProxyState extends State<DoctorHomeProxy> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  late Future<Doctor?> _doctorFuture;

  @override
  void initState() {
    super.initState();
    _doctorFuture = _repository.getDoctorDetails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Doctor?>(
      future: _doctorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Doctor not found")),
          );
        }

        final doctor = snapshot.data!;

        if (doctor.status != "approved") {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_top,
                      size: 50, color: Colors.orange),
                  const SizedBox(height: 15),
                  Text(
                    "Your account is ${doctor.status}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text("Please wait for admin approval."),
                ],
              ),
            ),
          );
        }

        return DoctorHomeScreen(userId: widget.userId);
      },
    );
  }
}
