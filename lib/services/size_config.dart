import 'package:flutter/material.dart';

class ScaleUtil {
  static double? _screenWidth;
  static double? _screenHeight;
  static const double _baseWidth = 375.0; // Base width (e.g., iPhone X)
  static const double _baseHeight = 812.0; // Base height (e.g., iPhone X)

  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }

  static double scale(double size) {
    if (_screenWidth == null) return size;
    return size * (_screenWidth! / _baseWidth);
  }

  // Font size
  static double fontSize(double size) => scale(size);

  // Padding and Margin
  static EdgeInsets all(double value) => EdgeInsets.all(scale(value));

  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal),
      vertical: scale(vertical),
    );
  }

  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: scale(left),
      top: scale(top),
      right: scale(right),
      bottom: scale(bottom),
    );
  }

  // Width and Height
  static double width(double size) => scale(size);
  static double height(double size) {
    if (_screenHeight == null) return size;
    return size * (_screenHeight! / _baseHeight);
  }
}