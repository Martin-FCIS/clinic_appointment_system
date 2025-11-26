import 'package:clinic_appointment_system/core/constants/app_assets.dart';
import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_text_form_field.dart';
import 'package:flutter/cupertino.dart';
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
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void _login() async {
    if (_formKey.currentState!.validate()) {
      var dbHelper = DatabaseHelper.getInstance();

      String hashedPassword = SecurityUtils.hashPassword(passController.text);

      var user = await dbHelper.loginUser(emailController.text, hashedPassword);

      if (user != null) {
        User currentUser = User.fromMap(user);
        print("Login Success: ${currentUser.name} - Role: ${currentUser.role}");
        emailController.clear();
        passController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome back, ${currentUser.name}!"),backgroundColor: Colors.blue,),
        );

        int role = user['role'];

        if (role == 1) {
          // Navigator.pushReplacementNamed(context, AppRoutesName.adminHome);
        } else if (role == 2) {
          // Navigator.pushReplacementNamed(context, AppRoutesName.doctorHome);
        } else {
          // Navigator.pushReplacementNamed(context, AppRoutesName.patientHome);
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
                CustomTextFormField(Controller: emailController, hintText: "email", icon: Icon(Icons.email_outlined),isPass: false,isSignUp: false,isEmail: false,),
                SizedBox(
                  height: 30,
                ),
                CustomTextFormField(Controller: passController, hintText: "password", icon: Icon(Icons.password_rounded), isPass: true,isEmail: false,isSignUp: false,),
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
                        Navigator.pushNamed(context, AppRoutesName.signUpScreen);
                      },
                    ),
                  ],
                ),
                Spacer(),
                CustomButton(function: _login,text: "Login",),
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
