import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.icon, required this.catName});
  final icon;
  final String catName;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(btnColor),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {},
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: MediaQuery.sizeOf(context).width * 0.3,
              ),
              Text(
                catName,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              )
            ],
          ),
        ),
      ),
    );
  }
}
