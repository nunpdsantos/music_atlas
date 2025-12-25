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
    
    // 1. Draw Wood Background
    final Rect boardRect = Rect.fromLTRB(boardStart, 0, boardEnd, h);
    final Paint woodPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF3E2723), const Color(0xFF5D4037)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(boardRect);

    canvas.drawRect(boardRect, woodPaint);

    final double paddingY = 24.0; 
    final double availableHeight = h - (paddingY * 2);
    final double stringSpacing = availableHeight / 5;

    final Paint fretPaint = Paint()..color = fretColor..strokeWidth = 2.0;
    final Paint nutPaint = Paint()..color = const Color(0xFFF5F5F5)..strokeWidth = 6.0;
    final Paint markerPaint = Paint()..color = Colors.black12;
    const markerFrets = [3, 5, 7, 9, 12];

    // 2. Draw Frets
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
        canvas.drawLine(Offset(x, paddingY), Offset(x, h - paddingY), nutPaint);
      } else {
        canvas.drawLine(Offset(x, paddingY), Offset(x, h - paddingY), fretPaint);
      }

      // Draw Markers
      if (i > 0 && markerFrets.contains(i)) {
        double markerX = leftHanded 
            ? x + (fretWidth / 2) 
            : x - (fretWidth / 2);
            
        double centerY = h / 2;
        if (i == 12) {
          canvas.drawCircle(Offset(markerX, centerY - 15), 5, markerPaint);
          canvas.drawCircle(Offset(markerX, centerY + 15), 5, markerPaint);
        } else {
          canvas.drawCircle(Offset(markerX, centerY), 5, markerPaint);
        }
      }
    }

    // 3. Draw Strings (0 at Top, 5 at Bottom)
    final Paint stringPaint = Paint()..color = stringColor;
    for (int s = 0; s < 6; s++) {
      double y = paddingY + (s * stringSpacing);
      stringPaint.strokeWidth = 1.0 + (5 - s) * 0.4; // Thickness
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

  void _drawNote(Canvas canvas, Offset center, String label, int pc, int rootPc, bool isOpen) {
    int interval = (pc - rootPc + 12) % 12;

    // Use centralized theme colors
    final color = AppTheme.getIntervalColor(interval);

    double r = 13.0;
    canvas.drawCircle(center, r, Paint()..color = color);
    canvas.drawCircle(center, r, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth=1.5);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
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
