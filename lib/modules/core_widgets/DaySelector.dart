import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final Function(List<String>) onDaysSelected;
  const DaySelector({super.key, required this.onDaysSelected});

  @override
  _DaySelectorState createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  final List<String> days = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday"
  ];

  List<String> selectedDays = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day);
        return ChoiceChip(
          selectedColor: Color(secondaryColor),
          label: Text(day),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedDays.add(day);
              } else {
                selectedDays.remove(day);
              }
            });

            //widget.onDaysSelected(selectedDays);
          },
        );
      }).toList(),
    );
  }
}
