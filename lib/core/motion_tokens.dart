import 'package:flutter/animation.dart';

/// Motion design tokens for consistent animations throughout the app.
///
/// Based on Material Design motion principles:
/// - Quick interactions: 150-200ms
/// - Standard transitions: 200-300ms
/// - Complex animations: 300-500ms
class MotionTokens {
  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  /// Quick micro-interactions (button feedback, toggles)
  static const Duration quick = Duration(milliseconds: 150);

  /// Standard UI transitions
  static const Duration standard = Duration(milliseconds: 250);

  /// Medium complexity animations
  static const Duration medium = Duration(milliseconds: 350);

  /// Complex, emphasized animations
  static const Duration complex = Duration(milliseconds: 500);

  /// Very slow, dramatic animations
  static const Duration slow = Duration(milliseconds: 700);

  // ---------------------------------------------------------------------------
  // Curves - Enter (elements appearing)
  // ---------------------------------------------------------------------------

  /// Standard entrance - smooth deceleration
  static const Curve enterCurve = Curves.easeOutCubic;

  /// Emphasized entrance - slight overshoot for attention
  static const Curve enterEmphasized = Curves.easeOutBack;

  /// Bounce entrance - playful feel
  static const Curve enterBounce = Curves.elasticOut;

  // ---------------------------------------------------------------------------
  // Curves - Exit (elements disappearing)
  // ---------------------------------------------------------------------------

  /// Standard exit - smooth acceleration
  static const Curve exitCurve = Curves.easeInCubic;

  /// Quick exit - fast departure
  static const Curve exitFast = Curves.easeIn;

  // ---------------------------------------------------------------------------
  // Curves - Continuous/Interactive
  // ---------------------------------------------------------------------------

  /// Smooth in-out for continuous motions
  static const Curve smooth = Curves.easeInOut;

  /// Spring-like feel for interactive elements
  static const Curve spring = Curves.easeOutBack;

  // ---------------------------------------------------------------------------
  // Stagger Delays (for list animations)
  // ---------------------------------------------------------------------------

  /// Base delay between staggered items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Calculate delay for item at index in staggered animation
  static Duration staggerDelayForIndex(int index, {int maxItems = 10}) {
    // Cap the delay to avoid overly long animations
    final cappedIndex = index.clamp(0, maxItems);
    return Duration(milliseconds: staggerDelay.inMilliseconds * cappedIndex);
  }

  // ---------------------------------------------------------------------------
  // Common Animation Configurations
  // ---------------------------------------------------------------------------

  /// Fade in animation values
  static const double fadeInStart = 0.0;
  static const double fadeInEnd = 1.0;

  /// Slide up entrance offset (in logical pixels)
  static const double slideUpOffset = 24.0;

  /// Scale entrance values
  static const double scaleStart = 0.95;
  static const double scaleEnd = 1.0;

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Get interval for staggered animation at index
  /// Used with Interval for sequencing in AnimationController
  static Interval getStaggerInterval(
    int index, {
    int totalItems = 7,
    double overlapFactor = 0.4,
  }) {
    final itemDuration = 1.0 / (totalItems * (1 - overlapFactor) + overlapFactor);
    final start = index * itemDuration * (1 - overlapFactor);
    final end = (start + itemDuration).clamp(0.0, 1.0);

    return Interval(start, end, curve: enterCurve);
  }
}

/// Extension to add common animation helpers to Duration
extension DurationExtension on Duration {
  /// Convert duration to seconds for AnimationController
  double get inSecondsDouble => inMilliseconds / 1000.0;
}
