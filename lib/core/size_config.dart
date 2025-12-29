import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class SizeConfig {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _devicePixelRatio = 1;
  static double _textScaleFactor = 1;

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  // The logical width of the Pixel 9 (approx 411-412)
  // We use this as the "standard" to scale against.
  static const double _designWidth = 412.0;

  // Max and min scale factors to prevent extreme scaling
  static const double _maxScaleFactor = 1.15;
  static const double _minScaleFactor = 0.85;

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _devicePixelRatio = mediaQuery.devicePixelRatio;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _initialized = true;
  }

  /// Scale a number relative to the screen width.
  /// Clamped to prevent extreme scaling on different devices.
  static double px(double size) {
    if (_screenWidth == 0) return size;
    final rawScale = _screenWidth / _designWidth;
    final clampedScale = rawScale.clamp(_minScaleFactor, _maxScaleFactor);
    return size * clampedScale;
  }

  /// A shortcut for font sizing with text scale consideration.
  static double font(double size) {
    if (_screenWidth == 0) return size;
    final rawScale = _screenWidth / _designWidth;
    // Be more conservative with font scaling
    final clampedScale = rawScale.clamp(0.9, 1.1);
    // Also limit the system text scale factor impact
    final textScale = _textScaleFactor.clamp(0.8, 1.2);
    return size * clampedScale * (textScale > 1.0 ? math.sqrt(textScale) : textScale);
  }

  /// Get the scale factor (useful for debugging)
  static double get scaleFactor {
    if (_screenWidth == 0) return 1.0;
    return (_screenWidth / _designWidth).clamp(_minScaleFactor, _maxScaleFactor);
  }
}
