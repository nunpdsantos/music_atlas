import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../logic/theory_engine.dart';
import '../../data/models.dart';
import '../components/chord_card.dart';
import '../components/interactive_fretboard_sheet.dart';

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  String _root = 'C';
  int _modeIdx = 0;
  final List<String> _roots = TheoryEngine.kCircleMajClock;
  static const _modeNames = ['Ionian', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Aeolian', 'Locrian'];

  // Helper to determine color based on Major/Minor family
  bool _isMajorFamily(String modeName) {
    final m = modeName.toLowerCase();
    // Ionian, Lydian, Mixolydian -> Major (Blue)
    if (m == 'ionian' || m == 'lydian' || m == 'mixolydian') return true;
    // Dorian, Phrygian, Aeolian, Locrian -> Minor (Amber)
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final modeName = _modeNames[_modeIdx];
    final TriadPack pack = TheoryEngine.buildModePack(_root, _modeIdx, modeName);
    final bool isMajor = _isMajorFamily(modeName);

    // Theme-aware colors
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    // Dynamic Colors for the Scale Row
    // Light mode: subtle backgrounds with colored text
    // Dark mode: vibrant backgrounds with white text
    final Color noteBg;
    final Color noteTxt;
    final Color noteBorder;

    if (isDark) {
      // Dark mode - bright vibrant colors
      noteBg = isMajor ? AppTheme.tonicBlue : const Color(0xFFF97316);
      noteTxt = Colors.white;
      noteBorder = isMajor ? AppTheme.tonicBlue : const Color(0xFFF97316);
    } else {
      // Light mode - subtle backgrounds with colored text
      noteBg = isMajor ? majorLight : minorLight;
      noteTxt = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
      noteBorder = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Modes Explorer",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        ),
        backgroundColor: scaffoldBg,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Controls Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _root,
                    dropdownColor: cardBg,
                    style: TextStyle(color: textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Root",
                      labelStyle: TextStyle(color: textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.tonicBlue),
                      ),
                    ),
                    items: _roots.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) => setState(() => _root = v!),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _modeIdx,
                    dropdownColor: cardBg,
                    style: TextStyle(color: textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Mode",
                      labelStyle: TextStyle(color: textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.tonicBlue),
                      ),
                    ),
                    items: List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(_modeNames[i]))),
                    onChanged: (v) => setState(() => _modeIdx = v!),
                  ),
                ),
              ],
            ),
          ),

          // MODE CHARACTERISTICS CARD
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final chars = TheoryEngine.kModeCharacteristics[modeName];
              if (chars == null) return const SizedBox.shrink();
              
              final isMajorFamily = chars['family'] == 'Major';
              final cardColor = isMajorFamily ? majorLight : minorLight;
              final textColor = isMajorFamily ? AppTheme.tonicBlue : AppTheme.minorAmber;
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(isDark ? 0.3 : 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with mood and family badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chars['mood'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chars['family'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Character description
                    Text(
                      chars['character'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: textPrimary.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Usage examples
                    Row(
                      children: [
                        Icon(Icons.music_note, size: 14, color: textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            chars['usage'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // PARENT KEY RELATIONSHIP
          if (_modeIdx != 0) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, color: textPrimary),
                        children: [
                          TextSpan(
                            text: '$_root $modeName',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: ' uses the same notes as '),
                          TextSpan(
                            text: '${TheoryEngine.getParentMajorForMode(_root, _modeIdx)} Major',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.tonicBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 2. Scale Notes (Dynamic Colors)
          Text(
            "SCALE NOTES",
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w700, 
              letterSpacing: 0.5, 
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: pack.scale.asMap().entries.map((entry) {
              final idx = entry.key;
              final note = entry.value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return InteractiveFretboardSheet(
                          chordName: "$_root $modeName Scale",
                          chordNotes: pack.scale,
                          isScale: true,
                          root: _root,
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: idx == 6 ? 0 : 4),
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: noteBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: noteBorder.withOpacity(0.2)),
                    ),
                    child: Text(
                      note,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: noteTxt,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          Text(
            "DIATONIC CHORDS",
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w700, 
              letterSpacing: 0.5, 
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: List.generate(pack.chordNames.length, (i) {
                  return ChordCardGrid(
                    width: itemWidth,
                    name: pack.chordNames[i],
                    notes: pack.notes[i],
                    roman: pack.roman[i],
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
