import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/utils/security_utils.dart';
import '../../../../models/doctor_model.dart';
import '../../../../models/user_model.dart';
import '../../../auth/widgets/custom_button.dart';
import '../../../auth/widgets/custom_text_form_field.dart';
import '../../../core_widgets/custom_dropdown_adapter.dart';

class DoctorProfileScreen extends StatefulWidget {
  final int userId;

  const DoctorProfileScreen({super.key, required this.userId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreen();
}

class _DoctorProfileScreen extends State<DoctorProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  User? _currentUser;
  bool _isLoading = true;
  String? _selectedSpeciality;

  Doctor? _initialDoctorData;
  User? _initialUserData;
  List<String> _specialtiesList = [];

  final ClinicRepository _repository = ClinicRepository.getInstance();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    var list = await _repository.getSpecialties();
    var userMap = await _repository.getUserById(widget.userId);
    var doctorMap = await _repository.getDoctorDetails(widget.userId);

    if (userMap != null && doctorMap != null) {
      User user = userMap;
      Doctor doctor = doctorMap;

      if (!list.contains(doctor.specialty)) {
        list.add(doctor.specialty);
      }
      _specialtiesList = list.toSet().toList();

      nameController.text = user.name;
      emailController.text = user.email;
      priceController.text = doctor.price.toString();
      _selectedSpeciality = doctor.specialty;

      if (mounted) {
        setState(() {
          _currentUser = user;
          _initialUserData = user;
          _initialDoctorData = doctor;
          _isLoading = false;
        });
      }
    }
  }

  void _updateProfile() async {
    if (_selectedSpeciality == null ||
        priceController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill basic info"),
          backgroundColor: Colors.red));
      return;
    }
    if (!SecurityUtils.isValidEmail(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid Email Format"), backgroundColor: Colors.red));
      emailController.text = _initialUserData!.email;
      return;
    }
    if (double.tryParse(priceController.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid Price"), backgroundColor: Colors.red));
      priceController.clear();
      return;
    }

    bool passwordChanged = newPassController.text.trim().isNotEmpty;

    bool personalInfoChanged = nameController.text != _initialUserData!.name ||
        emailController.text != _initialUserData!.email;
    double newPrice = double.tryParse(priceController.text) ?? 0.0;

    bool clinicInfoChanged = newPrice != _initialDoctorData!.price ||
        _selectedSpeciality != _initialDoctorData!.specialty;

    if (!passwordChanged && !personalInfoChanged && !clinicInfoChanged) {
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
            content: Text("Weak Password!"), backgroundColor: Colors.red));
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

    String oldStatus = _initialDoctorData!.status;

    Doctor updatedDoctor = Doctor(
      userId: widget.userId,
      specialty: _selectedSpeciality!,
      price: newPrice,
      status: oldStatus,
    );
    await _repository.saveDoctorProfile(updatedDoctor);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile Updated Successfully!"),
          backgroundColor: Colors.blue));
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
              const SizedBox(height: 10),
              const Text("Clinic Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CustomDropDownAdapter(
                  key: ValueKey(_specialtiesList.length),
                  onChanged: (val) {
                    setState(() {
                      _selectedSpeciality = val;
                    });
                  },
                  selectedValue: _selectedSpeciality,
                  list: _specialtiesList,
                  label: "Speciality"),
              const SizedBox(height: 15),
              CustomTextFormField(
                  Controller: priceController,
                  hintText: "Session Price",
                  icon: const Icon(FontAwesomeIcons.dollarSign),
                  isPass: false,
                  isSignUp: false,
                  isEmail: false,
                  isPrice: true),
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