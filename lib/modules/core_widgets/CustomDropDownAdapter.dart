import 'package:clinic_appointment_system/modules/core_widgets/CustomDropDown.dart';
import 'package:flutter/material.dart';

class CustomDropDownAdapter extends StatelessWidget {
  const CustomDropDownAdapter(
      {super.key,
      required this.list,
      required this.label,
      this.isDisabled = false});
  final List<String> list;
  final String label;
  final bool isDisabled;
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> mapList = [];
    int counter = 0;
    for (String item in list) {
      mapList.add({'id': counter, 'name': item});
      counter++;
    }
    return CustomDropDown(
      list: mapList,
      label: label,
      isDisabled: isDisabled,
    );
  }
}
