import 'package:clinic_appointment_system/modules/core_widgets/appointment.dart';
import 'package:clinic_appointment_system/modules/doctor/home/widgets/CategoryCard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CategoryCard(
                icon: FontAwesomeIcons.calendar, catName: "Appointments"),
            CategoryCard(
              catName: "Profile",
              icon: FontAwesomeIcons.userDoctor,
            ),
            AppointmentCard(),
          ],
        ),
      ),
    );
  }
}
