// app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _isDarkMode = true.obs;
  bool get isDarkMode => _isDarkMode.value;

  void _loadTheme() {
    _isDarkMode.value = _storage.read('isDarkMode') ?? false;
    _applyTheme();
  }

  void toggleTheme() {
    _isDarkMode.toggle();
    _storage.write('isDarkMode', _isDarkMode.value);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    updateStatusBarColor();
    Get.forceAppUpdate();
  }

  void updateStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDarkMode.value ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: _isDarkMode.value ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness: _isDarkMode.value ? Brightness.light : Brightness.dark,
    ),);
  }

   void updateStatusBarColorSplash() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDarkMode.value ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: _isDarkMode.value ? Brightness.light : Brightness.dark,
    ),);
  }

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
    surface: Color(0xFFF5F5F5),
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
  Color get backgroundColor => colorScheme.surface;

  Color get textFieldFillColor =>
      _isDarkMode.value ? Color(0xFF424242) : Color(0xFFE0E0E0);

  TextStyle get titleLarge => TextStyle(
        fontSize: ScaleUtil.fontSize(20),
        fontWeight: FontWeight.bold,
        fontFamily: "Euclid",
        color: textColor,
      );

  TextStyle get bodyMedium => TextStyle(
        fontSize: ScaleUtil.fontSize(14),
        color: textColor,
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

      ThemeData get themeData => ThemeData(
    colorScheme: colorScheme,
    brightness: _isDarkMode.value ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: titleLarge,
      bodyMedium: bodyMedium,
    ),
  );
}
