import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/const_variables.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/utils/security_utils.dart';
import '../../../../db/database_helper.dart';
import '../../../../models/doctor_model.dart';
import '../../../../models/user_model.dart';
import '../../../auth/widgets/custom_button.dart';
import '../../../auth/widgets/custom_text_form_field.dart';
import '../../../core_widets/custom_drop_down_adapter.dart';

class DoctorProfileScreen extends StatefulWidget {
  final int userId;
  const DoctorProfileScreen({super.key, required this.userId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreen();
}

class _DoctorProfileScreen extends State<DoctorProfileScreen> {
  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // Password Controllers
  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  User? _currentUser;
  bool _isLoading = true;
  String? _selectedSpeciality;

  Doctor? _initialDoctorData;
  User? _initialUserData;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    final db = DatabaseHelper.getInstance();
    var userMap = await db.getUserById(widget.userId);
    var doctorMap = await db.getDoctorDetails(widget.userId);

    if (userMap != null && doctorMap != null) {
      User user = userMap;
      Doctor doctor = Doctor.fromMap(doctorMap);

      // ملء الـ UI
      nameController.text = user.name;
      emailController.text = user.email;
      priceController.text = doctor.price.toString();
      _selectedSpeciality = doctor.specialty;

      if (mounted) {
        setState(() {
          _currentUser = user;

          // حفظ النسخة الأصلية للمقارنة
          _initialUserData = user;
          _initialDoctorData = doctor;

          _isLoading = false;
        });
      }
    }
  }

  void _updateProfile() async {
    if (_selectedSpeciality == null || priceController.text.isEmpty || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill basic info"), backgroundColor: Colors.red));
      return;
    }

    bool passwordChanged = newPassController.text.isNotEmpty;

    bool personalInfoChanged =
        nameController.text != _initialUserData!.name ||
            emailController.text != _initialUserData!.email;

    bool clinicInfoChanged =
        double.parse(priceController.text) != _initialDoctorData!.price ||
            _selectedSpeciality != _initialDoctorData!.specialty;

    // لو مفيش أي حاجة اتغيرت
    if (!passwordChanged && !personalInfoChanged && !clinicInfoChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No changes made."),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          )
      );
      return; // 🚪 اخرج
    }

    String finalPassword = _currentUser!.password;

    if (passwordChanged) {
      if (currentPassController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter current password to change it"), backgroundColor: Colors.red));
        return;
      }

      String hashedCurrentInput = SecurityUtils.hashPassword(currentPassController.text);
      if (hashedCurrentInput != _currentUser!.password) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wrong Current Password!"), backgroundColor: Colors.red));
        return;
      }

      if (newPassController.text != confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New passwords do not match"), backgroundColor: Colors.red));
        return;
      }

      finalPassword = SecurityUtils.hashPassword(newPassController.text);
    }

    final db = DatabaseHelper.getInstance();

    User updatedUser = User(
      id: _currentUser!.id,
      name: nameController.text,
      email: emailController.text,
      password: finalPassword,
      role: _currentUser!.role,
    );
    await db.updateUser(updatedUser);

    String oldStatus = _initialDoctorData!.status;

    Doctor updatedDoctor = Doctor(
      userId: widget.userId,
      specialty: _selectedSpeciality!,
      price: double.tryParse(priceController.text) ?? 0.0,
      status: oldStatus,
    );
    await db.saveDoctorProfile(updatedDoctor.toMap());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.btnColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              const Text("Basic Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CustomTextFormField(Controller: nameController, hintText: "Full Name", icon: const Icon(Icons.person), isPass: false, isSignUp: false, isEmail: false),
              const SizedBox(height: 15),
              CustomTextFormField(Controller: emailController, hintText: "Email", icon: const Icon(Icons.email), isPass: false, isSignUp: false, isEmail: true),

              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 10),

              // Password
              const Text("Change Password (Optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 15),
              CustomTextFormField(Controller: currentPassController, hintText: "Current Password", icon: const Icon(Icons.lock_outline), isPass: true, isSignUp: false, isEmail: false),
              const SizedBox(height: 15),
              CustomTextFormField(Controller: newPassController, hintText: "New Password", icon: const Icon(Icons.lock), isPass: true, isSignUp: true, isEmail: false),
              const SizedBox(height: 15),
              CustomTextFormField(Controller: confirmPassController, hintText: "Confirm New Password", icon: const Icon(Icons.lock), isPass: true, isSignUp: false, isEmail: false),

              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 10),

              // Clinic Info
              const Text("Clinic Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CustomDropDownAdapter(onChanged: (val) { setState(() { _selectedSpeciality = val; }); }, selectedValue: _selectedSpeciality, list: ConstVariables.speciality, label: "Speciality"),
              const SizedBox(height: 15),
              CustomTextFormField(Controller: priceController, hintText: "Session Price", icon: const Icon(Icons.monetization_on), isPass: false, isSignUp: false, isEmail: false, isPrice: true),

              const SizedBox(height: 40),
              CustomButton(function: _updateProfile, text: "Save Changes"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}