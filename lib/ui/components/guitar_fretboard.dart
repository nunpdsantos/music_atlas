import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../core/note_utils.dart';

/// Callback for when a fretboard note is tapped.
/// Provides the note name, pitch class, string number (0-5), and fret number.
typedef OnNoteTap = void Function(String noteName, int pitchClass, int string, int fret);

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

  /// Optional callback when a note is tapped. If null, notes are not interactive.
  final OnNoteTap? onNoteTap;

  /// Whether to provide haptic feedback on note tap
  final bool enableHaptics;

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
    this.onNoteTap,
    this.enableHaptics = true,
  });

  @override
  State<GuitarFretboard> createState() => _GuitarFretboardState();
}

class _GuitarFretboardState extends State<GuitarFretboard> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  // Standard guitar tuning MIDI notes: E2, A2, D3, G3, B3, E4
  static const List<int> _openStringMidi = [40, 45, 50, 55, 59, 64];

  /// Currently vibrating string index (-1 for none, 0-5 for strings)
  int _vibratingString = -1;

  /// Animation controller for string vibration
  late AnimationController _vibrationController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _vibrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _vibrationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _vibratingString = -1);
      }
    });
  }

  @override
  void dispose() {
    _vibrationController.dispose();
    super.dispose();
  }

  /// Trigger string vibration animation
  void _triggerVibration(int stringIndex) {
    setState(() => _vibratingString = stringIndex);
    _vibrationController.forward(from: 0);
  }

  /// Handle tap on the fretboard and determine which note was pressed.
  void _handleTap(Offset position, double contentWidth, double nutPadding) {
    final paddingY = 28.0;
    final availableHeight = widget.height - (paddingY * 2);
    final stringSpacing = availableHeight / 5;

    // Determine which string was tapped (0-5, top to bottom)
    final stringIndex = ((position.dy - paddingY) / stringSpacing).round().clamp(0, 5);

    // Determine which fret was tapped
    final boardStart = widget.leftHanded ? 0.0 : nutPadding;
    final boardEnd = widget.leftHanded ? contentWidth - nutPadding : contentWidth;

    int fret;
    if (widget.leftHanded) {
      // Left-handed: nut on right, frets go left
      if (position.dx > boardEnd) {
        fret = 0; // Open string
      } else {
        fret = ((boardEnd - position.dx) / widget.fretWidth).ceil().clamp(1, widget.totalFrets);
      }
    } else {
      // Right-handed: nut on left, frets go right
      if (position.dx < boardStart) {
        fret = 0; // Open string
      } else {
        fret = ((position.dx - boardStart) / widget.fretWidth).ceil().clamp(1, widget.totalFrets);
      }
    }

    // Calculate the MIDI note and pitch class
    final midi = _openStringMidi[stringIndex] + fret;
    final pitchClass = midi % 12;
    final noteName = NoteUtils.pitchClassToNote(pitchClass);

    // Only trigger for notes that are in the displayed tones
    final isNoteDisplayed = widget.tones.any((t) => NoteUtils.pitchClass(t) == pitchClass);
    if (isNoteDisplayed && widget.onNoteTap != null) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      // Trigger string vibration animation
      _triggerVibration(stringIndex);
      widget.onNoteTap?.call(noteName, pitchClass, stringIndex, fret);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We add extra width for the "Outside" open strings area
    final double nutPadding = widget.fretWidth * 0.8;
    final double contentWidth = (widget.totalFrets * widget.fretWidth) + nutPadding;
    final isDark = AppTheme.isDark(context);

    // Build semantic description for accessibility
    final notesDescription = widget.tones.isNotEmpty
        ? 'Notes displayed: ${widget.tones.join(", ")}'
        : 'No notes displayed';
    final semanticLabel = 'Guitar fretboard visualization. '
        'Root: ${widget.root}. $notesDescription. '
        'Swipe horizontally to navigate frets.';

    return Semantics(
      label: semanticLabel,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: GestureDetector(
          onTapDown: widget.onNoteTap != null
              ? (details) => _handleTap(details.localPosition, contentWidth, nutPadding)
              : null,
          child: AnimatedBuilder(
            animation: _vibrationController,
            builder: (context, child) {
              return SizedBox(
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
                    isDark: isDark,
                    vibratingString: _vibratingString,
                    vibrationAmount: _vibrationController.value,
                  ),
                ),
              );
            },
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
  final bool isDark;
  final int vibratingString;
  final double vibrationAmount;

  GuitarFretboardPainter({
    required this.tones,
    required this.root,
    required this.leftHanded,
    required this.fretWidth,
    required this.totalFrets,
    required this.nutPadding,
    required this.isDark,
    this.vibratingString = -1,
    this.vibrationAmount = 0.0,
  });

  static const List<int> _openStringMidi = [40, 45, 50, 55, 59, 64]; // E A D G B E

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;

    // Define the "Board" area (excluding the open string zone)
    final double boardStart = leftHanded ? 0.0 : nutPadding;
    final double boardEnd = leftHanded ? size.width - nutPadding : size.width;

    final double paddingY = 28.0;
    final double availableHeight = h - (paddingY * 2);
    final double stringSpacing = availableHeight / 5;

    // ================================================
    // 1. PREMIUM ROSEWOOD FRETBOARD BACKGROUND
    // ================================================
    _drawFretboardBackground(canvas, size, boardStart, boardEnd, h, paddingY);

    // ================================================
    // 2. FRET MARKERS (Mother of Pearl Inlays)
    // ================================================
    _drawFretMarkers(canvas, boardStart, boardEnd, h, paddingY);

    // ================================================
    // 3. FRETS (Metallic with 3D Effect)
    // ================================================
    _drawFrets(canvas, boardStart, boardEnd, h, paddingY);

    // ================================================
    // 4. NUT (Bone/Ivory)
    // ================================================
    _drawNut(canvas, boardStart, boardEnd, h, paddingY);

    // ================================================
    // 5. STRINGS (Realistic Metallic)
    // ================================================
    _drawStrings(canvas, size, paddingY, stringSpacing);

    // ================================================
    // 6. NOTES (Premium Styled)
    // ================================================
    _drawNotes(canvas, boardStart, boardEnd, paddingY, stringSpacing);
  }

  void _drawFretboardBackground(Canvas canvas, Size size, double boardStart, double boardEnd, double h, double paddingY) {
    final Rect boardRect = Rect.fromLTRB(boardStart, 0, boardEnd, h);

    // Rich rosewood gradient
    final Paint woodBasePaint = Paint()
      ..shader = LinearGradient(
        colors: isDark
          ? [const Color(0xFF2D1810), const Color(0xFF4A2C20), const Color(0xFF3D2218)]
          : [const Color(0xFF3E1F14), const Color(0xFF5D3423), const Color(0xFF4A2819)],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(boardRect);

    // Draw base wood with rounded corners for premium feel
    final RRect boardRRect = RRect.fromRectAndCorners(
      boardRect,
      topLeft: const Radius.circular(4),
      bottomLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    canvas.drawRRect(boardRRect, woodBasePaint);

    // Add subtle wood grain texture effect
    final Paint grainPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 30; i++) {
      double y = paddingY + (i * (h - paddingY * 2) / 30);
      double waviness = math.sin(i * 0.5) * 2;
      canvas.drawLine(
        Offset(boardStart + waviness, y),
        Offset(boardEnd - waviness, y),
        grainPaint,
      );
    }

    // Subtle inner shadow for depth
    final Paint innerShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.15),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: const Alignment(0, 0.1),
      ).createShader(boardRect);
    canvas.drawRRect(boardRRect, innerShadow);

    // Outer subtle glow/border
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.1);
    canvas.drawRRect(boardRRect, borderPaint);
  }

  void _drawFretMarkers(Canvas canvas, double boardStart, double boardEnd, double h, double paddingY) {
    const markerFrets = [3, 5, 7, 9, 12];

    for (int fret in markerFrets) {
      if (fret > totalFrets) continue;

      double markerX;
      if (leftHanded) {
        double fretX = boardEnd - (fret * fretWidth);
        markerX = fretX + (fretWidth / 2);
      } else {
        double fretX = boardStart + (fret * fretWidth);
        markerX = fretX - (fretWidth / 2);
      }

      double centerY = h / 2;
      double markerRadius = 6.0;

      if (fret == 12) {
        // Double dot for 12th fret
        _drawPearlInlay(canvas, Offset(markerX, centerY - 18), markerRadius);
        _drawPearlInlay(canvas, Offset(markerX, centerY + 18), markerRadius);
      } else {
        _drawPearlInlay(canvas, Offset(markerX, centerY), markerRadius);
      }
    }
  }

  void _drawPearlInlay(Canvas canvas, Offset center, double radius) {
    // Mother of pearl effect with gradient and shimmer
    final Rect markerRect = Rect.fromCircle(center: center, radius: radius);

    // Base pearl gradient
    final Paint pearlBase = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFAFAFA),
          const Color(0xFFE8E8E8),
          const Color(0xFFD4D4D4),
        ],
        stops: const [0.0, 0.6, 1.0],
        center: const Alignment(-0.3, -0.3),
      ).createShader(markerRect);

    // Subtle shadow underneath
    canvas.drawCircle(
      center.translate(0, 1),
      radius,
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // Main pearl body
    canvas.drawCircle(center, radius, pearlBase);

    // Iridescent shimmer highlight
    final Paint shimmer = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.0),
        ],
        center: const Alignment(-0.5, -0.5),
        radius: 0.6,
      ).createShader(markerRect);
    canvas.drawCircle(center, radius * 0.8, shimmer);

    // Subtle border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black.withOpacity(0.2),
    );
  }

  void _drawFrets(Canvas canvas, double boardStart, double boardEnd, double h, double paddingY) {
    for (int i = 1; i <= totalFrets; i++) {
      double x;
      if (leftHanded) {
        x = boardEnd - (i * fretWidth);
      } else {
        x = boardStart + (i * fretWidth);
      }

      // Fret wire with 3D metallic effect
      final double fretHeight = h - (paddingY * 2) + 8;
      final double fretTop = paddingY - 4;

      // Shadow
      canvas.drawLine(
        Offset(x + 1, fretTop),
        Offset(x + 1, fretTop + fretHeight),
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..strokeWidth = 2.5,
      );

      // Main fret body (nickel silver)
      canvas.drawLine(
        Offset(x, fretTop),
        Offset(x, fretTop + fretHeight),
        Paint()
          ..color = isDark
            ? const Color(0xFFB8B8B8)
            : const Color(0xFFC8C8C8)
          ..strokeWidth = 2.5,
      );

      // Left highlight (3D effect)
      canvas.drawLine(
        Offset(x - 0.8, fretTop),
        Offset(x - 0.8, fretTop + fretHeight),
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..strokeWidth = 0.8,
      );

      // Top crown highlight
      canvas.drawLine(
        Offset(x - 1, fretTop + 1),
        Offset(x + 1, fretTop + 1),
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 1,
      );
    }
  }

  void _drawNut(Canvas canvas, double boardStart, double boardEnd, double h, double paddingY) {
    double nutX = leftHanded ? boardEnd : boardStart;
    final double nutHeight = h - (paddingY * 2) + 10;
    final double nutTop = paddingY - 5;
    final double nutWidth = 8.0;

    // Nut rectangle (bone/ivory appearance)
    final Rect nutRect = leftHanded
      ? Rect.fromLTWH(nutX - 2, nutTop, nutWidth, nutHeight)
      : Rect.fromLTWH(nutX - nutWidth + 2, nutTop, nutWidth, nutHeight);

    final RRect nutRRect = RRect.fromRectAndRadius(nutRect, const Radius.circular(2));

    // Base ivory color with gradient
    final Paint nutBase = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFFEF8),
          const Color(0xFFF5F0E6),
          const Color(0xFFEDE8DC),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(nutRect);

    // Shadow
    canvas.drawRRect(
      nutRRect.shift(const Offset(1, 1)),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // Main nut body
    canvas.drawRRect(nutRRect, nutBase);

    // Subtle side highlight
    canvas.drawRRect(
      nutRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.7),
    );

    // Dark edge for depth
    canvas.drawRRect(
      nutRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black.withOpacity(0.15),
    );
  }

  void _drawStrings(Canvas canvas, Size size, double paddingY, double stringSpacing) {
    for (int s = 0; s < 6; s++) {
      double y = paddingY + (s * stringSpacing);

      // String thickness: bass strings are wound (thicker), treble are plain
      double thickness = 1.2 + (5 - s) * 0.5;
      bool isWound = s < 3; // E, A, D are wound strings
      bool isVibrating = s == vibratingString && vibrationAmount > 0;

      if (isVibrating) {
        // Draw vibrating string with wave effect
        _drawVibratingString(canvas, size, y, thickness, isWound, s);
      } else {
        // Draw normal static string
        _drawStaticString(canvas, size, y, thickness, isWound);
      }
    }
  }

  void _drawStaticString(Canvas canvas, Size size, double y, double thickness, bool isWound) {
    // String shadow
    canvas.drawLine(
      Offset(0, y + 1),
      Offset(size.width, y + 1),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..strokeWidth = thickness,
    );

    if (isWound) {
      // Wound string: darker bronze/nickel color with texture
      final Paint woundPaint = Paint()
        ..color = isDark
          ? const Color(0xFF8B7355)
          : const Color(0xFF9C8468)
        ..strokeWidth = thickness;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), woundPaint);

      // Wound texture pattern (subtle)
      final Paint woundHighlight = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..strokeWidth = thickness * 0.3;
      canvas.drawLine(Offset(0, y - thickness * 0.2), Offset(size.width, y - thickness * 0.2), woundHighlight);
    } else {
      // Plain steel string: bright silver with highlight
      final Paint steelBase = Paint()
        ..color = isDark
          ? const Color(0xFFB0B0B0)
          : const Color(0xFFC4C4C4)
        ..strokeWidth = thickness;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), steelBase);

      // Specular highlight
      final Paint steelHighlight = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = thickness * 0.3;
      canvas.drawLine(Offset(0, y - thickness * 0.25), Offset(size.width, y - thickness * 0.25), steelHighlight);
    }
  }

  void _drawVibratingString(Canvas canvas, Size size, double baseY, double thickness, bool isWound, int stringIndex) {
    // Calculate vibration amplitude that decays over time
    // Using a decay envelope: starts strong, fades out
    final decay = 1.0 - vibrationAmount; // 0 -> 1 as animation progresses
    final decayedAmplitude = 4.0 * math.pow(decay, 0.5) * (1.0 - vibrationAmount);

    // Higher frequency for treble strings, lower for bass
    final frequency = 8.0 + (5 - stringIndex) * 2.0;

    // Create path for vibrating string
    final path = Path();
    final shadowPath = Path();

    // String paint
    final Color stringColor = isWound
        ? (isDark ? const Color(0xFF8B7355) : const Color(0xFF9C8468))
        : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFFC4C4C4));

    // Draw string as a wavy path
    const int segments = 100;
    final segmentWidth = size.width / segments;

    for (int i = 0; i <= segments; i++) {
      final x = i * segmentWidth;
      // Sine wave with decay toward the ends (fixed at nut and bridge)
      final endDecay = math.sin((i / segments) * math.pi); // 0 at ends, 1 in middle
      final phase = vibrationAmount * math.pi * 20; // Fast phase animation
      final waveY = math.sin(x / size.width * math.pi * frequency + phase) * decayedAmplitude * endDecay;

      final y = baseY + waveY;
      final shadowY = baseY + waveY + 1;

      if (i == 0) {
        path.moveTo(x, y);
        shadowPath.moveTo(x, shadowY);
      } else {
        path.lineTo(x, y);
        shadowPath.lineTo(x, shadowY);
      }
    }

    // Draw shadow
    canvas.drawPath(
      shadowPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withOpacity(0.2)
        ..strokeWidth = thickness,
    );

    // Draw main string
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = stringColor
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round,
    );

    // Draw highlight for wound strings
    if (isWound) {
      final highlightPath = Path();
      for (int i = 0; i <= segments; i++) {
        final x = i * segmentWidth;
        final endDecay = math.sin((i / segments) * math.pi);
        final phase = vibrationAmount * math.pi * 20;
        final waveY = math.sin(x / size.width * math.pi * frequency + phase) * decayedAmplitude * endDecay;
        final y = baseY + waveY - thickness * 0.2;

        if (i == 0) {
          highlightPath.moveTo(x, y);
        } else {
          highlightPath.lineTo(x, y);
        }
      }
      canvas.drawPath(
        highlightPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withOpacity(0.15)
          ..strokeWidth = thickness * 0.3,
      );
    } else {
      // Specular highlight for steel strings
      final highlightPath = Path();
      for (int i = 0; i <= segments; i++) {
        final x = i * segmentWidth;
        final endDecay = math.sin((i / segments) * math.pi);
        final phase = vibrationAmount * math.pi * 20;
        final waveY = math.sin(x / size.width * math.pi * frequency + phase) * decayedAmplitude * endDecay;
        final y = baseY + waveY - thickness * 0.25;

        if (i == 0) {
          highlightPath.moveTo(x, y);
        } else {
          highlightPath.lineTo(x, y);
        }
      }
      canvas.drawPath(
        highlightPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = thickness * 0.3,
      );
    }
  }

  void _drawNotes(Canvas canvas, double boardStart, double boardEnd, double paddingY, double stringSpacing) {
    int rootPc = NoteUtils.pitchClass(root);

    for (int s = 0; s < 6; s++) {
      double y = paddingY + (s * stringSpacing);
      int stringOpenMidi = _openStringMidi[s];

      for (int i = 0; i <= totalFrets; i++) {
        int midi = stringOpenMidi + i;
        int pc = midi % 12;

        String? noteName = _findNoteName(pc);
        if (noteName != null) {
          double xCenter;
          if (leftHanded) {
            double nutX = boardEnd;
            if (i == 0) {
              xCenter = nutX + (nutPadding / 2);
            } else {
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

          _drawPremiumNote(canvas, Offset(xCenter, y), noteName, pc, rootPc, i == 0);
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

  void _drawPremiumNote(Canvas canvas, Offset center, String label, int pc, int rootPc, bool isOpen) {
    int interval = (pc - rootPc + 12) % 12;
    final color = AppTheme.getIntervalColor(interval);
    final bool isRoot = interval == 0;

    double radius = 14.0;
    final Rect noteRect = Rect.fromCircle(center: center, radius: radius);

    // Drop shadow
    canvas.drawCircle(
      center.translate(0, 2),
      radius,
      Paint()..color = Colors.black.withOpacity(0.25),
    );

    // Outer glow for root notes
    if (isRoot) {
      canvas.drawCircle(
        center,
        radius + 3,
        Paint()..color = color.withOpacity(0.3),
      );
    }

    // Main circle with gradient
    final Paint noteFill = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(color, Colors.white, 0.25)!,
          color,
          Color.lerp(color, Colors.black, 0.15)!,
        ],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
      ).createShader(noteRect);

    canvas.drawCircle(center, radius, noteFill);

    // Inner highlight (glass effect)
    final Paint innerHighlight = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0),
        ],
        center: const Alignment(-0.4, -0.5),
        radius: 0.6,
      ).createShader(noteRect);
    canvas.drawCircle(center, radius * 0.85, innerHighlight);

    // Border ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withOpacity(0.7),
    );

    // Outer dark edge for depth
    canvas.drawCircle(
      center,
      radius + 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black.withOpacity(0.2),
    );

    // Note label with shadow
    final textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 10,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );

    final tp = TextPainter(
      text: TextSpan(text: label, style: textStyle),
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
    if (oldDelegate.isDark != isDark) return true;
    if (oldDelegate.tones.length != tones.length) return true;
    if (oldDelegate.vibratingString != vibratingString) return true;
    if (oldDelegate.vibrationAmount != vibrationAmount) return true;

    for (int i = 0; i < tones.length; i++) {
      if (oldDelegate.tones[i] != tones[i]) return true;
    }

    return false;
  }
}
