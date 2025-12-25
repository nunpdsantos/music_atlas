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
    final blackBorderOpacity = isDark ? 0.3 : 0.12;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(r, Paint()..color = whiteKeyColor.withOpacity(0.9));

    // Draw white keys
    final whitePaint = Paint()..color = whiteKeyColor;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF1B1F2A).withOpacity(borderOpacity);

    for (int i = 0; i < whiteKeyCount; i++) {
      final x = i * whiteW;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, whiteW, whiteH),
        Radius.circular(i == 0 || i == whiteKeyCount - 1 ? 16 : 6),
      );
      canvas.drawRRect(rect, whitePaint);
      canvas.drawRRect(rect, borderPaint);

      final pc = _pcForWhiteIndex(i);
      _drawMarkerIfNeeded(canvas, tonesSet, rootPc, pc, Offset(x + whiteW / 2, whiteH * 0.78));
    }

    // Draw black keys (on top)
    final blackPaint = Paint()..color = blackKeyColor;
    final blackBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? Colors.grey[600]! : Colors.white).withOpacity(blackBorderOpacity);

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
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(xCenter - blackW / 2, 0, blackW, blackH),
          const Radius.circular(10),
        );
        canvas.drawRRect(rect, blackPaint);
        canvas.drawRRect(rect, blackBorder);

        _drawMarkerIfNeeded(canvas, tonesSet, rootPc, pc, Offset(xCenter, blackH * 0.70), onBlack: true);
      }
    }

    // subtle outer stroke
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF1B1F2A).withOpacity(isDark ? 0.2 : 0.08),
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

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF2D63FF).withOpacity(onBlack ? 0.85 : 0.72);

    // Adjust fill color based on dark mode
    final Color fillColor;
    if (isRoot) {
      fillColor = const Color(0xFF2D63FF);
    } else if (onBlack) {
      fillColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1B1F2A);
    } else {
      fillColor = isDark ? const Color(0xFFE2E8F0) : Colors.white;
    }

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final shadow = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.07);

    canvas.drawCircle(center.translate(0, 2), 13, shadow);
    canvas.drawCircle(center, 13, fill);
    canvas.drawCircle(center, 13, ring);

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
      fontWeight: FontWeight.w800,
      color: textColor,
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
