import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'interactive_fretboard_sheet.dart';

class ChordLabel extends ConsumerWidget {
  // Make width optional. If null, it will be flexible.
  final double? width;
  final String name;
  final List<String> notes;
  
  // Make roman optional (Search results don't have roman numerals)
  final String? roman;
  
  final bool compact;
  final String? badge;
  final List<String>? notesEnharmonicAlt;

  const ChordLabel({
    super.key,
    this.width,
    required this.name,
    required this.notes,
    this.roman,
    this.compact = false,
    this.badge,
    this.notesEnharmonicAlt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final isDark = AppTheme.isDark(context);

    // Determine chord quality from roman numeral
    final safeRoman = roman ?? '';
    final bool isDim = safeRoman.contains('°') || safeRoman.toLowerCase().contains('dim');
    final bool isAug = safeRoman.contains('+') || safeRoman.toLowerCase().contains('aug');
    final bool isMinor = !isDim && !isAug && safeRoman.isNotEmpty &&
        safeRoman[0] == safeRoman[0].toLowerCase();
    final bool isMajor = !isDim && !isMinor && !isAug;

    // Get standardized chord quality colors
    final (badgeBg, badgeText) = badge != null
        ? (isDark ? const Color(0xFF334155) : Colors.grey[200]!, textSecondary)
        : AppTheme.getChordQualityColors(
            context,
            isMajor: isMajor,
            isMinor: isMinor,
            isDim: isDim,
            isAug: isAug,
          );

    return GestureDetector(
      onTap: () {
        // Extract root from chord name (first letter + optional accidental)
        String root = name.isNotEmpty ? name[0] : 'C';
        if (name.length > 1 && (name[1] == '#' || name[1] == 'b')) {
          root = name.substring(0, 2);
        }
        
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chord name badge - with Flexible to prevent overflow
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: badgeText,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                // Only show badge/roman if they exist
                if (badge != null || safeRoman.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      badge ?? safeRoman, 
                      style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notes
            Text(
              notes.join(' • '), 
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
