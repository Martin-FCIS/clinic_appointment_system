import 'package:flutter/material.dart';

import 'custom_dropdown.dart';

class CustomDropDownAdapter extends StatelessWidget {
  const CustomDropDownAdapter(
      {super.key,
      required this.list,
      required this.label,
      required this.onChanged,
      this.selectedValue});
  final List<String> list;
  final String label;
  final void Function(dynamic)? onChanged;
  final dynamic selectedValue;
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> mapList = [];
    int counter = 0;
    for (String item in list) {
      mapList.add({'id': counter, 'name': item});
      counter++;
    }
    return CustomDropDown(
      onChanged: (val) {
        onChanged!(val.toString());
      },
      selectedValue: selectedValue,
      list: mapList,
      label: label,
    );
  }
}
