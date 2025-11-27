import 'package:flutter/material.dart';

import '../../../core/utils/security_utils.dart';

class CustomTextFormField extends StatelessWidget {
  TextEditingController Controller;
  bool isSignUp;
  bool isPass;
  bool isEmail;
  bool isNum;
  bool isReadOnly;
  String hintText;
  Icon icon;

  CustomTextFormField({
    super.key,
    required this.Controller,
    required this.hintText,
    required this.icon,
    required this.isPass,
    required this.isSignUp,
    required this.isEmail,
    this.isNum = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: isReadOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "${hintText.toUpperCase()} is required";
        }
        if (isSignUp && isEmail) {
          if (!SecurityUtils.isValidEmail(value)) {
            return "Invalid Email format";
          }
        }
        if (isSignUp && !isEmail) {
          if (!SecurityUtils.isStrongPassword(value)) {
            return "Weak Password! Use 8+ chars (letters & numbers)";
          }
        }
        if (isNum) {
          if (double.tryParse(value) == null) {
            return "Please enter a valid number";
          }
        }
        return null;
      },
      controller: Controller,
      obscureText: isPass ? true : false,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          hintStyle: TextStyle(color: Colors.grey),
          //hintText: "email",
          hintText: hintText,
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          //prefixIcon: Icon(Icons.email_outlined)),
          prefixIcon: icon),
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    );
  }
}
