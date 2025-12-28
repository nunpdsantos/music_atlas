import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'interactive_fretboard_sheet.dart';

/// Unified compact chord card used across all screens.
/// Designed to be space-efficient while maintaining visual clarity.
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
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    // Determine chord quality colors from roman numeral or name
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

    // Theme-aware accent colors for badge text
    final tonicBlue = AppTheme.getTonicBlue(context);
    final minorAmber = AppTheme.getMinorAmber(context);

    // Color scheme based on chord quality
    Color badgeBg;
    Color badgeText;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = isDark ? const Color(0xFFFB7185) : const Color(0xFFD32F2F);
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
    } else if (isMajor) {
      badgeBg = majorLight;
      badgeText = tonicBlue;
    } else {
      badgeBg = minorLight;
      badgeText = minorAmber;
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
      onTap: onTap ?? () {
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
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chord name badge
            Container(
              constraints: const BoxConstraints(minWidth: 44),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: badgeText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Notes display
            Expanded(
              child: Text(
                notes.join(' • '),
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Roman numeral or badge (optional)
            if (roman != null || badge != null) ...[
              const SizedBox(width: 8),
              Text(
                badge ?? roman!,
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    // Theme-aware accent colors for badge text
    final tonicBlue = AppTheme.getTonicBlue(context);
    final minorAmber = AppTheme.getMinorAmber(context);

    final safeRoman = roman ?? '';
    final bool isDim = safeRoman.contains('°');
    final bool isAug = safeRoman.contains('+');
    final bool isMajor = !isDim && !isAug &&
        (safeRoman.isNotEmpty && safeRoman[0] == safeRoman[0].toUpperCase());

    Color badgeBg;
    Color badgeText;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = isDark ? const Color(0xFFFB7185) : const Color(0xFFD32F2F);
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
    } else if (isMajor) {
      badgeBg = majorLight;
      badgeText = tonicBlue;
    } else {
      badgeBg = minorLight;
      badgeText = minorAmber;
    }

    String root = name.isNotEmpty ? name[0] : 'C';
    if (name.length > 1 && (name[1] == '#' || name[1] == 'b')) {
      root = name.substring(0, 2);
    }

    return GestureDetector(
      onTap: onTap ?? () {
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
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                // Chord name badge
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      safeRoman,
                      style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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
