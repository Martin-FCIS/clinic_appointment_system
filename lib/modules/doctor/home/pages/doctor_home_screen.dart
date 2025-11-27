import 'package:clinic_appointment_system/models/doctor_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../db/database_helper.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/user_model.dart';

class DoctorHomeScreen extends StatefulWidget {
  final int userId;

  DoctorHomeScreen({super.key, required this.userId});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  User? _user;
  Doctor? _doctor;
  List<Schedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  void _getData() async {
    final db = DatabaseHelper.getInstance();
    var userMap = await db.getUserById(widget.userId);
    var doctorMap = await db.getDoctorDetails(widget.userId);
    if (userMap != null && doctorMap != null) {
      User userObj = userMap;
      Doctor doctorObj = Doctor.fromMap(doctorMap);
      var schedulesMapList = await db.getDoctorSchedules(doctorObj.id!);
      List<Schedule> scheduleList =
          schedulesMapList.map((item) => Schedule.fromMap(item)).toList();
      if (mounted) {
        setState(() {
          _user = userObj;
          _doctor = doctorObj;
          _schedules = scheduleList;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null || _doctor == null) {
      return const Scaffold(
          body: Center(child: Text("Error: Profile not found")));
    }
    return Scaffold(
      drawer:Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Welcome, Dr. ${_user!.name}",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _doctor!.status == "pending"
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Status : ${_doctor!.status}",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.highlight_off_rounded,
                      size: 50,
                    ),
                    Text(
                      "waiting Admin for Approve your Account",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              )
            : Column(
                children: [],
              ),
      ),
    );
  }
}
