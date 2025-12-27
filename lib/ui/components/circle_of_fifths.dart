import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(circleProvider);
    final isDark = AppTheme.isDark(context);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ambient glow effect behind the circle
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: constraints.maxWidth * 0.85,
                    height: constraints.maxWidth * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.tonicBlue.withOpacity(
                            0.15 + 0.1 * math.sin(_glowController.value * 2 * math.pi),
                          ),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Main circle
              GestureDetector(
                onTapUp: (details) => _handleTap(context, details, constraints.maxWidth),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxWidth),
                  painter: DualCirclePainter(
                    selectedMajor: state.selectedMajorRoot,
                    view: state.view,
                    isDark: isDark,
                    glowProgress: _glowController.value,
                  ),
                ),
              ),
              // Center decoration
              Container(
                width: constraints.maxWidth * 0.32,
                height: constraints.maxWidth * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  void _handleTap(BuildContext context, TapUpDetails details, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    final ang = (math.atan2(dy, dx) + 2.5 * math.pi) % (2 * math.pi);
    final step = 2 * math.pi / 12;
    int idx = (ang / step).round() % 12;
    final key = TheoryEngine.kCircleMajClock[idx];

    final dividerRadius = size * 0.32;
    final innerRadius = size * 0.18;

    if (dist > dividerRadius) {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(circleProvider.notifier);
      notifier.selectKey(key);
      notifier.setView(KeyView.major);
    } else if (dist > innerRadius) {
      HapticFeedback.mediumImpact();
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
  final double glowProgress;

  DualCirclePainter({
    required this.selectedMajor,
    required this.view,
    this.isDark = false,
    this.glowProgress = 0.0,
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

    // Theme-aware background colors with gradients
    final majBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final minBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final separatorColor =
        isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.12);

    // Selection highlight colors (theme-aware)
    final majorLightColor = isDark ? AppTheme.darkMajorLight : AppTheme.majorLight;
    final minorLightColor = isDark ? AppTheme.darkMinorLight : AppTheme.minorLight;

    // Text colors for unselected items
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    // 1. Background Rings with subtle gradient
    final majBgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          majBgColor,
          majBgColor.withOpacity(isDark ? 0.8 : 0.95),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: rOuter))
      ..style = PaintingStyle.stroke
      ..strokeWidth = rOuter - rDivider;
    canvas.drawCircle(center, (rOuter + rDivider) / 2, majBgPaint);

    final minBgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          minBgColor,
          minBgColor.withOpacity(isDark ? 0.7 : 0.9),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: rDivider))
      ..style = PaintingStyle.stroke
      ..strokeWidth = rDivider - rInner;
    canvas.drawCircle(center, (rDivider + rInner) / 2, minBgPaint);

    // Outer ring border with subtle glow
    final outerBorderPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, rOuter, outerBorderPaint);

    // Inner ring border
    canvas.drawCircle(center, rInner, outerBorderPaint);

    // Divider ring
    final dividerPaint = Paint()
      ..color = separatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, rDivider, dividerPaint);

    // 2. Separator Lines (radial)
    final sepPaint = Paint()
      ..color = separatorColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n; i++) {
      final angle = base + i * step - (step / 2);
      canvas.drawLine(
        Offset(center.dx + rInner * math.cos(angle),
            center.dy + rInner * math.sin(angle)),
        Offset(center.dx + rOuter * math.cos(angle),
            center.dy + rOuter * math.sin(angle)),
        sepPaint,
      );
    }

    // 3. Active Selection & Text
    final selIndex = TheoryEngine.kCircleMajClock.indexOf(selectedMajor);
    final tp = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final angle = base + i * step;
      final isPairActive = i == selIndex;

      // Draw Highlights with gradient fills
      if (isPairActive) {
        final startAng = angle - step / 2;
        final bool isMajorPrimary = (view == KeyView.major);

        // Major Segment Fill with gradient
        final majPath = Path()
          ..arcTo(Rect.fromCircle(center: center, radius: rOuter), startAng,
              step, false)
          ..arcTo(Rect.fromCircle(center: center, radius: rDivider),
              startAng + step, -step, false)
          ..close();

        if (isMajorPrimary) {
          final majGradient = RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              majorLightColor,
              majorLightColor.withOpacity(0.7),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: rOuter));
          canvas.drawPath(
              majPath,
              Paint()
                ..style = PaintingStyle.fill
                ..shader = majGradient);

          // Add subtle glow around selected segment
          canvas.drawPath(
              majPath,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = AppTheme.tonicBlue.withOpacity(0.4));
        }

        // Minor Segment Fill with gradient
        final minPath = Path()
          ..arcTo(Rect.fromCircle(center: center, radius: rDivider), startAng,
              step, false)
          ..arcTo(Rect.fromCircle(center: center, radius: rInner),
              startAng + step, -step, false)
          ..close();

        if (!isMajorPrimary) {
          final minGradient = RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              minorLightColor,
              minorLightColor.withOpacity(0.7),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: rDivider));
          canvas.drawPath(
              minPath,
              Paint()
                ..style = PaintingStyle.fill
                ..shader = minGradient);

          // Add subtle glow around selected segment
          canvas.drawPath(
              minPath,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = AppTheme.minorAmber.withOpacity(0.4));
        }
      }

      // Draw Text with shadow for depth
      final rMajText = (rOuter + rDivider) / 2;
      final rMinText = (rDivider + rInner) / 2;

      Color majTextColor = isPairActive
          ? (view == KeyView.major
              ? AppTheme.tonicBlue
              : AppTheme.tonicBlue.withOpacity(0.6))
          : textPrimary;

      Color minTextColor = isPairActive
          ? (view == KeyView.relativeMinor
              ? AppTheme.minorAmber
              : AppTheme.minorAmber.withOpacity(0.7))
          : textSecondary;

      // Major Text with enhanced styling
      final xMaj = center.dx + rMajText * math.cos(angle);
      final yMaj = center.dy + rMajText * math.sin(angle);

      // Draw text shadow for selected items
      if (isPairActive && view == KeyView.major) {
        tp.text = TextSpan(
          text: TheoryEngine.kCircleMajClock[i],
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.tonicBlue.withOpacity(0.3),
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(xMaj - tp.width / 2 + 1, yMaj - tp.height / 2 + 1));
      }

      tp.text = TextSpan(
        text: TheoryEngine.kCircleMajClock[i],
        style: TextStyle(
          fontSize: isPairActive && view == KeyView.major ? 17 : 16,
          fontWeight: isPairActive ? FontWeight.w800 : FontWeight.w600,
          color: majTextColor,
          letterSpacing: isPairActive ? 0.5 : 0,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(xMaj - tp.width / 2, yMaj - tp.height / 2));

      // Minor Text with enhanced styling
      final xMin = center.dx + rMinText * math.cos(angle);
      final yMin = center.dy + rMinText * math.sin(angle);
      final minNote = TheoryEngine.kRelativeMinors[TheoryEngine.kCircleMajClock[i]] ?? '';

      tp.text = TextSpan(
        text: '${minNote}m',
        style: TextStyle(
          fontSize: isPairActive && view == KeyView.relativeMinor ? 13 : 12,
          fontWeight: isPairActive ? FontWeight.w700 : FontWeight.w500,
          color: minTextColor,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(xMin - tp.width / 2, yMin - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant DualCirclePainter old) =>
      old.selectedMajor != selectedMajor ||
      old.view != view ||
      old.isDark != isDark ||
      old.glowProgress != glowProgress;
}
