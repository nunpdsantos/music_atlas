import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import 'interactive_fretboard_sheet.dart';

/// Unified compact chord card used across all screens.
/// Designed to be space-efficient while maintaining visual clarity.
class ChordCard extends StatefulWidget {
  final String name;
  final List<String> notes;
  final String? roman;
  final String? badge;
  final List<String>? notesEnharmonicAlt;
  final double? width;
  final VoidCallback? onTap;

  const ChordCard({
    super.key,
    required this.name,
    required this.notes,
    this.roman,
    this.badge,
    this.notesEnharmonicAlt,
    this.width,
    this.onTap,
  });

  @override
  State<ChordCard> createState() => _ChordCardState();
}

class _ChordCardState extends State<ChordCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    // Determine chord quality colors from roman numeral or name
    final safeRoman = widget.roman ?? '';
    final bool isDim = safeRoman.contains('°') ||
        safeRoman.toLowerCase().contains('dim') ||
        widget.name.contains('°') ||
        widget.name.toLowerCase().contains('dim');
    final bool isAug = safeRoman.contains('+') ||
        safeRoman.toLowerCase().contains('aug') ||
        widget.name.contains('+');
    final bool isMinor = !isDim &&
        !isAug &&
        ((safeRoman.isNotEmpty &&
                safeRoman[0] == safeRoman[0].toLowerCase()) ||
            widget.name.toLowerCase().contains('m') &&
                !widget.name.toLowerCase().contains('maj'));
    final bool isMajor = !isDim && !isMinor && !isAug;

    // Color scheme based on chord quality
    Color badgeBg;
    Color badgeText;
    Color accentColor;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = const Color(0xFFD32F2F);
      accentColor = const Color(0xFFD32F2F);
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = const Color(0xFF7C3AED);
      accentColor = const Color(0xFF7C3AED);
    } else if (isMajor) {
      badgeBg = majorLight;
      badgeText = AppTheme.tonicBlue;
      accentColor = AppTheme.tonicBlue;
    } else {
      badgeBg = minorLight;
      badgeText = AppTheme.minorAmber;
      accentColor = AppTheme.minorAmber;
    }

    // Override colors for badge (transposer index)
    if (widget.badge != null) {
      badgeBg = isDark ? const Color(0xFF334155) : Colors.grey[100]!;
      badgeText = textSecondary;
    }

    // Extract root for fretboard display
    String root = widget.name.isNotEmpty ? widget.name[0] : 'C';
    if (widget.name.length > 1 &&
        (widget.name[1] == '#' ||
            widget.name[1] == 'b' ||
            widget.name[1] == '♯' ||
            widget.name[1] == '♭')) {
      root = widget.name.substring(0, 2);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InteractiveFretboardSheet(
              chordName: widget.name,
              tones: widget.notes,
              root: root,
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed ? accentColor.withOpacity(0.3) : borderColor,
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? accentColor.withOpacity(0.15)
                    : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Chord name badge with gradient
              Container(
                constraints: const BoxConstraints(minWidth: 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      badgeBg,
                      badgeBg.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeText.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: badgeText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 12),

              // Notes display
              Expanded(
                child: Text(
                  widget.notes.join(' • '),
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Roman numeral or badge (optional)
              if (widget.roman != null || widget.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.badge ?? widget.roman!,
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],

              // Arrow indicator
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid layout chord card - for 2-column layouts (Circle, Modes screens)
class ChordCardGrid extends StatefulWidget {
  final String name;
  final List<String> notes;
  final String? roman;
  final double? width;
  final VoidCallback? onTap;

  const ChordCardGrid({
    super.key,
    required this.name,
    required this.notes,
    this.roman,
    this.width,
    this.onTap,
  });

  @override
  State<ChordCardGrid> createState() => _ChordCardGridState();
}

class _ChordCardGridState extends State<ChordCardGrid> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    final safeRoman = widget.roman ?? '';
    final bool isDim = safeRoman.contains('°');
    final bool isAug = safeRoman.contains('+');
    final bool isMajor =
        !isDim && !isAug && (safeRoman.isNotEmpty && safeRoman[0] == safeRoman[0].toUpperCase());

    Color badgeBg;
    Color badgeText;
    Color accentColor;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = const Color(0xFFD32F2F);
      accentColor = const Color(0xFFD32F2F);
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = const Color(0xFF7C3AED);
      accentColor = const Color(0xFF7C3AED);
    } else if (isMajor) {
      badgeBg = majorLight;
      badgeText = AppTheme.tonicBlue;
      accentColor = AppTheme.tonicBlue;
    } else {
      badgeBg = minorLight;
      badgeText = AppTheme.minorAmber;
      accentColor = AppTheme.minorAmber;
    }

    String root = widget.name.isNotEmpty ? widget.name[0] : 'C';
    if (widget.name.length > 1 && (widget.name[1] == '#' || widget.name[1] == 'b')) {
      root = widget.name.substring(0, 2);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InteractiveFretboardSheet(
              chordName: widget.name,
              tones: widget.notes,
              root: root,
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed ? accentColor.withOpacity(0.4) : borderColor,
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? accentColor.withOpacity(0.2)
                    : Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                blurRadius: _isPressed ? 16 : 8,
                offset: Offset(0, _isPressed ? 6 : 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chord name badge with gradient
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            badgeBg,
                            badgeBg.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: badgeText.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          color: badgeText,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Roman numeral badge
                  if (safeRoman.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        safeRoman,
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Notes display with enhanced styling
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.notes.join(' • '),
                      style: TextStyle(
                        color: textPrimary.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
