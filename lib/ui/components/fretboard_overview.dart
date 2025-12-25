import 'package:flutter/material.dart';
import '../../core/theme.dart';

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
    // Theme-aware background color
    final bgColor = isDark ? const Color(0xFF334155) : Colors.grey[200]!;

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: constraints.maxWidth,
                  color: bgColor,
                  child: CustomPaint(
                    painter: _OverviewPainter(
                      scrollOffset: scrollController.hasClients ? scrollController.offset : 0,
                      viewportWidth: viewportWidth,
                      contentWidth: contentWidth,
                      isDark: isDark,
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

class _OverviewPainter extends CustomPainter {
  final double scrollOffset;
  final double viewportWidth;
  final double contentWidth;
  final bool isDark;

  _OverviewPainter({
    required this.scrollOffset,
    required this.viewportWidth,
    required this.contentWidth,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw background hint dots (optional, keeping simple for now)
    
    // 2. Draw View Box
    double scale = size.width / contentWidth;
    double boxWidth = viewportWidth * scale;
    double boxX = scrollOffset * scale;
    
    // Clamp
    if (boxWidth > size.width) boxWidth = size.width;
    
    final Rect viewRect = Rect.fromLTWH(boxX, 0, boxWidth, size.height);
    
    // Adjust opacity for dark mode
    final fillOpacity = isDark ? 0.4 : 0.3;
    
    final Paint boxPaint = Paint()
      ..color = AppTheme.tonicBlue.withOpacity(fillOpacity)
      ..style = PaintingStyle.fill;
      
    final Paint borderPaint = Paint()
      ..color = AppTheme.tonicBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(viewRect, boxPaint);
    canvas.drawRect(viewRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _OverviewPainter oldDelegate) => 
      oldDelegate.scrollOffset != scrollOffset ||
      oldDelegate.isDark != isDark;
}
