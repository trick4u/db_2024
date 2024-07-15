import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Euclid';

  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
    color: Colors.black,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: Colors.black,
  );

  static const TextStyle italic = TextStyle(
    fontFamily: fontFamily,
    fontStyle: FontStyle.italic,
    fontSize: 16.0,
    color: Colors.black,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: Colors.black,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
    color: Colors.black,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
    color: Colors.grey,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: Colors.white,
  );
}