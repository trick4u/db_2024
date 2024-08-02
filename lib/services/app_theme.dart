// app_theme.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'scale_util.dart';

class AppTheme extends GetxController {
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal() {
    _loadTheme();
  }

  final _storage = GetStorage();
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  void _loadTheme() {
    _isDarkMode.value = _storage.read('isDarkMode') ?? false;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _storage.write('isDarkMode', _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
    surface: Colors.white,
    onSurface: Colors.black,
    onPrimaryContainer: Colors.black,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Colors.blueAccent,
    secondary: Colors.lightBlueAccent,
    surface: Color(0xFF303030),
    onSurface: Colors.white,
    onPrimaryContainer: Colors.white,
  );

  ColorScheme get colorScheme =>
      _isDarkMode.value ? darkColorScheme : lightColorScheme;

  Color get cardColor => colorScheme.surface;
  Color get textColor => colorScheme.onSurface;
  Color get secondaryTextColor => colorScheme.onSurface.withOpacity(0.7);
  Color get backgroundColor => colorScheme.background;

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

  ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: Size(double.infinity, 50),
      );

  ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        side: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
      );
}
