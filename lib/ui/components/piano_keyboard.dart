import 'package:flutter/material.dart';
import '../../core/note_utils.dart';

/// Scrollable piano keyboard for 1 or 2 octaves.
/// Fixes the "too narrow / too long" look by enforcing a sane aspect ratio.
///
/// Highlights:
/// - root notes (filled dot)
/// - other tones (outlined dot)
class PianoKeyboard extends StatelessWidget {
  final List<String> tones;
  final String root;
  final int octaves;
  final bool isDark;

  /// Starting pitch class (0 = C). You can change this if you want the keyboard to start elsewhere.
  final int startPc;

  const PianoKeyboard({
    super.key,
    required this.tones,
    required this.root,
    this.octaves = 1,
    this.startPc = 0,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalWhiteKeys = 7 * (octaves <= 1 ? 1 : 2);
    // Choose proportions closer to real keyboard: width-driven, height not absurd.
    final whiteKeyWidth = 54.0;
    final keyboardWidth = totalWhiteKeys * whiteKeyWidth;

    // Theme-aware container background
    final containerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF6F7FB);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: containerBg,
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: keyboardWidth,
            height: 260, // better proportions than "very tall"
            child: CustomPaint(
              painter: _PianoPainter(
                tones: tones,
                root: root,
                octaves: octaves <= 1 ? 1 : 2,
                startPc: startPc,
                theme: Theme.of(context),
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PianoPainter extends CustomPainter {
  final List<String> tones;
  final String root;
  final int octaves;
  final int startPc;
  final ThemeData theme;
  final bool isDark;

  _PianoPainter({
    required this.tones,
    required this.root,
    required this.octaves,
    required this.startPc,
    required this.theme,
    required this.isDark,
  });

  static const List<int> _whitePcs = <int>[0, 2, 4, 5, 7, 9, 11]; // C D E F G A B
  static const List<int> _blackPcs = <int>[1, 3, 6, 8, 10]; // C# D# F# G# A#

  @override
  void paint(Canvas canvas, Size size) {
    final tonesSet = tones.map(NoteUtils.normalize).toSet();
    final rootPc = NoteUtils.pitchClass(root);

    final whiteKeyCount = 7 * octaves;
    final whiteW = size.width / whiteKeyCount;
    final whiteH = size.height;

    final blackW = whiteW * 0.62;
    final blackH = whiteH * 0.62;

    // Background colors based on theme
    final whiteKeyColor = isDark ? const Color(0xFFE2E8F0) : Colors.white;
    final blackKeyColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1B1F2A);
    final borderOpacity = isDark ? 0.3 : 0.14;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(r, Paint()..color = whiteKeyColor.withOpacity(0.9));

    // Draw white keys with enhanced 3D effect
    for (int i = 0; i < whiteKeyCount; i++) {
      final x = i * whiteW;
      final keyRect = Rect.fromLTWH(x, 0, whiteW, whiteH);
      final rect = RRect.fromRectAndRadius(
        keyRect,
        Radius.circular(i == 0 || i == whiteKeyCount - 1 ? 16 : 6),
      );

      // Draw key shadow for depth
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, 2, whiteW - 1, whiteH - 2),
        Radius.circular(i == 0 || i == whiteKeyCount - 1 ? 16 : 6),
      );
      canvas.drawRRect(
        shadowRect,
        Paint()..color = Colors.black.withOpacity(0.05)
      );

      // Draw key with subtle gradient for 3D effect
      final whitePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            whiteKeyColor,
            whiteKeyColor.withOpacity(0.98),
            whiteKeyColor.withOpacity(0.95),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(keyRect);

      canvas.drawRRect(rect, whitePaint);

      // Add subtle highlight at top for realism
      final highlightRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2, 4, whiteW - 4, whiteH * 0.1),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        highlightRect,
        Paint()..color = Colors.white.withOpacity(isDark ? 0.15 : 0.3)
      );

      // Draw border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF1B1F2A).withOpacity(borderOpacity);
      canvas.drawRRect(rect, borderPaint);

      final pc = _pcForWhiteIndex(i);
      _drawMarkerIfNeeded(canvas, tonesSet, rootPc, pc, Offset(x + whiteW / 2, whiteH * 0.78));
    }

    // Draw black keys (on top) with enhanced 3D effect
    for (int oct = 0; oct < octaves; oct++) {
      // Pattern positions relative to white keys: between C-D, D-E, F-G, G-A, A-B
      final baseWhiteIndex = oct * 7;

      final positions = <int, int>{
        baseWhiteIndex + 0: 1, // C#
        baseWhiteIndex + 1: 3, // D#
        baseWhiteIndex + 3: 6, // F#
        baseWhiteIndex + 4: 8, // G#
        baseWhiteIndex + 5: 10, // A#
      };

      for (final entry in positions.entries) {
        final leftWhite = entry.key;
        final pc = _pcForBlackAtWhite(leftWhite);

        final xCenter = (leftWhite + 1) * whiteW - whiteW * 0.33;
        final blackKeyRect = Rect.fromLTWH(xCenter - blackW / 2, 0, blackW, blackH);
        final rect = RRect.fromRectAndRadius(
          blackKeyRect,
          const Radius.circular(10),
        );

        // Draw black key shadow for strong 3D effect
        final shadowRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(xCenter - blackW / 2 + 1, 3, blackW, blackH + 4),
          const Radius.circular(10),
        );
        canvas.drawRRect(
          shadowRect,
          Paint()
            ..color = Colors.black.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        );

        // Draw black key with gradient for depth
        final blackPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              blackKeyColor,
              blackKeyColor.withOpacity(0.95),
              Colors.black.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(blackKeyRect);

        canvas.drawRRect(rect, blackPaint);

        // Add highlight on top edge for realism
        final highlightRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(xCenter - blackW / 2 + 3, 4, blackW - 6, 8),
          const Radius.circular(4),
        );
        canvas.drawRRect(
          highlightRect,
          Paint()..color = Colors.white.withOpacity(isDark ? 0.08 : 0.12)
        );

        // Draw border
        final blackBorder = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(isDark ? 0.1 : 0.15);
        canvas.drawRRect(rect, blackBorder);

        _drawMarkerIfNeeded(canvas, tonesSet, rootPc, pc, Offset(xCenter, blackH * 0.70), onBlack: true);
      }
    }

    // Enhanced outer stroke for definition
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF1B1F2A).withOpacity(isDark ? 0.25 : 0.12),
    );
  }

  int _pcForWhiteIndex(int whiteIndex) {
    final oct = (whiteIndex ~/ 7);
    final degree = whiteIndex % 7;
    return (_whitePcs[degree] + (oct * 12) + startPc) % 12;
  }

  int _pcForBlackAtWhite(int leftWhiteIndex) {
    // leftWhiteIndex within full range
    final degree = leftWhiteIndex % 7;
    final oct = (leftWhiteIndex ~/ 7);

    // Map left white degree to black pitch-class:
    // C -> C#(1), D -> D#(3), F -> F#(6), G -> G#(8), A -> A#(10)
    final map = <int, int>{0: 1, 1: 3, 3: 6, 4: 8, 5: 10};
    final pc = map[degree] ?? 1;
    return (pc + (oct * 12) + startPc) % 12;
  }

  void _drawMarkerIfNeeded(
    Canvas canvas,
    Set<String> tonesSet,
    int rootPc,
    int pc,
    Offset center, {
    bool onBlack = false,
  }) {
    // Find if any tone matches this pc
    final matching = NoteUtils.findByPitchClass(tonesSet, pc);
    if (matching == null) return;

    final isRoot = (pc == rootPc);
    const double radius = 14.0;

    // Adjust fill color based on dark mode
    final Color fillColor;
    final Color ringColor;
    if (isRoot) {
      fillColor = const Color(0xFF2D63FF);
      ringColor = const Color(0xFF2D63FF);
    } else if (onBlack) {
      fillColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1B1F2A);
      ringColor = const Color(0xFF2D63FF);
    } else {
      fillColor = isDark ? const Color(0xFFE2E8F0) : Colors.white;
      ringColor = const Color(0xFF2D63FF);
    }

    // Draw outer glow for emphasis
    final glowPaint = Paint()
      ..color = ringColor.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Draw shadow for depth
    final shadow = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(0, 2.5), radius, shadow);

    // Draw fill with gradient for depth
    if (isRoot) {
      final markerRect = Rect.fromCircle(center: center, radius: radius);
      final fill = Paint()
        ..shader = RadialGradient(
          colors: [
            fillColor.withOpacity(0.95),
            fillColor,
            fillColor.withOpacity(0.85),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(markerRect);
      canvas.drawCircle(center, radius, fill);

      // Add highlight for 3D effect
      final highlightPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center.translate(-3, -3), radius: radius * 0.5));
      canvas.drawCircle(center.translate(-3, -3), radius * 0.5, highlightPaint);
    } else {
      // Non-root notes use solid fill
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = fillColor;
      canvas.drawCircle(center, radius, fill);
    }

    // Draw outer ring
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = ringColor.withOpacity(onBlack ? 0.9 : 0.8);
    canvas.drawCircle(center, radius, ring);

    // Draw inner ring for extra definition
    final innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ringColor.withOpacity(0.3);
    canvas.drawCircle(center, radius - 1.5, innerRing);

    // label letter
    final label = matching;

    // Adjust text color based on background
    final Color textColor;
    if (isRoot) {
      textColor = Colors.white;
    } else if (onBlack) {
      textColor = Colors.white;
    } else {
      textColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1B1F2A);
    }

    final style = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w900,
      fontSize: 11,
      color: textColor,
      shadows: isRoot ? [
        Shadow(
          color: Colors.black.withOpacity(0.4),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ] : null,
    );

    final tp = TextPainter(
      text: TextSpan(text: label, style: style ?? const TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PianoPainter oldDelegate) {
    return oldDelegate.octaves != octaves ||
        oldDelegate.startPc != startPc ||
        oldDelegate.root != root ||
        oldDelegate.isDark != isDark ||
        oldDelegate.tones.length != tones.length;
  }
}
