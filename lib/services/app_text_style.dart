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
        fontSize: ScaleUtil.fontSize(32, min: 24, max: 40),
        fontWeight: FontWeight.bold,
        height: ScaleUtil.height(1.2),
      ),
      displayMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(28, min: 22, max: 34),
        fontWeight: FontWeight.bold,
        height: ScaleUtil.height(1.2),
      ),
      displaySmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(24, min: 20, max: 28),
        fontWeight: FontWeight.bold,
        height: ScaleUtil.height(1.2),
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(22, min: 18, max: 26),
        fontWeight: FontWeight.w600,
        height: ScaleUtil.height(1.3),
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(20, min: 16, max: 24),
        fontWeight: FontWeight.w600,
        height: ScaleUtil.height(1.3),
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(18, min: 14, max: 22),
        fontWeight: FontWeight.w600,
        height: ScaleUtil.height(1.3),
      ),
      titleLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(16, min: 14, max: 18),
        fontWeight: FontWeight.w600,
        height: ScaleUtil.height(1.4),
      ),
      titleMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(14, min: 12, max: 16),
        fontWeight: FontWeight.w600,
        height: ScaleUtil.height(1.4),
      ),
      titleSmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(12, min: 10, max: 14),
        fontWeight: FontWeight.w600,
        height: ScaleUtil.height(1.4),
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(16, min: 14, max: 18),
        fontWeight: FontWeight.normal,
        height: ScaleUtil.height(1.5),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(14, min: 12, max: 16),
        fontWeight: FontWeight.normal,
        height: ScaleUtil.height(1.5),
      ),
      bodySmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(12, min: 10, max: 14),
        fontWeight: FontWeight.normal,
        height: ScaleUtil.height(1.5),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(14, min: 12, max: 16),
        fontWeight: FontWeight.w500,
        height: ScaleUtil.height(1.4),
      ),
      labelMedium: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(12, min: 10, max: 14),
        fontWeight: FontWeight.w500,
        height: ScaleUtil.height(1.4),
      ),
      labelSmall: TextStyle(
        fontFamily: 'Euclid',
        fontSize: ScaleUtil.fontSize(10, min: 8, max: 12),
        fontWeight: FontWeight.w500,
        height: ScaleUtil.height(1.4),
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
