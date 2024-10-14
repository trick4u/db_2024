import 'package:flutter/material.dart';

class ScaleUtil {
  static double? _screenWidth;
  static double? _screenHeight;
  static double _baseWidth = 375.0; // Default base width (e.g., iPhone X)
  static double _baseHeight = 812.0; // Default base height (e.g., iPhone X)
  static bool _isTablet = false;
  static Orientation _orientation = Orientation.portrait;

  static void init(BuildContext context, {double? baseWidth, double? baseHeight}) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _orientation = MediaQuery.of(context).orientation;
    _isTablet = _screenWidth! >= 600; // Simple tablet detection
    if (baseWidth != null) _baseWidth = baseWidth;
    if (baseHeight != null) _baseHeight = baseHeight;
  }

  static double scale(double size) {
    if (_screenWidth == null) return size;
    double scaleFactor = _orientation == Orientation.portrait
        ? _screenWidth! / _baseWidth
        : _screenHeight! / _baseWidth;
    return size * scaleFactor;
  }

  // Font size
  static double fontSize(double size) => scale(size);

  // Icon size
  static double iconSize(double size) => scale(size * 1.2); // Slightly larger than font

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

  // SizedBox
  static SizedBox sizedBox({double? width, double? height}) {
    return SizedBox(
      width: width != null ? scale(width) : null,
      height: height != null ? scale(height) : null,
    );
  }

  // Border Radius
  static BorderRadius circular(double radius) => BorderRadius.circular(scale(radius));

  // Constrained scaling
  static double constrain(double size, {double? min, double? max}) {
    double scaledSize = scale(size);
    if (min != null) scaledSize = scaledSize.clamp(min, double.infinity);
    if (max != null) scaledSize = scaledSize.clamp(0, max);
    return scaledSize;
  }

  // Device type specific scaling
  static double deviceAwareScale(double size, {double tabletFactor = 1.5}) {
    return _isTablet ? scale(size * tabletFactor) : scale(size);
  }
  static Radius radius(double radius) {
  return Radius.circular(scale(radius));
}
}