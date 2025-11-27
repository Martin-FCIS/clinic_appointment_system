import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/themes.dart';

class CustomDropDown extends StatefulWidget {
  final String label;
  final void Function(dynamic)? onChanged;
   final dynamic selectedValue;
  List<Map<String, dynamic>> list;

  CustomDropDown({super.key, required this.list, required this.label,required this.onChanged,this.selectedValue});

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      decoration: InputDecoration(
          icon: Icon(FontAwesomeIcons.userDoctor),
          labelText: widget.label,
          labelStyle: TextStyle(color: (AppColors.secondaryColor)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: (AppColors.secondaryColor))),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: (AppColors.secondaryColor))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: (AppColors.secondaryColor))),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: (AppColors.secondaryColor)))),
      value: widget.selectedValue,
      items: widget.list.map((value) {
        return DropdownMenuItem(
            value: value['id'].toString(),
            child: Text(
              value['name'],
            ));
      }).toList(),
      onChanged:widget.onChanged,
    );
  }
}