import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/note_utils.dart';
import '../../core/theme.dart';

/// Callback for when a piano key is tapped.
/// Provides the note name and pitch class.
typedef OnKeyTap = void Function(String noteName, int pitchClass);

/// Premium scrollable piano keyboard with realistic 3D appearance.
/// Features elegant ivory and ebony keys with proper lighting and depth.
///
/// Highlights:
/// - root notes (filled colored circle with glow)
/// - other tones (elegant outlined circle with note name)
/// - tap-to-play functionality when [onKeyTap] is provided
/// - animated key press visual feedback
class PianoKeyboard extends StatefulWidget {
  final List<String> tones;
  final String root;
  final int octaves;
  final bool isDark;

  /// Starting pitch class (0 = C). You can change this if you want the keyboard to start elsewhere.
  final int startPc;

  /// Optional callback when a key is tapped. If null, keys are not interactive.
  final OnKeyTap? onKeyTap;

  /// Whether to provide haptic feedback on key tap
  final bool enableHaptics;

  const PianoKeyboard({
    super.key,
    required this.tones,
    required this.root,
    this.octaves = 1,
    this.startPc = 0,
    this.isDark = false,
    this.onKeyTap,
    this.enableHaptics = true,
  });

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> with SingleTickerProviderStateMixin {
  // White key pitch classes in order (C D E F G A B)
  static const List<int> _whitePcs = [0, 2, 4, 5, 7, 9, 11];

  // Black key positions (after which white key index)
  static const List<int> _blackKeyPositions = [0, 1, 3, 4, 5]; // C# D# F# G# A#
  static const List<int> _blackKeyPcs = [1, 3, 6, 8, 10];

  /// Currently pressed key index (-1 for none, 0-6 for white keys in first octave,
  /// 7-13 for second octave, 100+ for black keys encoded as 100 + octave*5 + blackIndex)
  int? _pressedKeyIndex;

  /// Animation controller for key press effect
  late AnimationController _pressAnimController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressAnimController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = CurvedAnimation(
      parent: _pressAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pressAnimController.dispose();
    super.dispose();
  }

  /// Handle tap down - show pressed state
  void _handleTapDown(TapDownDetails details, double keyboardWidth) {
    final keyInfo = _getKeyAtPosition(details.localPosition, keyboardWidth);
    if (keyInfo != null) {
      setState(() => _pressedKeyIndex = keyInfo.index);
      _pressAnimController.forward(from: 0);
    }
  }

  /// Handle tap up - trigger callback and release
  void _handleTapUp(TapUpDetails details, double keyboardWidth) {
    final keyInfo = _getKeyAtPosition(details.localPosition, keyboardWidth);
    if (keyInfo != null) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      widget.onKeyTap?.call(keyInfo.noteName, keyInfo.pitchClass);
    }
    _releaseKey();
  }

  /// Handle tap cancel - release without triggering
  void _handleTapCancel() {
    _releaseKey();
  }

  void _releaseKey() {
    _pressAnimController.reverse().then((_) {
      if (mounted) {
        setState(() => _pressedKeyIndex = null);
      }
    });
  }

  /// Get key info at a given position
  _KeyInfo? _getKeyAtPosition(Offset position, double keyboardWidth) {
    final effectiveOctaves = widget.octaves <= 1 ? 1 : 2;
    final whiteKeyCount = 7 * effectiveOctaves;
    final whiteKeyWidth = keyboardWidth / whiteKeyCount;
    final blackKeyWidth = whiteKeyWidth * 0.58;
    final blackKeyHeight = 220 * 0.62;

    // First check if tap is on a black key (they're on top)
    if (position.dy < blackKeyHeight) {
      for (int oct = 0; oct < effectiveOctaves; oct++) {
        final baseWhiteIndex = oct * 7;

        for (int i = 0; i < _blackKeyPositions.length; i++) {
          final leftWhite = baseWhiteIndex + _blackKeyPositions[i];
          if (leftWhite >= whiteKeyCount - 1) continue;

          // Calculate black key position
          final xCenter = (leftWhite + 1) * whiteKeyWidth;
          final blackX = xCenter - blackKeyWidth / 2 - whiteKeyWidth * 0.08;

          if (position.dx >= blackX && position.dx <= blackX + blackKeyWidth) {
            final pitchClass = (_blackKeyPcs[i] + widget.startPc) % 12;
            final noteName = NoteUtils.pitchClassToNote(pitchClass);
            // Encode black key index: 100 + octave*5 + blackKeyIndex
            return _KeyInfo(
              index: 100 + oct * 5 + i,
              noteName: noteName,
              pitchClass: pitchClass,
              isBlack: true,
            );
          }
        }
      }
    }

    // Must be a white key
    final whiteKeyIndex = (position.dx / whiteKeyWidth).floor();
    if (whiteKeyIndex >= 0 && whiteKeyIndex < whiteKeyCount) {
      final degree = whiteKeyIndex % 7;
      final pitchClass = (_whitePcs[degree] + widget.startPc) % 12;
      final noteName = NoteUtils.pitchClassToNote(pitchClass);
      return _KeyInfo(
        index: whiteKeyIndex,
        noteName: noteName,
        pitchClass: pitchClass,
        isBlack: false,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totalWhiteKeys = 7 * (widget.octaves <= 1 ? 1 : 2);
    const whiteKeyWidth = 52.0;
    final keyboardWidth = totalWhiteKeys * whiteKeyWidth;

    // Premium case colors
    final caseColor = widget.isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFF2D2D3A);
    final caseHighlight = widget.isDark
        ? const Color(0xFF252538)
        : const Color(0xFF3D3D4A);

    // Build semantic description for accessibility
    final notesDescription = widget.tones.isNotEmpty
        ? 'Notes highlighted: ${widget.tones.join(", ")}'
        : 'No notes highlighted';
    final semanticLabel = 'Piano keyboard visualization. '
        'Root: ${widget.root}. $notesDescription. '
        '${widget.octaves > 1 ? "Swipe horizontally to see more keys." : ""}';

    return Semantics(
      label: semanticLabel,
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.4 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.1),
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
                    child: GestureDetector(
                      onTapDown: widget.onKeyTap != null
                          ? (details) => _handleTapDown(details, keyboardWidth)
                          : null,
                      onTapUp: widget.onKeyTap != null
                          ? (details) => _handleTapUp(details, keyboardWidth)
                          : null,
                      onTapCancel: widget.onKeyTap != null
                          ? _handleTapCancel
                          : null,
                      child: AnimatedBuilder(
                        animation: _pressAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width: keyboardWidth,
                            height: 220,
                            child: CustomPaint(
                              painter: _PremiumPianoPainter(
                                tones: widget.tones,
                                root: widget.root,
                                octaves: widget.octaves <= 1 ? 1 : 2,
                                startPc: widget.startPc,
                                isDark: widget.isDark,
                                pressedKeyIndex: _pressedKeyIndex,
                                pressAmount: _pressAnimation.value,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// Information about a piano key
class _KeyInfo {
  final int index;
  final String noteName;
  final int pitchClass;
  final bool isBlack;

  _KeyInfo({
    required this.index,
    required this.noteName,
    required this.pitchClass,
    required this.isBlack,
  });
}

class _PremiumPianoPainter extends CustomPainter {
  final List<String> tones;
  final String root;
  final int octaves;
  final int startPc;
  final bool isDark;
  final int? pressedKeyIndex;
  final double pressAmount;

  _PremiumPianoPainter({
    required this.tones,
    required this.root,
    required this.octaves,
    required this.startPc,
    required this.isDark,
    this.pressedKeyIndex,
    this.pressAmount = 0.0,
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
      // Check if this white key is pressed (index < 100 means white key)
      final isPressed = pressedKeyIndex != null &&
          pressedKeyIndex! < 100 &&
          pressedKeyIndex == i;
      _drawWhiteKey(canvas, x, whiteW, whiteH, isFirst, isLast, isPressed ? pressAmount : 0.0);
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

      for (int i = 0; i < blackPositions.length; i++) {
        final pos = blackPositions[i];
        final leftWhite = baseWhiteIndex + pos;
        if (leftWhite >= whiteKeyCount - 1) continue;

        final pc = _pcForBlackAtWhite(leftWhite);

        // Position black key between white keys with slight offset
        final xCenter = (leftWhite + 1) * whiteW;
        final blackX = xCenter - blackW / 2 - whiteW * 0.08;

        // Check if this black key is pressed (index >= 100)
        // Black key index encoding: 100 + octave*5 + blackKeyIndex
        final blackKeyEncodedIndex = 100 + oct * 5 + i;
        final isPressed = pressedKeyIndex == blackKeyEncodedIndex;
        _drawBlackKey(canvas, blackX, blackW, blackH, isPressed ? pressAmount : 0.0);

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

  void _drawWhiteKey(Canvas canvas, double x, double width, double height, bool isFirst, bool isLast, double pressAmount) {
    final keyGap = 1.0;
    // Apply press effect: key appears to move down slightly
    final pressOffset = pressAmount * 3.0;
    final keyRect = Rect.fromLTWH(x + keyGap / 2, pressOffset, width - keyGap, height - pressOffset);

    // Key body with rounded bottom
    final RRect keyRRect = RRect.fromRectAndCorners(
      keyRect,
      bottomLeft: Radius.circular(isFirst ? 6 : 4),
      bottomRight: Radius.circular(isLast ? 6 : 4),
    );

    // Pressed keys are slightly darker
    final pressedDarken = pressAmount * 0.08;

    // Main ivory gradient (top to bottom for 3D effect)
    final Paint ivoryGradient = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                Color.lerp(const Color(0xFFE8E4DC), Colors.black, pressedDarken)!,
                Color.lerp(const Color(0xFFF5F2EB), Colors.black, pressedDarken)!,
                Color.lerp(const Color(0xFFEAE6DE), Colors.black, pressedDarken)!,
                Color.lerp(const Color(0xFFDDD9D0), Colors.black, pressedDarken)!,
              ]
            : [
                Color.lerp(const Color(0xFFFFFEFA), Colors.black, pressedDarken)!,
                Color.lerp(const Color(0xFFFFFDF8), Colors.black, pressedDarken)!,
                Color.lerp(const Color(0xFFF8F5EE), Colors.black, pressedDarken)!,
                Color.lerp(const Color(0xFFEDE9E0), Colors.black, pressedDarken)!,
              ],
        stops: const [0.0, 0.15, 0.85, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(keyRect);

    // Drop shadow for key depth (reduced when pressed)
    final shadowOpacity = 0.15 * (1.0 - pressAmount * 0.7);
    canvas.drawRRect(
      keyRRect.shift(Offset(0, 2 * (1.0 - pressAmount))),
      Paint()..color = Colors.black.withOpacity(shadowOpacity),
    );

    // Main key body
    canvas.drawRRect(keyRRect, ivoryGradient);

    // Side shadow (left edge) for 3D separation
    final Paint leftShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.08 + pressAmount * 0.04),
          Colors.transparent,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x, pressOffset, 4, height - pressOffset));
    canvas.drawRect(Rect.fromLTWH(x + keyGap / 2, pressOffset, 3, height - pressOffset), leftShadow);

    // Top edge highlight (simulates light from above) - dimmed when pressed
    final highlightOpacity = 0.7 * (1.0 - pressAmount * 0.5);
    canvas.drawLine(
      Offset(x + keyGap / 2 + 2, pressOffset + 1),
      Offset(x + width - keyGap / 2 - 2, pressOffset + 1),
      Paint()
        ..color = Colors.white.withOpacity(highlightOpacity)
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

    // Bottom edge (key front face simulation) - shorter when pressed
    final bottomHeight = 4.0 * (1.0 - pressAmount * 0.5);
    final bottomEdge = Rect.fromLTWH(x + keyGap / 2, height - bottomHeight, width - keyGap, bottomHeight);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        bottomEdge,
        bottomLeft: Radius.circular(isFirst ? 6 : 4),
        bottomRight: Radius.circular(isLast ? 6 : 4),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFD4D0C8), Colors.black, pressedDarken)!,
            Color.lerp(const Color(0xFFC8C4BC), Colors.black, pressedDarken)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bottomEdge),
    );
  }

  void _drawBlackKey(Canvas canvas, double x, double width, double height, double pressAmount) {
    // Apply press effect: key appears to move down slightly
    final pressOffset = pressAmount * 2.0;
    final keyRect = Rect.fromLTWH(x, pressOffset, width, height - pressOffset);

    // Black key with beveled 3D appearance
    final RRect keyRRect = RRect.fromRectAndCorners(
      keyRect,
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );

    // Shadow underneath (reduced when pressed)
    final shadowOpacity = 0.5 * (1.0 - pressAmount * 0.6);
    canvas.drawRRect(
      keyRRect.shift(Offset(2 * (1.0 - pressAmount), 3 * (1.0 - pressAmount))),
      Paint()..color = Colors.black.withOpacity(shadowOpacity),
    );

    // Pressed keys get slightly lighter (simulating light hitting differently)
    final pressedLighten = pressAmount * 0.05;

    // Main ebony body with gradient
    final Paint ebonyGradient = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                Color.lerp(const Color(0xFF252525), Colors.white, pressedLighten)!,
                Color.lerp(const Color(0xFF1A1A1A), Colors.white, pressedLighten)!,
                Color.lerp(const Color(0xFF151515), Colors.white, pressedLighten)!,
                Color.lerp(const Color(0xFF0D0D0D), Colors.white, pressedLighten)!,
              ]
            : [
                Color.lerp(const Color(0xFF2A2A2A), Colors.white, pressedLighten)!,
                Color.lerp(const Color(0xFF1F1F1F), Colors.white, pressedLighten)!,
                Color.lerp(const Color(0xFF171717), Colors.white, pressedLighten)!,
                Color.lerp(const Color(0xFF0F0F0F), Colors.white, pressedLighten)!,
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(keyRect);

    canvas.drawRRect(keyRRect, ebonyGradient);

    // Top bevel highlight (simulates light hitting the top edge) - reduced when pressed
    final topBevelOpacity = (1.0 - pressAmount * 0.5);
    final topBevel = Rect.fromLTWH(x, pressOffset, width, 3);
    canvas.drawRRect(
      RRect.fromRectAndCorners(topBevel),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15 * topBevelOpacity),
            Colors.white.withOpacity(0.05 * topBevelOpacity),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topBevel),
    );

    // Left edge highlight
    canvas.drawLine(
      Offset(x + 1, pressOffset + 2),
      Offset(x + 1, height - 4),
      Paint()
        ..color = Colors.white.withOpacity(0.08 * (1.0 - pressAmount * 0.3))
        ..strokeWidth = 1,
    );

    // Center specular highlight (glossy appearance) - enhanced slightly when pressed
    final specularOpacity = 0.12 + pressAmount * 0.08;
    final centerHighlight = Rect.fromLTWH(x + width * 0.3, pressOffset + 4, width * 0.4, (height - pressOffset) * 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerHighlight, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(specularOpacity),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(centerHighlight),
    );

    // Bottom rounded edge (shorter when pressed)
    final bottomEdgeHeight = 6.0 * (1.0 - pressAmount * 0.5);
    final bottomEdge = Rect.fromLTWH(x, height - bottomEdgeHeight, width, bottomEdgeHeight);
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
    final oct = (whiteIndex ~/ 7);
    final degree = whiteIndex % 7;
    return (_whitePcs[degree] + (oct * 12) + startPc) % 12;
  }

  int _pcForBlackAtWhite(int leftWhiteIndex) {
    final degree = leftWhiteIndex % 7;
    final oct = (leftWhiteIndex ~/ 7);

    final map = <int, int>{0: 1, 1: 3, 3: 6, 4: 8, 5: 10};
    final pc = map[degree] ?? 1;
    return (pc + (oct * 12) + startPc) % 12;
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
        oldDelegate.tones.length != tones.length ||
        oldDelegate.pressedKeyIndex != pressedKeyIndex ||
        oldDelegate.pressAmount != pressAmount;
  }
}
