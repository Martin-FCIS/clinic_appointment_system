import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../db/database_helper.dart';
import '../../../auth/widgets/custom_text_form_field.dart';
import '../../../core_widgets/custom_dropdown.dart';

class AddDoctorScreen extends StatefulWidget {
  AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final TextEditingController specialityController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int selectedID = 0;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.getInstance().getPendingDoctors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final doctorsList = snapshot.data;
          selectedID = doctorsList!.isEmpty ? 0 : doctorsList[0]['id'];
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
                      setState(() {
                        selectedID = int.parse(value);
                        int counter = 0;
                        for (Map<String, dynamic> doc in snapshot.data!) {
                          if (doc['id'] == selectedID) {
                            specialityController.text = doc['speciality'];
                            priceController.text = doc['price'];
                            index = counter;
                          }
                          counter++;
                          return;
                        }
                      });
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
                    isNum: true,
                  ),
                  Spacer(),
                  CustomButton(
                    function: () {
                      if (_formKey.currentState!.validate()) {
                        DatabaseHelper.getInstance()
                            .updateDoctorStatus(selectedID, 'approved');
                        setState(() {
                          doctorsList.removeAt(index);
                          specialityController.text = "";
                          priceController.text = "";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Doctor Approved Successfully')));
                      }
                    },
                    text: 'Approve Doctor',
                  ),
                  Spacer(),
                  CustomButton(
                    color: Colors.red,
                    function: () {
                      if (_formKey.currentState!.validate()) {
                        DatabaseHelper.getInstance()
                            .updateDoctorStatus(selectedID, 'denied');
                        setState(() {
                          doctorsList.removeAt(index);
                          specialityController.text = "";
                          priceController.text = "";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Doctor denied')));
                      }
                    },
                    text: 'Decline Doctor',
                  ),
                  Spacer(flex: 4),
                  // DaySelector(onDaysSelected: (l) {
                  //   print('hi');
                  // }),
                  //DoctorScheduleWidget(doctorId: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
