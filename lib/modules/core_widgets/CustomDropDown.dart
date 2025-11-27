import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/themes/themes.dart';

class CustomDropDown extends StatefulWidget {
  CustomDropDown(
      {super.key,
      required this.list,
      required this.label,
      this.isDisabled = false});
  List<Map<String, dynamic>> list;
  final String label;
  final bool isDisabled;
  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String? selectedValue;
  init() {
    selectedValue = widget.list[0]['id'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      decoration: InputDecoration(
          icon: Icon(FontAwesomeIcons.userDoctor),
          labelText: widget.label,
          labelStyle: TextStyle(color: Color(secondaryColor)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(secondaryColor))),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(secondaryColor))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(secondaryColor))),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(secondaryColor)))),
      value: selectedValue,
      items: widget.list.map((value) {
        return DropdownMenuItem(
            value: value['id'].toString(),
            child: Text(
              value['name'],
            ));
      }).toList(),
      onChanged: widget.isDisabled
          ? null
          : (value) {
              setState(() {
                selectedValue = value;
              });
            },
    );
  }
}
