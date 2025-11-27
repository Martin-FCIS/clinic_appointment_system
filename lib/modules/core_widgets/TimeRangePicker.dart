import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:flutter/material.dart';

class TimeRangePicker extends StatefulWidget {
  //final Function(TimeOfDay from, TimeOfDay to) onTimeSelected;

  const TimeRangePicker({
    super.key,
  });

  @override
  _TimeRangePickerState createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future pickStartTime() async {
    final time = await showTimePicker(
      barrierColor: Color(secondaryColor),
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => startTime = time);
    }
  }

  Future pickEndTime() async {
    final time = await showTimePicker(
      barrierColor: Color(secondaryColor),
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => endTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 40,
          child: MaterialButton(
            color: Color(secondaryColor),
            onPressed: pickStartTime,
            child: Text(
              startTime == null
                  ? "Select Start Time"
                  : "From: ${startTime!.format(context)}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          height: 40,
          child: MaterialButton(
            color: Color(secondaryColor),
            onPressed: pickEndTime,
            child: Text(
              endTime == null
                  ? "Select End Time"
                  : "To: ${endTime!.format(context)}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
