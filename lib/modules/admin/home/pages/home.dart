import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/routes/app_routes_name.dart';
import '../../../doctor/home/widgets/CategoryCard.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CategoryCard(
                icon: FontAwesomeIcons.calendar, catName: "Appointments"),
            CategoryCard(
              catName: "Doctors",
              icon: FontAwesomeIcons.userDoctor,
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AppRoutesName.adminDoctorsScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
