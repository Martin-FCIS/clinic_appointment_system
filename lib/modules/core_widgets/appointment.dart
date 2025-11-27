import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        child: Container(
          child: ListTile(
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            subtitleTextStyle: TextStyle(color: Colors.white, fontSize: 14),
            leadingAndTrailingTextStyle: TextStyle(color: Colors.black),
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          FontAwesomeIcons.calendar,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '10/12/2025',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '10:12',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  FontAwesomeIcons.arrowRight,
                  color: Colors.black,
                ),
              ),
            ),
            title: const Text('user'),
            subtitle: const Text('doctor'),
            style: ListTileStyle.list,
          ),
        ),
      ),
    );
  }
}
