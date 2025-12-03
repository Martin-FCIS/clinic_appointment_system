import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart'; // Import your repository
import 'package:flutter/material.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  late Future<List<Map<String, dynamic>>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _repository
        .getAllApprovedDoctors();
  }

  void refreshData() {
    setState(() {
      _doctorsFuture = _repository.getAllApprovedDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "All Approved Doctors",
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final doctorsList = snapshot.data ?? [];

          if (doctorsList.isEmpty) {
            return const Center(child: Text("No approved doctors available."));
          }

          return Padding(
            padding: EdgeInsets.all(8),
            child: ListView.separated(
              itemCount: doctorsList.length,
              itemBuilder: (context, index) {
                final doctor = doctorsList[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: AppColors.timeSelectedColor,
                  title: Text(doctor['name']),
                  subtitle: Text(
                    "${doctor['specialty']} - \$${doctor['price'].toString()}",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final result = await Navigator.of(context).pushNamed(
                      AppRoutesName
                          .adminDoctorDetailsScreen,
                      arguments: doctor['id'] as int,
                    );
                    if (result == true) {
                      refreshData();
                    }
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 12,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutesName.adminAddDoctorScreen);
        },
        backgroundColor: AppColors.secondaryColor,
        label: const Text(
          'Manage Pending Doctors',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
