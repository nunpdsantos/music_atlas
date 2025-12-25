import 'package:flutter/widgets.dart';

class SizeConfig {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  
  // The logical width of the Pixel 9 (approx 411-412)
  // We use this as the "standard" to scale against.
  static const double _designWidth = 412.0;

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _initialized = true;
  }

  /// Scale a number relative to the screen width.
  /// Example: px(20) on a small screen might return 17.0
  static double px(double size) {
    if (_screenWidth == 0) return size; // Safety check
    final scaleFactor = _screenWidth / _designWidth;
    return size * scaleFactor;
  }
  
  /// A shortcut for font sizing.
  static double font(double size) {
    return px(size);
  }
}
