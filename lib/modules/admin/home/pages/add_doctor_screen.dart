import 'package:clinic_appointment_system/modules/auth/widgets/custom_button.dart';
import 'package:clinic_appointment_system/modules/core_widgets/DaySelector.dart';
import 'package:clinic_appointment_system/modules/core_widgets/DoctorScheduleWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../db/database_helper.dart';
import '../../../auth/widgets/custom_text_form_field.dart';
import '../../../core_widgets/CustomDropDown.dart';

class AddDoctorScreen extends StatelessWidget {
  AddDoctorScreen({super.key});
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> l = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.getInstance().getAllDoctors(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final doctorsList = [
            {"id": 0, "name": ""}
          ];

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomDropDown(
                    list: doctorsList,
                    label: 'Choose Doctor',
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
                      if (_formKey.currentState!.validate()) {}
                    },
                    text: 'Add Doctor',
                  ),
                  Spacer(flex: 4),
                  DaySelector(onDaysSelected: (l) {
                    print('hi');
                  }),
                  DoctorScheduleWidget(doctorId: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
