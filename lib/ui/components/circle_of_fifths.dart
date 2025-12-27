import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers.dart';
import '../../logic/theory_engine.dart';
import '../../core/theme.dart';

class InteractiveCircle extends ConsumerWidget {
  const InteractiveCircle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(circleProvider);
    final isDark = AppTheme.isDark(context);
    final majorTextColor = AppTheme.getMajorTextColor(context);
    final minorTextColor = AppTheme.getMinorTextColor(context);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapUp: (details) => _handleTap(context, ref, details, constraints.maxWidth),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxWidth),
              painter: DualCirclePainter(
                selectedMajor: state.selectedMajorRoot,
                view: state.view,
                isDark: isDark,
                majorTextColor: majorTextColor,
                minorTextColor: minorTextColor,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, TapUpDetails details, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final dist = math.sqrt(dx*dx + dy*dy);
    
    final ang = (math.atan2(dy, dx) + 2.5 * math.pi) % (2 * math.pi);
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
}

class DualCirclePainter extends CustomPainter {
  final String selectedMajor;
  final KeyView view;
  final bool isDark;
  final Color majorTextColor;
  final Color minorTextColor;

  DualCirclePainter({
    required this.selectedMajor,
    required this.view,
    this.isDark = false,
    required this.majorTextColor,
    required this.minorTextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final n = TheoryEngine.kCircleMajClock.length;
    final step = 2 * math.pi / n;
    final base = -math.pi / 2;

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
          ? (view == KeyView.major ? majorTextColor : majorTextColor.withOpacity(0.6))
          : textPrimary;

      Color minTextColor = isPairActive
          ? (view == KeyView.relativeMinor ? minorTextColor : minorTextColor.withOpacity(0.7))
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
      old.isDark != isDark;
}
