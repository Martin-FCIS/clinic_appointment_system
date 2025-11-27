import 'package:clinic_appointment_system/core/constants/const_variables.dart';
import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/core/themes/themes.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_text_form_field.dart';
import 'package:clinic_appointment_system/modules/core_widets/custom_drop_down_adapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../db/database_helper.dart';
import '../../../../models/doctor_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/user_model.dart';

class WorkDayHelper {
  String dayName;
  bool isSelected;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  WorkDayHelper(
      {required this.dayName,
      this.isSelected = false,
      this.startTime,
      this.endTime});
}

class DoctorRegistrationScreen extends StatefulWidget {
  final int userId;

  DoctorRegistrationScreen({super.key, required this.userId});

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  TextEditingController priceController = TextEditingController();
  User? _currentUser;
  bool _isLoading = true;
  String? _selectedSpeciality;
  final List<WorkDayHelper> _uiDays = [
    WorkDayHelper(dayName: 'Saturday'),
    WorkDayHelper(dayName: 'Sunday'),
    WorkDayHelper(dayName: 'Monday'),
    WorkDayHelper(dayName: 'Tuesday'),
    WorkDayHelper(dayName: 'Wednesday'),
    WorkDayHelper(dayName: 'Thursday'),
    WorkDayHelper(dayName: 'Friday'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    var user = await DatabaseHelper.getInstance().getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickTime(WorkDayHelper day, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // معلومة: ممكن نستخدم builder عشان نحدد الدقائق المتاحة بس ده معقد
      // الأسهل نعمل validation بعد الاختيار زي ما انت طلبت
    );

    if (picked != null) {
      // 1. شرط الدقائق (00 أو 30 فقط) ⏰
      if (picked.minute != 0 && picked.minute!=15 && picked.minute != 30 &&picked.minute!=45) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select valid time (e.g. 7:00, 7:15 , 7:30 , 7:45)"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      int pickedInMinutes = picked.hour * 60 + picked.minute;

      if (isStart) {
        if (day.endTime != null) {
          int endInMinutes = day.endTime!.hour * 60 + day.endTime!.minute;


          if (endInMinutes - pickedInMinutes < 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Start time must be before End time by at least 15 mins"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        setState(() => day.startTime = picked);

      } else {
        if (day.startTime != null) {
          int startInMinutes = day.startTime!.hour * 60 + day.startTime!.minute;

          if (pickedInMinutes - startInMinutes < 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("End time must be after Start time by at least 15 mins"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        setState(() => day.endTime = picked);
      }
    }
  }

  void _saveAllData() async {
    if (_selectedSpeciality == null || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill Price & Specialty"),backgroundColor: Colors.red,));
      return;
    }

    Doctor newDoctor = Doctor(
      userId: widget.userId,
      specialty: _selectedSpeciality!,
      price: double.tryParse(priceController.text) ?? 0.0,
      status: 'pending',
    );

    final db = DatabaseHelper.getInstance();

    await db.saveDoctorProfile(newDoctor.toMap());

    var doctorMap = await db.getDoctorDetails(widget.userId);

    Doctor savedDoctor = Doctor.fromMap(doctorMap!);
    int realDoctorId = savedDoctor.id!;

    await db.deleteSchedulesByDoctorId(realDoctorId);
    int schedulesAdded = 0;

    for (var uiDay in _uiDays) {
      if (uiDay.isSelected &&
          uiDay.startTime != null &&
          uiDay.endTime != null) {
        Schedule schedule = Schedule(
          doctorId: realDoctorId,
          day: uiDay.dayName,
          startTime: '${uiDay.startTime!.hour}:${uiDay.startTime!.minute}',
          endTime: '${uiDay.endTime!.hour}:${uiDay.endTime!.minute}',
        );

        await db.addSchedule(schedule.toMap());
        schedulesAdded++;
      }
    }
    print("\n🔍 ============ DEBUGGING DATABASE START ============");

    final dbInstance = DatabaseHelper.getInstance();
    final dbb = await dbInstance.database;


    var allDoctors = await dbb.query('doctors');
    print("👨‍⚕️ DOCTORS TABLE (${allDoctors.length} rows):");
    for (var row in allDoctors) {
      print(row);
    }

    var allSchedules = await dbb.query('schedules');
    print("\n📅 SCHEDULES TABLE (${allSchedules.length} rows):");
    for (var row in allSchedules) {
      print(row);
    }

    print("🔍 ============ DEBUGGING DATABASE END ============\n");

    // ============================================================
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Request Sent! Pending Admin Approval. ($schedulesAdded shifts added)"),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutesName.DoctorHomeScreen,
            (route) => false,
        arguments: _currentUser!.id,
      );    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (AppColors.btnColor),
        title: Text(
          "Doctor Profile",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please Complete your Registration!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Name: ${_currentUser?.name}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Email: ${_currentUser?.email}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Choose your Speciality:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            CustomDropDownAdapter(
              onChanged: (val) {
                _selectedSpeciality=val;
              },
                selectedValue: _selectedSpeciality,
                list: ConstVariables.speciality, label: "Speciality:"),
            SizedBox(
              height: 5,
            ),
            Text("Enter your Price per Session :",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 10,
            ),
            CustomTextFormField(
                Controller: priceController,
                hintText: "eg..100",
                icon: Icon(Icons.monetization_on),
                isPass: false,
                isSignUp: false,
                isEmail: false),
            SizedBox(
              height: 20,
            ),
            Text("Enter your available slots per week :",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
            SizedBox(height: 5,),
            Expanded(
              flex: 50,
              child: ListView.builder(
                itemCount: _uiDays.length,
                itemBuilder: (context, index) {
                  final day = _uiDays[index];
                  return Card(
                    color: day.isSelected ? Colors.blue.shade100 : null,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text(day.dayName),
                          value: day.isSelected,
                          onChanged: (val) =>
                              setState(() => day.isSelected = val!),
                        ),
                        if (day.isSelected)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _pickTime(day, true),
                                    child: Text(
                                        day.startTime?.format(context) ??
                                            "Start"),
                                  ),
                                ),
                                const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("TO")),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _pickTime(day, false),
                                    child: Text(
                                        day.endTime?.format(context) ?? "End"),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
            ),
            Spacer(),
            CustomButton(function: _saveAllData, text: "Confirm"),

          ],
        ),
      ),
    );
  }
}
