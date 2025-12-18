import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/routes/app_routes_name.dart';
import '../../../../auth/widgets/custom_text_form_field.dart';
import '../../../../core_widgets/custom_dropdown.dart';

class AddDoctorScreen extends StatefulWidget {
  AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  List<Map<String, dynamic>> localDoctors = [];
  bool isLoaded = false;
  final TextEditingController specialityController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ClinicRepository _repository = ClinicRepository.getInstance();

  int selectedID = 0;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pending Doctors",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, AppRoutesName.adminDoctorsScreen);
          },
          icon: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _repository.getPendingDoctors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (!isLoaded) {
            localDoctors = List<Map<String, dynamic>>.from(snapshot.data!);
            isLoaded = true;
          }
          final doctorsList = localDoctors;
          print(doctorsList);
          specialityController.text =
              doctorsList.isEmpty ? "" : doctorsList[0]['specialty'];
          priceController.text =
              doctorsList.isEmpty ? "" : doctorsList[0]['price'].toString();

          selectedID = doctorsList.isEmpty ? 0 : doctorsList[0]['id'];
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SafeArea(child: SizedBox()),
                  CustomDropDown(
                    selectedValue: selectedID.toString(),
                    list: doctorsList.isEmpty
                        ? [
                            {'id': 0, 'name': "No doctors to show"}
                          ]
                        : doctorsList,
                    label: 'Choose Doctor',
                    onChanged: (value) {
                      selectedID = int.parse(value);
                      int counter = 0;

                      for (Map<String, dynamic> doc in doctorsList) {
                        if (doc['id'] == selectedID) {
                          specialityController.text = doc['specialty'];
                          priceController.text = doc['price'].toString();
                          print("${doc['id']} // $selectedID");
                          index = counter;
                          return;
                        }
                        counter++;
                      }
                      setState(() {});
                    },
                  ),
                  Spacer(),
                  CustomTextFormField(
                    Controller: specialityController,
                    hintText: 'speciality',
                    icon: Icon(FontAwesomeIcons.userDoctor),
                    isPass: false,
                    isSignUp: false,
                    isEmail: false,
                    isReadOnly: true,
                  ),
                  Spacer(),
                  CustomTextFormField(
                    isReadOnly: true,
                    Controller: priceController,
                    hintText: 'Enter Doctor Appointment Price',
                    icon: Icon(FontAwesomeIcons.dollarSign),
                    isPass: false,
                    isSignUp: false,
                    isEmail: false,
                    isPrice: true,
                  ),
                  Spacer(),
                  CustomButton(
                    function: () async {
                      if (_formKey.currentState!.validate()) {
                        await _repository.updateDoctorStatus(
                            selectedID, 'approved');

                        localDoctors.removeAt(index);
                        specialityController.text = "";
                        priceController.text = "";
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Doctor Approved Successfully'),
                          backgroundColor: Colors.blue,
                        ));
                        setState(() {});
                      }
                    },
                    text: 'Approve Doctor',
                  ),
                  Spacer(),
                  CustomButton(
                    color: Colors.red,
                    function: () {
                      if (_formKey.currentState!.validate()) {
                        _repository.deleteDoctor(selectedID);

                        localDoctors.removeAt(index);
                        specialityController.text = "";
                        priceController.text = "";

                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Doctor denied'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                    text: 'Decline Doctor',
                  ),
                  Spacer(flex: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
