import 'package:clinic_appointment_system/core/constants/const_variables.dart';
import 'package:clinic_appointment_system/modules/admin/home/widgets/schedule_editor.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/modules/auth/widgets/custom_text_form_field.dart';
import 'package:clinic_appointment_system/modules/core_widgets/custom_dropdown_adapter.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String selectedValue;
  final TextEditingController priceController = TextEditingController();

  Map<String, dynamic>? doctorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    final data = await _repository.getDoctorById(widget.doctorId);
    doctorData = data;
    if (mounted && doctorData != null) {
      selectedValue = doctorData!['specialty'];
      priceController.text = doctorData!['price'].toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateDoctor() async {
    if (_formKey.currentState!.validate()) {
      // Basic input validation for price
      if (double.tryParse(priceController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid price value."),
              backgroundColor: Colors.red),
        );
        return;
      }

      await _repository.updateDoctor(
        widget.doctorId,
        selectedValue,
        double.parse(priceController.text.trim()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Doctor info updated successfully!"),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteDoctor() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete ${doctorData!['name']} and their user account? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteDoctor(widget.doctorId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("${doctorData!['name']} deleted successfully!"),
            backgroundColor: Colors.red),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          appBar: null, body: Center(child: CircularProgressIndicator()));
    }

    if (doctorData == null) {
      return Scaffold(
          appBar: AppBar(title: const Text("Doctor Not Found")),
          body: const Center(
              child:
                  Text("Could not load doctor details. ID may be invalid.")));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Edit Doctor: ${doctorData!['name']}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doctor Details (Read-only)
              Text("Name: ${doctorData!['name']}",
                  style: Theme.of(context).textTheme.headlineSmall),
              Text("Email: ${doctorData!['email']}",
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider(height: 30),

              // Specialty Field
              CustomDropDownAdapter(
                  list: ConstVariables.speciality,
                  label: "Speciality",
                  selectedValue: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  }),
              const SizedBox(height: 20),

              // Price Field
              CustomTextFormField(
                Controller: priceController,
                hintText: 'Appointment Price',
                icon: const Icon(FontAwesomeIcons.dollarSign),
                isPass: false,
                isSignUp: false,
                isEmail: false,
                isPrice: true,
              ),
              const SizedBox(height: 30),

              // Update Button
              CustomButton(
                function: _updateDoctor,
                text: 'Update Info',
              ),
              const SizedBox(height: 40),

              // Schedule Editor (Days and Times)
              ScheduleEditor(doctorId: widget.doctorId),

              const SizedBox(height: 40),

              // Delete Button
              CustomButton(
                color: Colors.red,
                function: _deleteDoctor,
                text: 'Delete Doctor',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
