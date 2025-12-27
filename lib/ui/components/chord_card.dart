import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import 'interactive_fretboard_sheet.dart';

/// Unified compact chord card used across all screens.
/// Modern design with smooth animations and haptic feedback.
class ChordCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    // Determine chord quality colors
    final safeRoman = roman ?? '';
    final bool isDim = safeRoman.contains('°') ||
        safeRoman.toLowerCase().contains('dim') ||
        name.contains('°') || name.toLowerCase().contains('dim');
    final bool isAug = safeRoman.contains('+') ||
        safeRoman.toLowerCase().contains('aug') ||
        name.contains('+');
    final bool isMinor = !isDim && !isAug && (
        (safeRoman.isNotEmpty && safeRoman[0] == safeRoman[0].toLowerCase()) ||
        name.toLowerCase().contains('m') && !name.toLowerCase().contains('maj')
    );
    final bool isMajor = !isDim && !isMinor && !isAug;

    Color badgeBg;
    Color badgeText;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = AppTheme.accentRed;
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = AppTheme.accentPurple;
    } else if (isMajor) {
      badgeBg = majorLight;
      badgeText = AppTheme.tonicBlue;
    } else {
      badgeBg = minorLight;
      badgeText = AppTheme.minorAmber;
    }

    // Override colors for badge (transposer index)
    if (badge != null) {
      badgeBg = isDark ? const Color(0xFF334155) : Colors.grey[100]!;
      badgeText = textSecondary;
    }

    // Extract root for fretboard display
    String root = name.isNotEmpty ? name[0] : 'C';
    if (name.length > 1 && (name[1] == '#' || name[1] == 'b' || name[1] == '♯' || name[1] == '♭')) {
      root = name.substring(0, 2);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InteractiveFretboardSheet(
              chordName: name,
              tones: notes,
              root: root,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: AppTheme.curveEaseOut,
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor),
          boxShadow: AppTheme.getShadow(context, size: 'sm'),
        ),
        child: Row(
          children: [
            // Chord name badge
            Container(
              constraints: const BoxConstraints(minWidth: 54),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: badgeText,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 12),

            // Notes display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notes.join(' • '),
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${notes.length} notes",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Roman numeral or badge (optional)
            if (roman != null || badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.getScaffoldBg(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  badge ?? roman!,
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grid layout chord card - for 2-column layouts (Circle, Modes screens)
class ChordCardGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    final safeRoman = roman ?? '';
    final bool isDim = safeRoman.contains('°');
    final bool isAug = safeRoman.contains('+');
    final bool isMajor = !isDim && !isAug &&
        (safeRoman.isNotEmpty && safeRoman[0] == safeRoman[0].toUpperCase());

    Color badgeBg;
    Color badgeText;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = AppTheme.accentRed;
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = AppTheme.accentPurple;
    } else if (isMajor) {
      badgeBg = majorLight;
      badgeText = AppTheme.tonicBlue;
    } else {
      badgeBg = minorLight;
      badgeText = AppTheme.minorAmber;
    }

    String root = name.isNotEmpty ? name[0] : 'C';
    if (name.length > 1 && (name[1] == '#' || name[1] == 'b')) {
      root = name.substring(0, 2);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InteractiveFretboardSheet(
              chordName: name,
              tones: notes,
              root: root,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: AppTheme.curveEaseOut,
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor),
          boxShadow: AppTheme.getShadow(context, size: 'sm'),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chord name badge
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: badgeText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Roman numeral
                if (safeRoman.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getScaffoldBg(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
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

            const SizedBox(height: 10),

            // Notes display
            Text(
              notes.join(' • '),
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
