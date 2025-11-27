import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/security_utils.dart';

class CustomTextFormField extends StatelessWidget {
  TextEditingController Controller;
  bool isSignUp;
  bool isPass;
  bool isEmail;
  String hintText;
  Icon icon;

  CustomTextFormField(
      {super.key,
      required this.Controller,
      required this.hintText,
      required this.icon,required this.isPass,required this.isSignUp,required this.isEmail});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "${hintText.toUpperCase()} is required";
        }
        if(isSignUp&&isEmail) {
          if (!SecurityUtils.isValidEmail(value)) {
            return "Invalid Email format";
          }
        }
           if(isSignUp&&!isEmail){
            if (!SecurityUtils.isStrongPassword(value)) {
              return "Weak Password! Use 8+ chars (letters & numbers)";
          }
        }

        return null;
      },
      controller: Controller,
      obscureText: isPass?true:false,
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
