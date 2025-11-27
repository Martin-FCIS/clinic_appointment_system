import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../db/database_helper.dart';
import '../../../../models/schedule_model.dart';

class DoctorScheduleScreen extends StatefulWidget {
  final int doctorId;

  const DoctorScheduleScreen({super.key, required this.doctorId});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  final List<String> _days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  // void _printAllDatabaseData() async {
  //   final db = await DatabaseHelper.getInstance().database;
  //
  //   print("\n📦 ========= DATABASE CONTENT ========= 📦");
  //
  //   // 1. طباعة الدكاترة
  //   var doctors = await db.query('doctors');
  //   print("👨‍⚕️ Doctors Table (${doctors.length}):");
  //   for (var d in doctors) print(d);
  //
  //   // 2. طباعة المواعيد
  //   var schedules = await db.query('schedules');
  //   print("\n📅 Schedules Table (${schedules.length}):");
  //   for (var s in schedules) print(s);
  //
  //   // 3. طباعة المستخدمين (عشان تتأكد من الـ IDs)
  //   var users = await db.query('users');
  //   print("\n👤 Users Table (${users.length}):");
  //   for (var u in users) print(u);
  //
  //   print("=========================================\n");
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() async {
    final db = DatabaseHelper.getInstance();
    final data = await db.getDoctorSchedules(widget.doctorId);

    if (mounted) {
      setState(() {
        _schedules = data.map((e) => Schedule.fromMap(e)).toList();
        _isLoading = false;
      });
    }
  }

  void _deleteSchedule(int scheduleId) async {
    await DatabaseHelper.getInstance().deleteSchedule(scheduleId);
    _loadSchedules(); // تحديث القائمة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Schedule removed successfully"),
          backgroundColor: Colors.red),
    );
  }

  void _showScheduleDialog({Schedule? existingSchedule}) {
    bool isEditing = existingSchedule != null;
    String selectedDay = existingSchedule?.day ?? _days[0];

    // تحويل الـ String (10:00) لـ TimeOfDay عشان نعرضه
    TimeOfDay? startTime = isEditing ? _parseTime(existingSchedule!.startTime) : null;
    TimeOfDay? endTime = isEditing ? _parseTime(existingSchedule!.endTime) : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Shift" : "Add New Shift"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                    onChanged: (val) => setDialogState(() => selectedDay = val!),
                    decoration: InputDecoration(labelText: "Day", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await _pickTime(startTime, null);
                            if (picked != null) setDialogState(() => startTime = picked);
                          },
                          child: Text(startTime?.format(context) ?? "Start"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("-"),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await _pickTime(null, startTime);
                            if (picked != null) setDialogState(() => endTime = picked);
                          },
                          child: Text(endTime?.format(context) ?? "End"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
            onPressed: () async {
            if (startTime != null && endTime != null) {

            // ====================================================
            // 🔥 هنا اللوجيك الجديد: التحقق من التداخل
            // ====================================================
            bool hasConflict = _isOverlapping(
            selectedDay,
            startTime!,
            endTime!,
            excludeId: existingSchedule?.id // بنبعت الـ ID لو تعديل عشان يتجاهله
            );

            if (hasConflict) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text("Conflict! This time overlaps with another shift."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            ),
            );
            return; // 🛑 وقف هنا ومتحفظش
            }

            // ====================================================
            // باقي كود الحفظ العادي بتاعك زي ما هو
            // ====================================================
            Schedule scheduleObj = Schedule(
            id: existingSchedule?.id,
            doctorId: widget.doctorId,
            day: selectedDay,
            startTime: '${startTime!.hour}:${startTime!.minute}',
            endTime: '${endTime!.hour}:${endTime!.minute}',
            );

            if (isEditing) {
            // ... كود الـ Update ...
            await DatabaseHelper.getInstance().deleteSchedule(existingSchedule!.id!);
            await DatabaseHelper.getInstance().addSchedule(scheduleObj.toMap());
            } else {
            // ... كود الـ Add ...
            await DatabaseHelper.getInstance().addSchedule(scheduleObj.toMap());
            }

            _loadSchedules();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Updated!" : "Added!"), backgroundColor: Colors.green));
            } else {
            // ... validation message ...
            }
            },
            child: Text(isEditing ? "Update" : "Add"),
            ),
              ],
            );
          },
        );
      },
    );
  }
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<TimeOfDay?> _pickTime(
      TimeOfDay? currentStart, TimeOfDay? referenceStart) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      // 1. شرط الدقائق (00 أو 30)
      if (picked.minute != 0 && picked.minute != 30) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please pick :00 or :30"),
            backgroundColor: Colors.orange));
        return null;
      }
      if (referenceStart != null) {
        int startMin = referenceStart.hour * 60 + referenceStart.minute;
        int endMin = picked.hour * 60 + picked.minute;
        if (endMin - startMin < 15) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("End time must be > Start by 15 mins"),
              backgroundColor: Colors.orange));
          return null;
        }
      }
      return picked;
    }
    return null;
  }
  int _timeStringToMinutes(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  bool _isOverlapping(String day, TimeOfDay newStart, TimeOfDay newEnd, {int? excludeId}) {
    int newStartMin = _timeOfDayToMinutes(newStart);
    int newEndMin = _timeOfDayToMinutes(newEnd);

    var daySchedules = _schedules.where((s) => s.day == day);

    for (var schedule in daySchedules) {
      if (excludeId != null && schedule.id == excludeId) continue;

      int existingStart = _timeStringToMinutes(schedule.startTime);
      int existingEnd = _timeStringToMinutes(schedule.endTime);

      if (newStartMin < existingEnd && existingStart < newEndMin) {
        return true;
      }
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(child: Icon(Icons.arrow_back,),onTap: () {
          Navigator.pop(context);
        },),
        centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text("Manage Schedule",style: TextStyle(color: Colors.white,fontSize: 30 ),), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showScheduleDialog();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calendar_today_outlined,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No schedules found. Add one!",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final item = _schedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () => _showScheduleDialog(existingSchedule: item),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(item.day.substring(0, 3).toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        title: Text(item.day,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item.startTime} - ${item.endTime}"),
                        // زرار الحذف
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deleteSchedule(item.id!),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
