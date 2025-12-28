import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers.dart';
import '../../logic/theory_engine.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../components/circle_of_fifths.dart';
import '../components/chord_card.dart';
import '../components/interactive_fretboard_sheet.dart';

class CircleScreen extends ConsumerWidget {
  const CircleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(circleProvider);
    final pack = ref.watch(triadPackProvider);

    // FIX: Access enum by index to avoid naming errors
    // 0 = Major, 1 = Relative Minor (or whatever the second option is named)
    final isMajor = state.view == KeyView.values[0];

    // Theme-aware colors
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final cardBg = AppTheme.getCardBg(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);

    final isDark = AppTheme.isDark(context);

    // Dynamic Colors for the Scale Row
    // Light mode: subtle backgrounds with colored text
    // Dark mode: vibrant backgrounds with white text
    final Color scaleBg;
    final Color scaleText;
    final Color scaleBorder;

    if (isDark) {
      // Dark mode - bright vibrant colors
      scaleBg = isMajor ? AppTheme.tonicBlue : const Color(0xFFF97316);
      scaleText = Colors.white;
      scaleBorder = isMajor ? AppTheme.tonicBlue : const Color(0xFFF97316);
    } else {
      // Light mode - subtle backgrounds with colored text
      scaleBg = isMajor ? majorLight : minorLight;
      scaleText = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
      scaleBorder = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Circle of Fifths"),
        backgroundColor: scaffoldBg,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        children: [
          // 1. The Circle
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340, maxHeight: 340),
              child: const InteractiveCircle(),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Current Key Card
          _CurrentKeyCard(pack: pack, state: state, ref: ref),

          // 3. Minor Type Toggle
          if (!isMajor)
            _MinorTypeSelector(
              current: state.minorType,
              onChanged: (t) => ref.read(circleProvider.notifier).setMinorType(t),
            ),

          const SizedBox(height: 20),

          // 4. Scale Notes Display
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
                    String title = "";
                    if (isMajor) {
                      title = "${pack.scale[0]} Major Scale";
                    } else {
                      String typeName = state.minorType.name;
                      typeName = typeName[0].toUpperCase() + typeName.substring(1);
                      title = "${pack.scale[0]} $typeName Minor Scale";
                    }

                    final sheetRoot = pack.scale.isNotEmpty ? pack.scale.first : 'C';

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: cardBg,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) {
                        return InteractiveFretboardSheet(
                          chordName: title,
                          chordNotes: pack.scale,
                          isScale: true,
                          root: sheetRoot,
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: idx == 6 ? 0 : 4),
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scaleBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: scaleBorder.withOpacity(0.1)),
                    ),
                    child: Text(
                      note,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scaleText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 5. Chords Grid
          Text(
            "Chords in ${pack.keyLabel}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;
              
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: List.generate(pack.chordNames.length, (i) {
                  final chordName = pack.chordNames[i];
                  final chordNotes = pack.notes[i];
                  
                  return ChordCardGrid(
                    width: itemWidth,
                    name: chordName,
                    notes: chordNotes,
                    roman: pack.roman[i],
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: cardBg,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return InteractiveFretboardSheet(
                            chordName: chordName,
                            chordNotes: chordNotes,
                            isScale: false,
                            root: chordNotes.isNotEmpty ? chordNotes[0] : 'C',
                          );
                        },
                      );
                    },
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CurrentKeyCard extends StatelessWidget {
  final TriadPack pack;
  final CircleState state;
  final WidgetRef ref;

  const _CurrentKeyCard({required this.pack, required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    // FIX: Use index 0
    final isMajor = state.view == KeyView.values[0];
    final root = state.selectedMajorRoot;
    final relMinor = TheoryEngine.kRelativeMinors[root] ?? '?';

    final activeColor = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
    
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Key name (full width, can wrap or ellipsis)
          Row(
            children: [
              Expanded(
                child: Text(
                  pack.keyLabel,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w800, 
                    color: activeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Key signature badge - compact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  TheoryEngine.getKeySignatureDisplay(root),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Row 2: Toggle buttons (left) + Relative key (right)
          Row(
            children: [
              // Toggle buttons
              Container(
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(circleProvider.notifier).setView(KeyView.values[0]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMajor ? cardBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isMajor ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3)] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Major",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isMajor ? AppTheme.tonicBlue : textSecondary,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(circleProvider.notifier).setView(KeyView.values[1]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: !isMajor ? cardBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: !isMajor ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3)] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Minor",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: !isMajor ? AppTheme.minorAmber : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Relative key on the right
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMajor ? "Rel. Minor" : "Rel. Major",
                    style: TextStyle(
                      fontSize: 10, 
                      color: textSecondary.withOpacity(0.7), 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scaffoldBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isMajor ? "${relMinor}m" : root,
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w700, 
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinorTypeSelector extends StatelessWidget {
  final MinorType current;
  final ValueChanged<MinorType> onChanged;

  const _MinorTypeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final isDark = AppTheme.isDark(context);

    // Dark mode: bright orange background with white text
    // Light mode: subtle amber background with amber text
    final Color activeBg = isDark ? const Color(0xFFF97316) : AppTheme.getMinorLight(context);
    final Color activeText = isDark ? Colors.white : AppTheme.minorAmber;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 36,
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: borderColor)),
      child: Row(
        children: MinorType.values.map((type) {
          final isActive = type == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: isActive ? activeBg : Colors.transparent, borderRadius: BorderRadius.circular(18)),
                child: Text(type.name[0].toUpperCase() + type.name.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? activeText : textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
