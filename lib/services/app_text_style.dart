import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'scale_util.dart';

class AppTextTheme {
  static TextTheme get lightTextTheme {
    return textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    );
  }

  static TextTheme get darkTextTheme {
    return textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
  }

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(32),
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(28),
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(24),
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(22),
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(20),
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(18),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(16),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(14),
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(12),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(16),
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(14),
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(12),
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(14),
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(12),
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(10),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _themeMode = Rx<ThemeMode>(ThemeMode.system);
  ThemeMode get themeMode => _themeMode.value;

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  ThemeData get lightTheme => ThemeData.light().copyWith(
        textTheme: AppTextTheme.lightTextTheme,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.white,
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        // Add other light theme properties here as needed
      );

  ThemeData get darkTheme => ThemeData.dark().copyWith(
        textTheme: AppTextTheme.darkTextTheme,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.grey[850]!,
          background: Colors.grey[900]!,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          color: Colors.grey[850],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        // Add other dark theme properties here as needed
      );
}