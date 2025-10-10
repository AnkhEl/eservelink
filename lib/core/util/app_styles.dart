import 'package:flutter/material.dart';

class AppStyles {
  static TextStyle whiteTextStyle({required double fontSize}) {
    return TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle headingTextStyle({required double fontSize}) {
    return TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle normalTextStyle({required double fontSize}) {
    return TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }
}
