import 'package:flutter/material.dart';

class LightTheme {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.grey[200],
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.redAccent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[300],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.black54),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme(
      surface: Colors.white,
      onSurface: Colors.black,
      primary: Colors.red,
      onError: Colors.red,
      onSecondary: Colors.red,
      onPrimary: Colors.red,
      secondary: Colors.red,
      brightness: Brightness.light,
      error: Colors.red,
    ),
  );
}

class DarkTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.redAccent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white70),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme(
      background: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      primary: Colors.red,
      onError: Colors.red,
      onSecondary: Colors.red,
      onPrimary: Colors.red,
      secondary: Colors.red,
      brightness: Brightness.dark,
      error: Colors.red,
    
    ),
  );
}
