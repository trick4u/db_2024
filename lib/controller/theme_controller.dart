import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  final GetStorage _box = GetStorage();
  final _key = 'isDarkMode';

  ThemeController() {
    isDarkMode.value = _box.read(_key) ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _box.write(_key, isDarkMode.value);
  }
}