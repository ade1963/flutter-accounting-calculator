import 'package:flutter/material.dart';

class CalcStyle {
  static const double buttonFontSize = 40;
  static const double displayFontSize = 80;
  static const double expressionFontSize = 32; //should be devide by 4
  static const double histButtonFontSize = 30;
}


Widget buttonGradient(String label, op,
    {double fontSize = CalcStyle.buttonFontSize}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xFF009688),
                  Color(0xFF80CBC4),
                  Color(0xFFB2DFDB),
                ],
              ),
            ),
          ),
        ),
        SizedBox.expand(
            child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(4.0),
            primary: Colors.black,
            //textStyle: TextStyle(fontSize: fontSize),
          ),
          onPressed: () => op(label),
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
            '$label',
            style: TextStyle(fontSize: fontSize),
            maxLines: 1,
          )),
        )),
      ],
    ),
  );
}

Widget fittedTextBox(String value, double fontSize) {
  return SizedBox.expand(
    child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          (value == '' ? ' ' : value),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
          maxLines: 1,
        )),
  );
}
