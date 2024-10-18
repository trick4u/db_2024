import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ToastUtil {
  static void showToast(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
  }) {
    Fluttertoast.showToast(
      msg: "$title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: duration?.inSeconds ?? 3,
      backgroundColor: backgroundColor ?? Colors.grey,
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,

    );
  }
}
