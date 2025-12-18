import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes_name.dart';

class CustomAdminDrawer extends StatelessWidget {
  String name;
  String email;
  CustomAdminDrawer({
    super.key,
    required this.name,
    required this.email,
  });

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
              child: Icon(
                Icons.person_2_rounded,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text("Appointments"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, AppRoutesName.adminAppointmentsScreen);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text("Doctors"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, AppRoutesName.adminDoctorsScreen);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Logout ?",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}
