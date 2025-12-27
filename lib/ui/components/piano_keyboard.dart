import 'package:flutter/material.dart';
import '../../core/note_utils.dart';
import '../../core/theme.dart';

/// Premium scrollable piano keyboard with realistic 3D appearance.
/// Features elegant ivory and ebony keys with proper lighting and depth.
///
/// Highlights:
/// - root notes (filled colored circle with glow)
/// - other tones (elegant outlined circle with note name)
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
    const whiteKeyWidth = 52.0;
    final keyboardWidth = totalWhiteKeys * whiteKeyWidth;

    // Premium case colors
    final caseColor = isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFF2D2D3A);
    final caseHighlight = isDark
        ? const Color(0xFF252538)
        : const Color(0xFF3D3D4A);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [caseHighlight, caseColor, caseColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.1, 1.0],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Piano brand plate (subtle decorative element)
              Container(
                width: 60,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade700.withOpacity(0.6),
                      Colors.amber.shade300.withOpacity(0.8),
                      Colors.amber.shade700.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Keyboard container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: keyboardWidth,
                      height: 220,
                      child: CustomPaint(
                        painter: _PremiumPianoPainter(
                          tones: tones,
                          root: root,
                          octaves: octaves <= 1 ? 1 : 2,
                          startPc: startPc,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPianoPainter extends CustomPainter {
  final List<String> tones;
  final String root;
  final int octaves;
  final int startPc;
  final bool isDark;

  _PremiumPianoPainter({
    required this.tones,
    required this.root,
    required this.octaves,
    required this.startPc,
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

    final blackW = whiteW * 0.58;
    final blackH = whiteH * 0.62;

    // Draw keyboard base (the surface under the keys)
    _drawKeyboardBase(canvas, size);

    // Draw all white keys first
    for (int i = 0; i < whiteKeyCount; i++) {
      final x = i * whiteW;
      final isFirst = i == 0;
      final isLast = i == whiteKeyCount - 1;
      _drawWhiteKey(canvas, x, whiteW, whiteH, isFirst, isLast);
    }

    // Draw note markers on white keys
    for (int i = 0; i < whiteKeyCount; i++) {
      final x = i * whiteW;
      final pc = _pcForWhiteIndex(i);
      _drawMarkerIfNeeded(canvas, tonesSet, rootPc, pc, Offset(x + whiteW / 2, whiteH * 0.80), false);
    }

    // Draw black keys on top
    for (int oct = 0; oct < octaves; oct++) {
      final baseWhiteIndex = oct * 7;

      // Black key positions: after C, D, F, G, A
      final blackPositions = [0, 1, 3, 4, 5];

      for (final pos in blackPositions) {
        final leftWhite = baseWhiteIndex + pos;
        if (leftWhite >= whiteKeyCount - 1) continue;

        final pc = _pcForBlackAtWhite(leftWhite);

        // Position black key between white keys with slight offset
        final xCenter = (leftWhite + 1) * whiteW;
        final blackX = xCenter - blackW / 2 - whiteW * 0.08;

        _drawBlackKey(canvas, blackX, blackW, blackH);

        // Draw marker on black key
        _drawMarkerIfNeeded(
          canvas,
          tonesSet,
          rootPc,
          pc,
          Offset(xCenter - whiteW * 0.08, blackH * 0.72),
          true,
        );
      }
    }
  }

  void _drawKeyboardBase(Canvas canvas, Size size) {
    // Dark felt/fabric under the keys
    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1A1A1A),
          const Color(0xFF0D0D0D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);
  }

  void _drawWhiteKey(Canvas canvas, double x, double width, double height, bool isFirst, bool isLast) {
    final keyGap = 1.0;
    final keyRect = Rect.fromLTWH(x + keyGap / 2, 0, width - keyGap, height);

    // Key body with rounded bottom
    final RRect keyRRect = RRect.fromRectAndCorners(
      keyRect,
      bottomLeft: Radius.circular(isFirst ? 6 : 4),
      bottomRight: Radius.circular(isLast ? 6 : 4),
    );

    // Main ivory gradient (top to bottom for 3D effect)
    final Paint ivoryGradient = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFFE8E4DC),
                const Color(0xFFF5F2EB),
                const Color(0xFFEAE6DE),
                const Color(0xFFDDD9D0),
              ]
            : [
                const Color(0xFFFFFEFA),
                const Color(0xFFFFFDF8),
                const Color(0xFFF8F5EE),
                const Color(0xFFEDE9E0),
              ],
        stops: const [0.0, 0.15, 0.85, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(keyRect);

    // Drop shadow for key depth
    canvas.drawRRect(
      keyRRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withOpacity(0.15),
    );

    // Main key body
    canvas.drawRRect(keyRRect, ivoryGradient);

    // Side shadow (left edge) for 3D separation
    final Paint leftShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.08),
          Colors.transparent,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x, 0, 4, height));
    canvas.drawRect(Rect.fromLTWH(x + keyGap / 2, 0, 3, height), leftShadow);

    // Top edge highlight (simulates light from above)
    canvas.drawLine(
      Offset(x + keyGap / 2 + 2, 1),
      Offset(x + width - keyGap / 2 - 2, 1),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 1,
    );

    // Subtle key border
    canvas.drawRRect(
      keyRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = const Color(0xFF9E9A92).withOpacity(0.4),
    );

    // Bottom edge (key front face simulation)
    final bottomEdge = Rect.fromLTWH(x + keyGap / 2, height - 4, width - keyGap, 4);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        bottomEdge,
        bottomLeft: Radius.circular(isFirst ? 6 : 4),
        bottomRight: Radius.circular(isLast ? 6 : 4),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFD4D0C8),
            const Color(0xFFC8C4BC),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bottomEdge),
    );
  }

  void _drawBlackKey(Canvas canvas, double x, double width, double height) {
    final keyRect = Rect.fromLTWH(x, 0, width, height);

    // Black key with beveled 3D appearance
    final RRect keyRRect = RRect.fromRectAndCorners(
      keyRect,
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );

    // Shadow underneath
    canvas.drawRRect(
      keyRRect.shift(const Offset(2, 3)),
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    // Main ebony body with gradient
    final Paint ebonyGradient = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF252525),
                const Color(0xFF1A1A1A),
                const Color(0xFF151515),
                const Color(0xFF0D0D0D),
              ]
            : [
                const Color(0xFF2A2A2A),
                const Color(0xFF1F1F1F),
                const Color(0xFF171717),
                const Color(0xFF0F0F0F),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(keyRect);

    canvas.drawRRect(keyRRect, ebonyGradient);

    // Top bevel highlight (simulates light hitting the top edge)
    final topBevel = Rect.fromLTWH(x, 0, width, 3);
    canvas.drawRRect(
      RRect.fromRectAndCorners(topBevel),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topBevel),
    );

    // Left edge highlight
    canvas.drawLine(
      Offset(x + 1, 2),
      Offset(x + 1, height - 4),
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..strokeWidth = 1,
    );

    // Center specular highlight (glossy appearance)
    final centerHighlight = Rect.fromLTWH(x + width * 0.3, 4, width * 0.4, height * 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerHighlight, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(centerHighlight),
    );

    // Bottom rounded edge
    final bottomEdge = Rect.fromLTWH(x, height - 6, width, 6);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        bottomEdge,
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF080808),
    );

    // Subtle border
    canvas.drawRRect(
      keyRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black.withOpacity(0.5),
    );
  }

  int _pcForWhiteIndex(int whiteIndex) {
    final degree = whiteIndex % 7;
    // White keys always map to natural notes: C=0, D=2, E=4, F=5, G=7, A=9, B=11
    return _whitePcs[degree];
  }

  int _pcForBlackAtWhite(int leftWhiteIndex) {
    final degree = leftWhiteIndex % 7;
    // Black keys always map to sharps/flats: C#=1, D#=3, F#=6, G#=8, A#=10
    final map = <int, int>{0: 1, 1: 3, 3: 6, 4: 8, 5: 10};
    return map[degree] ?? 1;
  }

  void _drawMarkerIfNeeded(
    Canvas canvas,
    Set<String> tonesSet,
    int rootPc,
    int pc,
    Offset center,
    bool onBlack,
  ) {
    final matching = NoteUtils.findByPitchClass(tonesSet, pc);
    if (matching == null) return;

    final isRoot = (pc == rootPc);
    final interval = (pc - rootPc + 12) % 12;
    final intervalColor = AppTheme.getIntervalColor(interval);

    final double radius = 12.0;
    final Rect markerRect = Rect.fromCircle(center: center, radius: radius);

    // Drop shadow
    canvas.drawCircle(
      center.translate(0, 1.5),
      radius,
      Paint()..color = Colors.black.withOpacity(0.25),
    );

    if (isRoot) {
      // Root note: filled with glow effect
      canvas.drawCircle(
        center,
        radius + 4,
        Paint()..color = intervalColor.withOpacity(0.35),
      );

      // Gradient fill for root
      final Paint rootFill = Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(intervalColor, Colors.white, 0.3)!,
            intervalColor,
            Color.lerp(intervalColor, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.3, -0.3),
        ).createShader(markerRect);

      canvas.drawCircle(center, radius, rootFill);

      // Inner highlight
      final Paint innerGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.0),
          ],
          center: const Alignment(-0.4, -0.4),
          radius: 0.6,
        ).createShader(markerRect);
      canvas.drawCircle(center, radius * 0.8, innerGlow);

      // White border
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(0.8),
      );
    } else {
      // Non-root: outlined style with interval color
      final Color fillColor = onBlack
          ? const Color(0xFF1A1A1A)
          : (isDark ? const Color(0xFFE8E4DC) : const Color(0xFFFFFDF8));

      canvas.drawCircle(center, radius, Paint()..color = fillColor);

      // Interval colored border (thicker for visibility)
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = intervalColor,
      );

      // Subtle inner shadow
      canvas.drawCircle(
        center,
        radius - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = intervalColor.withOpacity(0.3),
      );
    }

    // Note label
    final Color textColor = isRoot
        ? Colors.white
        : (onBlack
            ? Colors.white
            : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFF2D2D2D)));

    final style = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 10,
      color: textColor,
      shadows: isRoot
          ? [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ]
          : null,
    );

    final tp = TextPainter(
      text: TextSpan(text: matching, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PremiumPianoPainter oldDelegate) {
    return oldDelegate.octaves != octaves ||
        oldDelegate.startPc != startPc ||
        oldDelegate.root != root ||
        oldDelegate.isDark != isDark ||
        oldDelegate.tones.length != tones.length;
  }
}
