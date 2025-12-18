import 'package:clinic_appointment_system/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomDoctorDrawer extends StatelessWidget {
  String name;
  String email;
  Function() profileFun;
  Function()? mySchedFun;
  Function() myAppointFun;
  Function() logoutFun;
  Function() deleteAccFun;
  bool isDoctor;
   CustomDoctorDrawer({super.key,required this.name,required this.email,required this.profileFun, this.mySchedFun,required this.myAppointFun,required this.logoutFun,required this.deleteAccFun,this.isDoctor=true});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            accountName: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: isDoctor?Image.asset(AppAssets.doctorIcon,height: 52,):Icon(Icons.person_rounded,size: 50,color: Colors.blue,),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile"),
            onTap: () {
              profileFun();
            },
          ),
          if(isDoctor)ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text("My Schedules"),
            onTap: () {
              mySchedFun!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text("My Appointments"),
            onTap: () {
             myAppointFun();
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
          onTap:(){
              logoutFun();
          },
          ),
          ListTile(
            leading:
            const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text("Delete Account",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              deleteAccFun();
            },
          ),
        ],
      ),
    );
  }
}
