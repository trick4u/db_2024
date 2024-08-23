import 'package:flutter/material.dart';
import 'dart:math' as math;
class ScaleUtil {
  static double? _screenWidth;
  static double? _screenHeight;
  static const double _baseWidth = 375.0; // Base width (e.g., iPhone X)
  static const double _baseHeight = 812.0; // Base height (e.g., iPhone X)
  static double? _textScaleFactor;
  static double? _pixelRatio;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _pixelRatio = mediaQuery.devicePixelRatio;
  }

  static double scale(double size) {
    if (_screenWidth == null) return size;
    return size * (_screenWidth! / _baseWidth);
  }

  static double scaleHeight(double size) {
    if (_screenHeight == null) return size;
    return size * (_screenHeight! / _baseHeight);
  }

  // Scaling with minimum and maximum constraints
  static double scaleWithConstraints(double size, {double? min, double? max}) {
    double scaledSize = scale(size);
    if (min != null) scaledSize = math.max(min, scaledSize);
    if (max != null) scaledSize = math.min(max, scaledSize);
    return scaledSize;
  }

  // Font size with scaling and optional constraints
  static double fontSize(double size, {double? min, double? max}) {
    if (_textScaleFactor == null) return size;
    double scaledSize = scale(size) * _textScaleFactor!;
    return scaleWithConstraints(scaledSize, min: min, max: max);
  }

  // Padding and Margin
  static EdgeInsets all(double value) => EdgeInsets.all(scale(value));

  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal),
      vertical: scaleHeight(vertical),
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
      top: scaleHeight(top),
      right: scale(right),
      bottom: scaleHeight(bottom),
    );
  }

  // Width and Height
  static double width(double size) => scale(size);
  static double height(double size) => scaleHeight(size);

  // Radius
  static BorderRadius circular(double radius) => BorderRadius.circular(scale(radius));

  // Box constraints
  static BoxConstraints constraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth != null ? scale(minWidth) : 0,
      maxWidth: maxWidth != null ? scale(maxWidth) : double.infinity,
      minHeight: minHeight != null ? scaleHeight(minHeight) : 0,
      maxHeight: maxHeight != null ? scaleHeight(maxHeight) : double.infinity,
    );
  }

  // Pixel-perfect scaling
  static double dp(double size) => size * (_pixelRatio ?? 1.0);
}