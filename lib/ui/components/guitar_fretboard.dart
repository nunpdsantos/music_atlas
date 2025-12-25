import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/note_utils.dart';

class GuitarFretboard extends StatefulWidget {
  final List<String> tones;
  final String root;
  final int octaves;
  final bool leftHanded; // Headstock Right
  final double height;
  final ScrollController? scrollController;
  
  // Layout constraints passed from parent
  final double fretWidth; 
  final int totalFrets;

  const GuitarFretboard({
    super.key,
    required this.tones,
    required this.root,
    required this.octaves,
    required this.leftHanded,
    this.height = 300,
    this.scrollController,
    required this.fretWidth,
    this.totalFrets = 12,
  });

  @override
  State<GuitarFretboard> createState() => _GuitarFretboardState();
}

class _GuitarFretboardState extends State<GuitarFretboard> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // We add extra width for the "Outside" open strings area
    final double nutPadding = widget.fretWidth * 0.8; 
    final double contentWidth = (widget.totalFrets * widget.fretWidth) + nutPadding;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: contentWidth,
        height: widget.height,
        child: CustomPaint(
          painter: GuitarFretboardPainter(
            tones: widget.tones,
            root: widget.root,
            leftHanded: widget.leftHanded,
            fretWidth: widget.fretWidth,
            totalFrets: widget.totalFrets,
            nutPadding: nutPadding,
          ),
        ),
      ),
    );
  }
}

class GuitarFretboardPainter extends CustomPainter {
  final List<String> tones;
  final String root;
  final bool leftHanded;
  final double fretWidth;
  final int totalFrets;
  final double nutPadding;

  // Colors
  final Color woodColor = const Color(0xFF5D4037);
  final Color fretColor = const Color(0xFFBCAAA4);
  final Color stringColor = const Color(0xFF9E9E9E); 

  GuitarFretboardPainter({
    required this.tones,
    required this.root,
    required this.leftHanded,
    required this.fretWidth,
    required this.totalFrets,
    required this.nutPadding,
  });

  static const List<int> _openStringMidi = [40, 45, 50, 55, 59, 64]; // E A D G B E

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;

    // Define the "Board" area (excluding the open string zone)
    // If LeftHanded (Headstock Right): Board is from 0 to (Width - nutPadding)
    final double boardStart = leftHanded ? 0.0 : nutPadding;
    final double boardEnd = leftHanded ? size.width - nutPadding : size.width;

    // 1. Draw Wood Background with Enhanced Gradient and Depth
    final Rect boardRect = Rect.fromLTRB(boardStart, 0, boardEnd, h);

    // Multi-layer wood effect for depth
    final Paint woodBasePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF2C1810),  // Darker brown
          const Color(0xFF3E2723),
          const Color(0xFF5D4037),
          const Color(0xFF4E342E),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(boardRect);

    canvas.drawRect(boardRect, woodBasePaint);

    // Add subtle wood grain texture effect
    final Paint grainPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 40; i++) {
      final double xPos = boardStart + (boardEnd - boardStart) * (i / 40);
      canvas.drawLine(
        Offset(xPos, 0),
        Offset(xPos, h),
        grainPaint..color = Colors.black.withOpacity(0.03 + (i % 3) * 0.02)
      );
    }

    final double paddingY = 24.0;
    final double availableHeight = h - (paddingY * 2);
    final double stringSpacing = availableHeight / 5;

    // Enhanced fret paint with metallic effect
    final Paint fretPaint = Paint()
      ..color = fretColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Paint fretShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Enhanced nut with gradient
    final Paint nutPaint = Paint()..strokeWidth = 8.0..strokeCap = StrokeCap.round;

    final Paint markerPaint = Paint()..color = Colors.white.withOpacity(0.85);
    final Paint markerShadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
    const markerFrets = [3, 5, 7, 9, 12];

    // 2. Draw Frets with Enhanced 3D Effect
    for (int i = 0; i <= totalFrets; i++) {
      double x;
      if (leftHanded) {
        // Headstock Right: Fret 0 (Nut) is at boardEnd
        x = boardEnd - (i * fretWidth);
      } else {
        // Headstock Left: Fret 0 (Nut) is at boardStart
        x = boardStart + (i * fretWidth);
      }

      if (i == 0) {
        // Draw nut with gradient effect
        final nutRect = Rect.fromLTRB(x - 4, paddingY, x + 4, h - paddingY);
        nutPaint.shader = LinearGradient(
          colors: [
            const Color(0xFFF5F5F5),
            const Color(0xFFFFFFFF),
            const Color(0xFFF0F0F0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(nutRect);

        canvas.drawLine(Offset(x, paddingY), Offset(x, h - paddingY), nutPaint);
      } else {
        // Draw fret shadow first for depth
        canvas.drawLine(
          Offset(x + 1, paddingY),
          Offset(x + 1, h - paddingY),
          fretShadowPaint
        );
        // Draw fret with metallic gradient
        final fretRect = Rect.fromLTRB(x - 1.5, paddingY, x + 1.5, h - paddingY);
        fretPaint.shader = LinearGradient(
          colors: [
            const Color(0xFFBCAAA4),
            const Color(0xFFD7CCC8),
            const Color(0xFFBCAAA4),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(fretRect);

        canvas.drawLine(Offset(x, paddingY), Offset(x, h - paddingY), fretPaint);
      }

      // Draw Enhanced Markers (Mother of Pearl Effect)
      if (i > 0 && markerFrets.contains(i)) {
        double markerX = leftHanded
            ? x + (fretWidth / 2)
            : x - (fretWidth / 2);

        double centerY = h / 2;
        if (i == 12) {
          // Double dots for 12th fret
          _drawPearlMarker(canvas, Offset(markerX, centerY - 18), markerPaint, markerShadowPaint);
          _drawPearlMarker(canvas, Offset(markerX, centerY + 18), markerPaint, markerShadowPaint);
        } else {
          _drawPearlMarker(canvas, Offset(markerX, centerY), markerPaint, markerShadowPaint);
        }
      }
    }

    // 3. Draw Strings with Enhanced Depth and Shadows
    final Paint stringPaint = Paint()..strokeCap = StrokeCap.round;
    final Paint stringShadowPaint = Paint()..strokeCap = StrokeCap.round;

    for (int s = 0; s < 6; s++) {
      double y = paddingY + (s * stringSpacing);
      final thickness = 1.2 + (5 - s) * 0.5;

      // Draw string shadow
      stringShadowPaint.strokeWidth = thickness;
      stringShadowPaint.color = Colors.black.withOpacity(0.25);
      canvas.drawLine(Offset(0, y + 1), Offset(size.width, y + 1), stringShadowPaint);

      // Draw string with gradient for metallic effect
      stringPaint.strokeWidth = thickness;
      stringPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF757575),
          const Color(0xFFBDBDBD),
          const Color(0xFF9E9E9E),
          const Color(0xFF757575),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - thickness/2, size.width, thickness));

      canvas.drawLine(Offset(0, y), Offset(size.width, y), stringPaint);
    }

    // 4. Draw Notes
    int rootPc = NoteUtils.pitchClass(root);

    for (int s = 0; s < 6; s++) {
      double y = paddingY + (s * stringSpacing);
      int stringOpenMidi = _openStringMidi[s];

      for (int i = 0; i <= totalFrets; i++) {
        int midi = stringOpenMidi + i;
        int pc = midi % 12;

        String? noteName = _findNoteName(pc);
        if (noteName != null) {
          // Calculate Center X
          double xCenter;
          if (leftHanded) {
             double nutX = boardEnd;
             if (i == 0) {
               // OPEN STRING: Draw OUTSIDE the board (to the right)
               xCenter = nutX + (nutPadding / 2); 
             } else {
               // STOPPED NOTE: Inside fret
               xCenter = nutX - (i * fretWidth) + (fretWidth / 2);
             }
          } else {
             double nutX = boardStart;
             if (i == 0) {
               xCenter = nutX - (nutPadding / 2);
             } else {
               xCenter = nutX + (i * fretWidth) - (fretWidth / 2);
             }
          }
          
          _drawNote(canvas, Offset(xCenter, y), noteName, pc, rootPc, i==0);
        }
      }
    }
  }

  String? _findNoteName(int pc) {
    for (String t in tones) {
      if (NoteUtils.pitchClass(t) == pc) return t;
    }
    return null;
  }

  // Helper method to draw mother-of-pearl style fret markers
  void _drawPearlMarker(Canvas canvas, Offset center, Paint markerPaint, Paint shadowPaint) {
    const double radius = 7.0;

    // Draw shadow for depth
    canvas.drawCircle(center.translate(0.5, 1), radius, shadowPaint);

    // Draw base marker with gradient
    final markerRect = Rect.fromCircle(center: center, radius: radius);
    final pearlGradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.95),
        Colors.white.withOpacity(0.85),
        Colors.white.withOpacity(0.75),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = pearlGradient.createShader(markerRect)
    );

    // Add subtle highlight for realistic pearl effect
    canvas.drawCircle(
      center.translate(-1.5, -1.5),
      2.5,
      Paint()..color = Colors.white.withOpacity(0.4)
    );
  }

  void _drawNote(Canvas canvas, Offset center, String label, int pc, int rootPc, bool isOpen) {
    int interval = (pc - rootPc + 12) % 12;

    // Use centralized theme colors
    final color = AppTheme.getIntervalColor(interval);
    final isRoot = interval == 0;

    double r = 15.0;

    // Draw outer glow for emphasis
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, r + 3, glowPaint);

    // Draw shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(0, 2), r, shadowPaint);

    // Draw note circle with gradient for 3D effect
    final noteRect = Rect.fromCircle(center: center, radius: r);
    final notePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.95),
          color,
          color.withOpacity(0.85),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(noteRect);

    canvas.drawCircle(center, r, notePaint);

    // Add highlight for 3D effect
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(isRoot ? 0.3 : 0.2),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center.translate(-3, -3), radius: r * 0.5));

    canvas.drawCircle(center.translate(-3, -3), r * 0.5, highlightPaint);

    // Draw stroke
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
    );

    // Draw inner stroke for extra definition
    canvas.drawCircle(
      center,
      r - 1,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
    );

    // Draw label with shadow for clarity
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant GuitarFretboardPainter oldDelegate) {
    if (oldDelegate.root != root) return true;
    if (oldDelegate.leftHanded != leftHanded) return true;
    if (oldDelegate.totalFrets != totalFrets) return true;
    if (oldDelegate.fretWidth != fretWidth) return true;
    if (oldDelegate.tones.length != tones.length) return true;
    
    // Deep compare tones list
    for (int i = 0; i < tones.length; i++) {
      if (oldDelegate.tones[i] != tones[i]) return true;
    }
    
    return false;
  }
}
