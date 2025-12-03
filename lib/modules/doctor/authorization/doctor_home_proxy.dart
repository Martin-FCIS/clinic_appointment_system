import 'package:clinic_appointment_system/modules/doctor/home/pages/doctor_home_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes_name.dart';
import '../../../models/doctor_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/clinic_repository.dart';
import '../home/widgets/custom_doctor_drawer.dart';

class DoctorHomeProxy extends StatefulWidget {
  final int userId;

  const DoctorHomeProxy({super.key, required this.userId});

  @override
  State<DoctorHomeProxy> createState() => _DoctorHomeProxyState();
}

class _DoctorHomeProxyState extends State<DoctorHomeProxy> {
  final ClinicRepository _repository = ClinicRepository.getInstance();

  User? _user;
  Doctor? _doctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var user = await _repository.getUserById(widget.userId);

    var raw = await _repository.getDoctorDetails(widget.userId);

    Doctor? doctor;
    if (raw != null) {
      doctor = raw;
    }

    if (mounted) {
      setState(() {
        _user = user;
        _doctor = doctor;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null || _doctor == null) {
      return const Scaffold(
        body: Center(child: Text("Doctor not found")),
      );
    }

    if (_doctor!.status != "approved") {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue,
          title: const Text("Clinic Application",
              style: TextStyle(fontSize: 30, color: Colors.white)),
          centerTitle: true,
        ),
        drawer: CustomDoctorDrawer(
          name: "Dr. ${_user!.name}",
          email: _user!.email,
          profileFun: () {},
          mySchedFun: () {},
          myAppointFun: () {},
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
                    child: const Text("logout",
                        style: TextStyle(color: Colors.red)),
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
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      _repository.deleteDoctor(widget.userId);
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(context,
                            AppRoutesName.loginScreen, (route) => false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, size: 50, color: Colors.orange),
              const SizedBox(height: 15),
              Text(
                "Your account is ${_doctor!.status}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Please wait for admin approval."),
            ],
          ),
        ),
      );
    }

    return DoctorHomeScreen(userId: widget.userId);
  }
}
