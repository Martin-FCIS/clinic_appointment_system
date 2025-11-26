import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
    Function() function;
    String text;
   CustomButton({super.key,required this.function,required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.all(16)),
              onPressed: () {
               function();
              },
              child: Text(
                text, style: TextStyle(color: Colors.white, fontSize: 22),)),
        ),
      ],
    );
  }
}
