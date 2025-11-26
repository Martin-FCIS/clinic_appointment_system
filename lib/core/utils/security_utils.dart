import 'dart:convert';
 import 'package:crypto/crypto.dart';

class SecurityUtils {

  // 1. دالة تشفير الباسورد (SHA-256) 🔐
  static String hashPassword(String password) {
    var bytes = utf8.encode(password); // تحويل النص لـ bytes
    var digest = sha256.convert(bytes); // التشفير
    return digest.toString();
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }


  static bool isStrongPassword(String password) {
    final passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passRegex.hasMatch(password);
  }
}