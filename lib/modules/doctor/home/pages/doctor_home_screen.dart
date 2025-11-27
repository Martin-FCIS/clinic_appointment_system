import 'package:clinic_appointment_system/models/doctor_model.dart';
import 'package:clinic_appointment_system/modules/doctor/home/widgets/custom_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes_name.dart';
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text(
                "Dr. ${_user!.name}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(_user!.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_2_rounded,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text("Home"),
              onTap: () {
                // اقفل الـ Drawer لما يضغط
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
               Navigator.pushNamed(context, AppRoutesName.DoctorProfileScreen,arguments: _user!.id).then((_){
                 _getData();
               });
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.blue),
              title: const Text("My Schedules"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutesName.DoctorScheduleScreen,
                  arguments: _doctor!.id,
                ).then((_){
                  _getData();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.blue),
              title: const Text("My Appointments"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                    context,
                    AppRoutesName.DoctorAppointmentsScreen,
                    arguments: _doctor!.id,

                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          "Clinic Application",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
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
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 30),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status: Active",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade800),
                          ),
                          Text("You are visible to patients"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      title: "Specialty",
                      value: _doctor!.specialty, // التخصص
                      icon: Icons.medical_services_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomCard(
                      title: "Price",
                      value: "${_doctor!.price} EGP", // السعر
                      icon: Icons.monetization_on_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Working Hours",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutesName.DoctorScheduleScreen,
                        arguments: _doctor!.id,
                      ).then((_){
                        _getData();
                      });
                      // Edit Action
                    },
                  )
                ],
              ),

              const SizedBox(height: 10),
              _schedules.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.calendar_month_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("No schedules added yet", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final schedule = _schedules[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          schedule.day.substring(0, 3).toUpperCase(),
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      title: Text(
                        schedule.day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${schedule.startTime} - ${schedule.endTime}",
                          style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}