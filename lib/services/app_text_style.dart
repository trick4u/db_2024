import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'scale_util.dart';

class AppTextTheme {
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
        textTheme: AppTextTheme.textTheme,
        // Add other light theme properties here
      );

  ThemeData get darkTheme => ThemeData.dark().copyWith(
        textTheme: AppTextTheme.textTheme,
        // Add other dark theme properties here
      );
}

class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal();

  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Define your color schemes
  static final ColorScheme lightColorScheme = ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
    surface: Colors.white,
    onSurface: Colors.black,
  );

  static final ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Colors.blueAccent,
    secondary: Colors.lightBlueAccent,
    surface: Colors.grey[800]!,
    onSurface: Colors.white,
  );

  ColorScheme get colorScheme =>
      _isDarkMode.value ? darkColorScheme : lightColorScheme;

  // Custom colors
  Color get cardColor => _isDarkMode.value ? Colors.grey[900]! : Colors.white;
  Color get textColor => _isDarkMode.value ? Colors.white : Colors.black;
  Color get secondaryTextColor =>
      _isDarkMode.value ? Colors.white70 : Colors.black54;

  // Text Styles
  TextStyle get titleLarge => TextStyle(
        fontSize: ScaleUtil.fontSize(20),
        fontWeight: FontWeight.bold,
        fontFamily: "Euclid",
        color: textColor,
      );

  TextStyle get bodyMedium => TextStyle(
        fontSize: ScaleUtil.fontSize(14),
        color: secondaryTextColor,
        fontFamily: "Euclid",
      );

  // Button Styles
  ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: _isDarkMode.value ? Colors.white : Colors.black,
        foregroundColor: _isDarkMode.value ? Colors.black : Colors.white,
        minimumSize: Size(double.infinity, 50),
      );

  ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        side: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
      );
}
