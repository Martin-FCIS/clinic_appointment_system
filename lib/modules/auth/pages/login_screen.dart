import 'package:clinic_appointment_system/core/constants/app_assets.dart';
import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_text_form_field.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/security_utils.dart';
import '../../../db/database_helper.dart';
import '../../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ClinicRepository _repository = ClinicRepository.getInstance();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String hashedPassword = SecurityUtils.hashPassword(passController.text);

      User? currentUser =
          await _repository.login(emailController.text, hashedPassword);

      if (currentUser != null) {
        print("Login Success: ${currentUser.name} - Role: ${currentUser.role}");
        emailController.clear();
        passController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome back, ${currentUser.name}!"),
            backgroundColor: Colors.blue,
          ),
        );

        int role = currentUser.role;
        if (role == 2) {
          //doctor
          var doctorProfile =
              await _repository.getDoctorDetails(currentUser.id!);
          if (doctorProfile == null) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutesName.doctorRegistrationScreen,
              arguments: currentUser.id,
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutesName.doctorProxy,
                arguments: currentUser.id);
            print("Go to Doctor Home");
          }
        } else if (currentUser.role == 1) {
          // Admin
          Navigator.pushReplacementNamed(
              context, AppRoutesName.adminHomeScreen);
        } else {
          // Patient
          Navigator.pushReplacementNamed(
              context, AppRoutesName.patientHomeScreen,
              arguments: currentUser.id);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Email or Password"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _printAllDatabaseData() async {
    final db = await DatabaseHelper.getInstance().database;

    print("\n📦 ========= DATABASE CONTENT ========= 📦");

    // 1. طباعة الدكاترة
    var doctors = await db.query('doctors');
    print("👨‍⚕️ Doctors Table (${doctors.length}):");
    for (var d in doctors) print(d);

    // 2. طباعة المواعيد
    var schedules = await db.query('schedules');
    print("\n📅 Schedules Table (${schedules.length}):");
    for (var s in schedules) print(s);

    // 3. طباعة المستخدمين (عشان تتأكد من الـ IDs)
    var users = await db.query('users');
    print("\n👤 Users Table (${users.length}):");
    for (var u in users) print(u);

    // 4. طباعة الحجوزات (Appointments) 🏥
    var appointments = await db.query('appointments');
    print("\n🏥 Appointments Table (${appointments.length}):");
    for (var a in appointments) print(a);

    print("=========================================\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
                Spacer(),
                CustomTextFormField(
                  Controller: emailController,
                  hintText: "email",
                  icon: Icon(Icons.email_outlined),
                  isPass: false,
                  isSignUp: false,
                  isEmail: false,
                ),
                SizedBox(
                  height: 30,
                ),
                CustomTextFormField(
                  Controller: passController,
                  hintText: "password",
                  icon: Icon(Icons.password_rounded),
                  isPass: true,
                  isEmail: false,
                  isSignUp: false,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Don't have account ? ",
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                    InkWell(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutesName.signUpScreen);
                      },
                    ),
                  ],
                ),
                Spacer(),
                CustomButton(
                  function: () {
                    _printAllDatabaseData();
                    _login();
                  },
                  text: "Login",
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
