import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  
  
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  textTheme: TextTheme(
    titleSmall: TextStyle(
      fontFamily: GoogleFonts.inder().fontFamily,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
    ),
  ),
);
