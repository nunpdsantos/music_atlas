import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers.dart';
import '../../logic/theory_engine.dart';
import '../../core/theme.dart';

class InteractiveCircle extends ConsumerStatefulWidget {
  const InteractiveCircle({super.key});

  @override
  ConsumerState<InteractiveCircle> createState() => _InteractiveCircleState();
}

class _InteractiveCircleState extends ConsumerState<InteractiveCircle>
    with SingleTickerProviderStateMixin {
  /// Current rotation offset in radians (for drag interaction)
  double _rotationOffset = 0.0;

  /// Animation controller for spring physics
  late AnimationController _springController;

  /// Velocity tracking for fling gestures
  double _lastAngularVelocity = 0.0;

  /// Whether we're currently dragging
  bool _isDragging = false;

  /// Last drag angle for velocity calculation
  double? _lastDragAngle;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(vsync: this);
    _springController.addListener(_onSpringUpdate);
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onSpringUpdate() {
    setState(() {
      _rotationOffset = _springController.value;
    });
  }

  /// Calculate angle from center to a point
  double _angleFromCenter(Offset point, Offset center) {
    return math.atan2(point.dy - center.dy, point.dx - center.dx);
  }

  /// Snap rotation to nearest key position
  void _snapToNearestKey() {
    final step = 2 * math.pi / 12;
    // Find the nearest snap position
    final snappedOffset = ((_rotationOffset / step).round() * step) % (2 * math.pi);

    // Use spring physics to animate to snapped position
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 200.0,
      damping: 20.0,
    );

    final simulation = SpringSimulation(spring, _rotationOffset, snappedOffset, _lastAngularVelocity);

    _springController.animateWith(simulation);
  }

  /// Handle pan start
  void _onPanStart(DragStartDetails details, Offset center) {
    _springController.stop();
    _isDragging = true;
    _lastDragAngle = _angleFromCenter(details.localPosition, center);
  }

  /// Handle pan update
  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    if (!_isDragging) return;

    final currentAngle = _angleFromCenter(details.localPosition, center);
    if (_lastDragAngle != null) {
      var delta = currentAngle - _lastDragAngle!;
      // Handle wrap-around
      if (delta > math.pi) delta -= 2 * math.pi;
      if (delta < -math.pi) delta += 2 * math.pi;

      setState(() {
        _rotationOffset += delta;
        _lastAngularVelocity = delta * 60; // Approximate velocity
      });
    }
    _lastDragAngle = currentAngle;
  }

  /// Handle pan end
  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _lastDragAngle = null;
    _snapToNearestKey();
  }

  void _handleTap(TapUpDetails details, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final dist = math.sqrt(dx*dx + dy*dy);

    // Account for rotation offset when calculating angle
    final ang = (math.atan2(dy, dx) + 2.5 * math.pi - _rotationOffset) % (2 * math.pi);
    final step = 2 * math.pi / 12;
    int idx = (ang / step).round() % 12;
    final key = TheoryEngine.kCircleMajClock[idx];

    // Touch Target Zones
    final dividerRadius = size * 0.32;
    final innerRadius = size * 0.18;

    if (dist > dividerRadius) {
       // Outer Ring -> Major
       HapticFeedback.selectionClick();
       final notifier = ref.read(circleProvider.notifier);
       notifier.selectKey(key);
       notifier.setView(KeyView.major);
    } else if (dist > innerRadius) {
       // Inner Ring -> Minor
       HapticFeedback.selectionClick();
       final notifier = ref.read(circleProvider.notifier);
       notifier.selectKey(key);
       notifier.setView(KeyView.relativeMinor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(circleProvider);
    final isDark = AppTheme.isDark(context);

    // Build semantic label for screen readers
    final isMajor = state.view == KeyView.major;
    final relMinor = TheoryEngine.kRelativeMinors[state.selectedMajorRoot] ?? '';
    final currentKey = isMajor
        ? '${state.selectedMajorRoot} Major'
        : '${relMinor} minor';
    final semanticLabel = 'Circle of Fifths. Currently selected: $currentKey. '
        'Tap outer ring for major keys, inner ring for minor keys. '
        'Drag to rotate the circle.';

    return Semantics(
      label: semanticLabel,
      hint: 'Double tap to select a key, or drag to rotate',
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final center = Offset(constraints.maxWidth / 2, constraints.maxWidth / 2);
            return GestureDetector(
              onTapUp: (details) => _handleTap(details, constraints.maxWidth),
              onPanStart: (details) => _onPanStart(details, center),
              onPanUpdate: (details) => _onPanUpdate(details, center),
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxWidth),
                painter: DualCirclePainter(
                  selectedMajor: state.selectedMajorRoot,
                  view: state.view,
                  isDark: isDark,
                  rotationOffset: _rotationOffset,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DualCirclePainter extends CustomPainter {
  final String selectedMajor;
  final KeyView view;
  final bool isDark;
  final double rotationOffset;

  DualCirclePainter({
    required this.selectedMajor,
    required this.view,
    this.isDark = false,
    this.rotationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final n = TheoryEngine.kCircleMajClock.length;
    final step = 2 * math.pi / n;
    // Apply rotation offset to the base angle
    final base = -math.pi / 2 + rotationOffset;

    // Dimensions
    final rOuter = size.shortestSide * 0.48; 
    final rDivider = size.shortestSide * 0.32;
    final rInner = size.shortestSide * 0.18;
    
    // Theme-aware background colors
    final majBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final minBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final separatorColor = isDark ? Colors.grey.withOpacity(0.25) : Colors.grey.withOpacity(0.15);
    
    // Selection highlight colors (theme-aware)
    final majorLightColor = isDark ? AppTheme.darkMajorLight : AppTheme.majorLight;
    final minorLightColor = isDark ? AppTheme.darkMinorLight : AppTheme.minorLight;
    
    // Text colors for unselected items
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    
    // 1. Background Rings
    final majBgPaint = Paint()
      ..color = majBgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = rOuter - rDivider;
    canvas.drawCircle(center, (rOuter + rDivider) / 2, majBgPaint);

    final minBgPaint = Paint()
      ..color = minBgColor 
      ..style = PaintingStyle.stroke
      ..strokeWidth = rDivider - rInner;
    canvas.drawCircle(center, (rDivider + rInner) / 2, minBgPaint);

    // 2. Separator Lines
    final sepPaint = Paint()
      ..color = separatorColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    for (int i = 0; i < n; i++) {
      final angle = base + i * step - (step / 2);
      canvas.drawLine(
        Offset(center.dx + rInner * math.cos(angle), center.dy + rInner * math.sin(angle)),
        Offset(center.dx + rOuter * math.cos(angle), center.dy + rOuter * math.sin(angle)),
        sepPaint
      );
    }

    // 3. Active Selection & Text
    final selIndex = TheoryEngine.kCircleMajClock.indexOf(selectedMajor);
    final tp = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final angle = base + i * step;
      final isPairActive = i == selIndex;

      // Draw Highlights
      if (isPairActive) {
        final startAng = angle - step/2;
        final bool isMajorPrimary = (view == KeyView.major);
        
        // Use theme-aware highlight colors
        final Color majFill = isMajorPrimary ? majorLightColor : Colors.transparent;
        final Color minFill = !isMajorPrimary ? minorLightColor : Colors.transparent;
        
        // Major Segment Fill
        final majPath = Path()..arcTo(Rect.fromCircle(center: center, radius: rOuter), startAng, step, false)
          ..arcTo(Rect.fromCircle(center: center, radius: rDivider), startAng + step, -step, false)..close();
        canvas.drawPath(majPath, Paint()..style = PaintingStyle.fill..color = majFill);

        // Minor Segment Fill
        final minPath = Path()..arcTo(Rect.fromCircle(center: center, radius: rDivider), startAng, step, false)
          ..arcTo(Rect.fromCircle(center: center, radius: rInner), startAng + step, -step, false)..close();
        canvas.drawPath(minPath, Paint()..style = PaintingStyle.fill..color = minFill);
      }

      // Draw Text
      final rMajText = (rOuter + rDivider) / 2;
      final rMinText = (rDivider + rInner) / 2;
      
      Color majTextColor = isPairActive 
          ? (view == KeyView.major ? AppTheme.tonicBlue : AppTheme.tonicBlue.withOpacity(0.6)) 
          : textPrimary;
      
      Color minTextColor = isPairActive 
          ? (view == KeyView.relativeMinor ? AppTheme.minorAmber : AppTheme.minorAmber.withOpacity(0.7)) 
          : textSecondary;

      // Major Text
      final xMaj = center.dx + rMajText * math.cos(angle);
      final yMaj = center.dy + rMajText * math.sin(angle);
      tp.text = TextSpan(text: TheoryEngine.kCircleMajClock[i], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: majTextColor));
      tp.layout();
      tp.paint(canvas, Offset(xMaj - tp.width/2, yMaj - tp.height/2));

      // Minor Text
      final xMin = center.dx + rMinText * math.cos(angle);
      final yMin = center.dy + rMinText * math.sin(angle);
      final minNote = TheoryEngine.kRelativeMinors[TheoryEngine.kCircleMajClock[i]] ?? '';
      tp.text = TextSpan(text: '${minNote}m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: minTextColor));
      tp.layout();
      tp.paint(canvas, Offset(xMin - tp.width/2, yMin - tp.height/2));
    }
  }

  @override
  bool shouldRepaint(covariant DualCirclePainter old) =>
      old.selectedMajor != selectedMajor ||
      old.view != view ||
      old.isDark != isDark ||
      old.rotationOffset != rotationOffset;
}
