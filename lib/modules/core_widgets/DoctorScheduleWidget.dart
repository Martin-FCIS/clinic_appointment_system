import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:flutter/material.dart';

import '../../models/schedule_model.dart'; // import Schedule model

class DoctorScheduleWidget extends StatefulWidget {
  final int doctorId;
  //final Function(List<Schedule>) onSchedulesChanged;

  const DoctorScheduleWidget({
    super.key,
    required this.doctorId,
    //required this.onSchedulesChanged,
  });

  @override
  _DoctorScheduleWidgetState createState() => _DoctorScheduleWidgetState();
}

class _DoctorScheduleWidgetState extends State<DoctorScheduleWidget> {
  final List<String> weekDays = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday"
  ];

  List<Schedule> schedules = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          direction: Axis.vertical,
          runSpacing: 8,
          spacing: 8,
          children: weekDays.map((day) {
            final existingSchedule = schedules.firstWhere((s) => s.day == day,
                orElse: () => Schedule(
                    doctorId: widget.doctorId,
                    day: day,
                    startTime: "",
                    endTime: ""));

            final isSelected = existingSchedule.startTime.isNotEmpty;

            return ChoiceChip(
              selectedColor: Color(secondaryColor),
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) async {
                if (selected) {
                  final start = await pickTime(context, "Start Time");
                  final end = await pickTime(context, "End Time");

                  if (start != null && end != null) {
                    final startStr = formatTime(start);
                    final endStr = formatTime(end);

                    setState(() {
                      schedules.removeWhere((s) => s.day == day);
                      schedules.add(Schedule(
                        doctorId: widget.doctorId,
                        day: day,
                        startTime: startStr,
                        endTime: endStr,
                      ));
                    });

                    //widget.onSchedulesChanged(schedules);
                  }
                } else {
                  setState(() {
                    schedules.removeWhere((s) => s.day == day);
                  });
                  //widget.onSchedulesChanged(schedules);
                }
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16),
        ...schedules.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text("${s.day}: ${s.startTime} - ${s.endTime}"),
            )),
      ],
    );
  }

  Future<TimeOfDay?> pickTime(BuildContext context, String label) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked == null) return null;

    int hour = picked.hour;
    int minute = picked.minute;

    // Round to nearest 30 minutes
    if (minute >= 0 && minute < 15) {
      minute = 0;
    } else if (minute >= 15 && minute < 45) {
      minute = 30;
    } else {
      minute = 0;
      hour = (hour + 1) % 24;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatTime(TimeOfDay time) {
    return time.format(context);
  }
}
