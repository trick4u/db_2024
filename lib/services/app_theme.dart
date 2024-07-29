
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'scale_util.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'scale_util.dart';

class AppTheme {
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