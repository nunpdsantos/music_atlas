import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Premium fretboard scroll overview/minimap with refined visual design.
/// Provides an elegant scrollbar-style indicator for navigating the fretboard.
class FretboardOverview extends StatelessWidget {
  final List<String> tones;
  final String root;
  final int octaves;
  final bool leftHanded;
  final double viewportWidth;
  final double contentWidth;
  final ScrollController scrollController;
  final bool isDark;

  const FretboardOverview({
    super.key,
    required this.tones,
    required this.root,
    required this.octaves,
    required this.leftHanded,
    required this.viewportWidth,
    required this.contentWidth,
    required this.scrollController,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: scrollController,
          builder: (context, child) {
            return GestureDetector(
              onPanUpdate: (details) {
                final double renderWidth = constraints.maxWidth;
                final double scale = contentWidth / renderWidth;
                final double delta = details.delta.dx * scale;
                final double newOffset = (scrollController.offset + delta)
                    .clamp(0.0, scrollController.position.maxScrollExtent);
                scrollController.jumpTo(newOffset);
              },
              child: Container(
                width: constraints.maxWidth,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2D1810), const Color(0xFF3D2218)]
                        : [const Color(0xFF3E1F14), const Color(0xFF4A2819)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: CustomPaint(
                    painter: _PremiumOverviewPainter(
                      scrollOffset: scrollController.hasClients ? scrollController.offset : 0,
                      viewportWidth: viewportWidth,
                      contentWidth: contentWidth,
                      isDark: isDark,
                      leftHanded: leftHanded,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PremiumOverviewPainter extends CustomPainter {
  final double scrollOffset;
  final double viewportWidth;
  final double contentWidth;
  final bool isDark;
  final bool leftHanded;

  _PremiumOverviewPainter({
    required this.scrollOffset,
    required this.viewportWidth,
    required this.contentWidth,
    required this.isDark,
    required this.leftHanded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / contentWidth;

    // Draw subtle fret position indicators
    _drawFretIndicators(canvas, size, scale);

    // Draw fret marker positions (dots at 3, 5, 7, 9, 12)
    _drawMarkerIndicators(canvas, size, scale);

    // Draw viewport indicator
    _drawViewportIndicator(canvas, size, scale);
  }

  void _drawFretIndicators(Canvas canvas, Size size, double scale) {
    final fretPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1;

    // Approximate fret positions (12 frets + open)
    final fretWidth = contentWidth / 12;
    for (int i = 1; i <= 12; i++) {
      double x = leftHanded
          ? size.width - (i * fretWidth * scale)
          : i * fretWidth * scale;
      canvas.drawLine(
        Offset(x, 4),
        Offset(x, size.height - 4),
        fretPaint,
      );
    }
  }

  void _drawMarkerIndicators(Canvas canvas, Size size, double scale) {
    const markerFrets = [3, 5, 7, 9, 12];
    final fretWidth = contentWidth / 12;

    for (int fret in markerFrets) {
      double x;
      if (leftHanded) {
        x = size.width - ((fret - 0.5) * fretWidth * scale);
      } else {
        x = (fret - 0.5) * fretWidth * scale;
      }

      final markerPaint = Paint()
        ..color = Colors.white.withOpacity(0.25);

      if (fret == 12) {
        // Double dot
        canvas.drawCircle(Offset(x, size.height / 2 - 5), 2.5, markerPaint);
        canvas.drawCircle(Offset(x, size.height / 2 + 5), 2.5, markerPaint);
      } else {
        canvas.drawCircle(Offset(x, size.height / 2), 2.5, markerPaint);
      }
    }
  }

  void _drawViewportIndicator(Canvas canvas, Size size, double scale) {
    double boxWidth = viewportWidth * scale;
    double boxX = scrollOffset * scale;

    if (boxWidth > size.width) boxWidth = size.width;

    final RRect viewRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, 2, boxWidth, size.height - 4),
      const Radius.circular(4),
    );

    // Gradient fill for viewport indicator
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.tonicBlue.withOpacity(0.35),
          AppTheme.tonicBlue.withOpacity(0.25),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(viewRRect.outerRect);

    // Glow effect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxX - 2, 0, boxWidth + 4, size.height),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.tonicBlue.withOpacity(0.15),
    );

    // Main fill
    canvas.drawRRect(viewRRect, fillPaint);

    // Border with glow effect
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.tonicBlue.withOpacity(0.8);

    canvas.drawRRect(viewRRect, borderPaint);

    // Inner highlight
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX + 1, 3, boxWidth - 2, size.height - 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant _PremiumOverviewPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset ||
      oldDelegate.isDark != isDark ||
      oldDelegate.leftHanded != leftHanded;
}
