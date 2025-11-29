import 'package:flutter/material.dart';

import '../../../../core/utils/security_utils.dart';
import '../../../../models/user_model.dart';
import '../../../../repositories/clinic_repository.dart';
import '../../../auth/widgets/custom_button.dart';
import '../../../auth/widgets/custom_text_form_field.dart';

class PatientProfileScreen extends StatefulWidget {
  final int userId;

  const PatientProfileScreen({super.key, required this.userId});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  User? _currentUser;
  bool _isLoading = true;
  User? _initialUserData;
  final ClinicRepository _repository = ClinicRepository.getInstance();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    var userMap = await _repository.getUserById(widget.userId);
    if (userMap != null) {
      User user = userMap;
      nameController.text = user.name;
      emailController.text = user.email;
      if (mounted) {
        setState(() {
          _currentUser = user;
          _initialUserData = user;
          _isLoading = false;
        });
      }
    }
  }

  void _updateProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill basic info"),
          backgroundColor: Colors.red));
      return;
    }
    if (!SecurityUtils.isValidEmail(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid Email Format (e.g. name@domain.com)"),
          backgroundColor: Colors.red));
      emailController.text = _initialUserData!.email;
      return;
    }
    bool passwordChanged = newPassController.text.trim().isNotEmpty;
    bool personalInfoChanged = nameController.text != _initialUserData!.name ||
        emailController.text != _initialUserData!.email;
    if (!passwordChanged && !personalInfoChanged) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No changes made."),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    String finalPassword = _currentUser!.password;
    if (passwordChanged) {
      if (currentPassController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Enter current password to change it"),
            backgroundColor: Colors.red));
        confirmPassController.clear();
        newPassController.clear();
        currentPassController.clear();
        return;
      }

      String hashedCurrentInput =
          SecurityUtils.hashPassword(currentPassController.text);
      if (hashedCurrentInput != _currentUser!.password) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Wrong Current Password!"),
            backgroundColor: Colors.red));
        confirmPassController.clear();
        newPassController.clear();
        currentPassController.clear();
        return;
      }

      if (newPassController.text != confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("New passwords do not match"),
            backgroundColor: Colors.red));
        confirmPassController.clear();
        newPassController.clear();
        currentPassController.clear();
        return;
      }
      if (!SecurityUtils.isStrongPassword(newPassController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Weak Password! Use 8+ chars (letters & numbers)"),
            backgroundColor: Colors.red));
        confirmPassController.clear();
        newPassController.clear();
        currentPassController.clear();
        return;
      }

      finalPassword = SecurityUtils.hashPassword(newPassController.text);
    }
    User updatedUser = User(
      id: _currentUser!.id,
      name: nameController.text,
      email: emailController.text,
      password: finalPassword,
      role: _currentUser!.role,
    );
    await _repository.updateUser(updatedUser);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile Updated Successfully!"),
          backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              const Text("Basic Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CustomTextFormField(
                  Controller: nameController,
                  hintText: "Full Name",
                  icon: const Icon(Icons.person),
                  isPass: false,
                  isSignUp: false,
                  isEmail: false),
              const SizedBox(height: 15),
              CustomTextFormField(
                  Controller: emailController,
                  hintText: "Email",
                  icon: const Icon(Icons.email),
                  isPass: false,
                  isSignUp: false,
                  isEmail: true),

              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 10),

              // Password
              const Text("Change Password (Optional)",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 15),
              CustomTextFormField(
                  Controller: currentPassController,
                  hintText: "Current Password",
                  icon: const Icon(Icons.lock_outline),
                  isPass: true,
                  isSignUp: false,
                  isEmail: false),
              const SizedBox(height: 15),
              CustomTextFormField(
                  Controller: newPassController,
                  hintText: "New Password",
                  icon: const Icon(Icons.lock),
                  isPass: true,
                  isSignUp: true,
                  isEmail: false),
              const SizedBox(height: 15),
              CustomTextFormField(
                  Controller: confirmPassController,
                  hintText: "Confirm New Password",
                  icon: const Icon(Icons.lock),
                  isPass: true,
                  isSignUp: false,
                  isEmail: false),

              const SizedBox(height: 25),
              const Divider(),
              SizedBox(height: 200,),
              CustomButton(function: _updateProfile, text: "Save Changes"),

              // Clinic Info
            ],
          ),
        ),
      ),
    );
  }
}
