import 'package:clinic_appointment_system/core/constants/app_assets.dart';
import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/models/user_factory.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/security_utils.dart';
import '../widgets/custom_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passController = TextEditingController();

  TextEditingController rePassController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ClinicRepository _repository=ClinicRepository.getInstance();

  RoleType _selectedRole = RoleType.PATIENT;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (passController.text != rePassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
        return;
      }

      bool isEmailExists = await _repository.isEmailExists(emailController.text);
      if (isEmailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email already registered! Try Login."),backgroundColor: Colors.red,),
        );
        return;
      }
      String hashedPassword = SecurityUtils.hashPassword(passController.text);

      final newUser = UserFactory.createUser(
        name: usernameController.text,
        email: emailController.text,
        password: hashedPassword,
        role: _selectedRole,
      );
      int resultId = await _repository.registerUser(newUser);

      if (resultId > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account Created Successfully! with ID : $resultId'),backgroundColor: Colors.blue,),
          );
          Navigator.pushReplacementNamed(context,AppRoutesName.loginScreen);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Failed'),backgroundColor: Colors.red,),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Center(

            child: Column(
              children: [
                Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                  
                        CustomTextFormField(
                          Controller: usernameController,
                          hintText: "username",
                          icon: Icon(Icons.person_outlined),
                          isPass: false,
                          isEmail: false,
                          isSignUp: false,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        CustomTextFormField(
                          Controller: emailController,
                          hintText: "email",
                          icon: Icon(Icons.email_outlined),
                          isPass: false,
                          isSignUp: true,
                          isEmail: true,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        CustomTextFormField(
                          Controller: passController,
                          hintText: "password",
                          icon: Icon(Icons.password_outlined),
                          isPass: true,
                          isSignUp: true,
                          isEmail: false,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        CustomTextFormField(
                          Controller: rePassController,
                          hintText: "rePassword",
                          icon: Icon(Icons.password_outlined),
                          isPass: true,
                          isEmail: false,
                          isSignUp: false,
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Text(
                              "you are :",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            ChoiceChip(
                              label: Text("Patient"),
                              selected: _selectedRole == RoleType.PATIENT,
                              selectedColor: Colors.blue.shade100,
                              onSelected: (value) {
                                setState(() {
                                  _selectedRole = RoleType.PATIENT;
                                });
                              },
                            ),
                            Spacer(),
                            ChoiceChip(
                              label: Text("Doctor"),
                              selected: _selectedRole == RoleType.DOCTOR,
                              selectedColor: Colors.blue.shade100,
                              onSelected: (value) {
                                setState(() {
                                  _selectedRole = RoleType.DOCTOR;
                                });
                              },
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 20,),
                        CustomButton(
                          function: _signUp,
                          text: "Create account",
                        ),
                  
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
