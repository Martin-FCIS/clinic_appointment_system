import 'package:clinic_appointment_system/models/schedule_model.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ScheduleEditor extends StatefulWidget {
  final int doctorId;
  const ScheduleEditor({super.key, required this.doctorId});

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  late Future<List<Schedule>> _schedulesFuture;

  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  String? selectedDay;
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _repository.getDoctorSchedules(widget.doctorId);
  }

  void _refreshSchedules() {
    setState(() {
      _schedulesFuture = _repository.getDoctorSchedules(widget.doctorId);
    });
  }

  Future<void> _addSchedule() async {
    if (selectedDay == null || startTime == endTime || selectedDay == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select a day and a valid, non-empty time range.')),
      );
      return;
    }

    String start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    // Simple validation to ensure end time is after start time
    if (startTime.hour * 60 + startTime.minute >=
        endTime.hour * 60 + endTime.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time!')),
      );
      return;
    }

    final newSchedule = Schedule(
      doctorId: widget.doctorId,
      day: selectedDay!,
      startTime: start,
      endTime: end,
    );

    await _repository.addSchedule(newSchedule);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule added for ${selectedDay!}')),
    );
    _refreshSchedules();
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    await _repository.deleteSchedule(scheduleId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule deleted.')),
    );
    _refreshSchedules();
  }
  String _formatTo12Hour(String time24) {
    try {
      DateTime tempDate = DateFormat("HH:mm").parse(time24);
      return DateFormat("h:mm a").format(tempDate);
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Add New Schedule:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        // --- Add Schedule Section ---
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Day'),
          value: selectedDay,
          items: days
              .map((day) => DropdownMenuItem(value: day, child: Text(day)))
              .toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedDay = newValue;
            });
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(FontAwesomeIcons.clock, size: 16),
                label: Text("Start: ${startTime.format(context)}"),
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                      context: context, initialTime: startTime);
                  if (picked != null && picked != startTime) {
                    setState(() {
                      startTime = picked;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(FontAwesomeIcons.clock, size: 16),
                label: Text("End: ${endTime.format(context)}"),
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                      context: context, initialTime: endTime);
                  if (picked != null && picked != endTime) {
                    setState(() {
                      endTime = picked;
                    });
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addSchedule,
              child: const Text('Add'),
            ),
          ],
        ),
        const Divider(height: 30),

        const Text("Current Schedules:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        FutureBuilder<List<Schedule>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ));
            }
            if (snapshot.hasError) {
              return Text("Error loading schedules: ${snapshot.error}");
            }
            final schedules = snapshot.data ?? [];

            if (schedules.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text("No work schedule set."),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ListTile(
                  dense: true,
                  title: Text(schedule.day,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${_formatTo12Hour(schedule.startTime)} - ${_formatTo12Hour(schedule.endTime)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    // Use schedule.id to delete
                    onPressed: () => _deleteSchedule(schedule.id! as int),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
