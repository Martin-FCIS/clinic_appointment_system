import 'package:clinic_appointment_system/modules/doctor/home/widgets/custom_doctor_drawer.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes_name.dart';
import '../../../../models/doctor_model.dart';
import '../../../../models/user_model.dart';

class PatientHomeScreen extends StatefulWidget {
  final int userId;

  const PatientHomeScreen({super.key, required this.userId});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  User? _user;
  List<Map<String, dynamic>> _doctorsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    var user = await _repository.getUserById(widget.userId);
    var doctors = await _repository.getAllApprovedDoctors();
    if (mounted) {
      setState(() {
        _user = user;
        _doctorsList = doctors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(
          body: Center(child: Text("Error: Profile not found")));
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: CustomDoctorDrawer(
        name: _user!.name,
        email: _user!.email,
        profileFun: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutesName.patientProfileScreen,
                  arguments: _user!.id)
              .then((_) {
            _getData();
          });
        },
        myAppointFun: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutesName.patientAppointmentsScreen,
            arguments: _user!.id,
          );
        },
        logoutFun: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Logout ?",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: Text("Are you sure you want to logout ?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child:
                      const Text("logout", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                        context, AppRoutesName.loginScreen);
                  },
                ),
              ],
            ),
          );
        },
        deleteAccFun: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Delete Account ?",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: Text("Are you sure you want to Delete the Account?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child:
                      const Text("Delete", style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    _repository.deleteUser(widget.userId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutesName.loginScreen, (route) => false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Account deleted successfully"),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                ),
              ],
            ),
          );
        },
        isDoctor: false,
      ),
      appBar: AppBar(
        title: const Text("Find a Doctor",
            style: TextStyle(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${_user!.name} 👋",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Book an appointment with top doctors",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: _doctorsList.isEmpty
                  ? const Center(child: Text("No doctors available yet."))
                  : ListView.builder(
                      itemCount: _doctorsList.length,
                      itemBuilder: (context, index) {
                        final doctor = _doctorsList[index];
                        return _buildDoctorCard(doctor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dr. ${doctor['name']}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(doctor['specialty'],
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Text("${doctor['price']} EGP / Session",
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_user?.id == null) {
                  print("nulllllllllllllllll");
                  return;
                }
                Doctor docObj = Doctor(
                    id: doctor['id'],
                    userId: doctor['userId'],
                    specialty: doctor['specialty'],
                    price: doctor['price'],
                    status: doctor['status']);
                Navigator.pushNamed(
                  context,
                  AppRoutesName.patientBookingScreen,
                  arguments: {
                    'patientId': _user!.id,
                    'doctor': docObj,
                    'doctorName': doctor['name'],
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue),
              child: const Text("Book", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
