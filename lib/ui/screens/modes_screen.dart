import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _isMajorFamily(String modeName) {
    final m = modeName.toLowerCase();
    if (m == 'ionian' || m == 'lydian' || m == 'mixolydian') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final modeName = _modeNames[_modeIdx];
    final TriadPack pack = TheoryEngine.buildModePack(_root, _modeIdx, modeName);
    final bool isMajor = _isMajorFamily(modeName);

    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);

    final Color noteBg = isMajor ? majorLight : minorLight;
    final Color noteTxt = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
    final Color noteBorder = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: scaffoldBg,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Modes Explorer",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Learn the 7 modes of the major scale",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Mode Selector Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: borderColor),
                    boxShadow: AppTheme.getShadow(context),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Root Selector
                          Expanded(
                            child: _ModernDropdown(
                              label: "Root",
                              value: _root,
                              items: _roots,
                              onChanged: (v) => setState(() => _root = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Mode Selector
                          Expanded(
                            flex: 2,
                            child: _ModernDropdown(
                              label: "Mode",
                              value: modeName,
                              items: _modeNames,
                              onChanged: (v) => setState(() => _modeIdx = _modeNames.indexOf(v!)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Mode Characteristics Card
                Builder(
                  builder: (context) {
                    final chars = TheoryEngine.kModeCharacteristics[modeName];
                    if (chars == null) return const SizedBox.shrink();

                    final isMajorFamily = chars['family'] == 'Major';
                    final cardColor = isMajorFamily ? majorLight : minorLight;
                    final textColor = isMajorFamily ? AppTheme.tonicBlue : AppTheme.minorAmber;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cardColor,
                            cardColor.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: textColor.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chars['mood'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                          const SizedBox(height: 14),
                          Text(
                            chars['character'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: textPrimary.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(Icons.music_note_rounded, size: 16, color: textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  chars['usage'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
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

                // Parent Key Relationship
                if (_modeIdx != 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: majorLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppTheme.tonicBlue,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 14, color: textPrimary),
                              children: [
                                TextSpan(
                                  text: '$_root $modeName',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(text: ' shares the same notes as '),
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

                const SizedBox(height: 28),

                // Scale Notes Section
                _SectionHeader(title: "Scale Notes"),
                const SizedBox(height: 12),

                Row(
                  children: pack.scale.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final note = entry.value;
                    final isRoot = idx == 0;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: idx == 6 ? 0 : 6),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
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
                          child: AnimatedContainer(
                            duration: AppTheme.durationFast,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isRoot ? noteTxt : noteBg,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(
                                color: noteBorder.withOpacity(isRoot ? 1.0 : 0.15),
                                width: isRoot ? 2 : 1,
                              ),
                              boxShadow: isRoot ? AppTheme.shadowGlow(noteTxt) : [],
                            ),
                            child: Text(
                              note,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isRoot ? Colors.white : noteTxt,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Diatonic Chords Section
                _SectionHeader(title: "Diatonic Chords"),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(pack.chordNames.length, (i) {
                        return ChordCardGrid(
                          width: itemWidth,
                          name: pack.chordNames[i],
                          notes: pack.notes[i],
                          roman: pack.roman[i],
                          onTap: () {
                            HapticFeedback.lightImpact();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return InteractiveFretboardSheet(
                                  chordName: pack.chordNames[i],
                                  chordNotes: pack.notes[i],
                                  isScale: false,
                                  root: pack.notes[i].isNotEmpty ? pack.notes[i][0] : 'C',
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.getTextPrimary(context),
        letterSpacing: -0.3,
      ),
    );
  }
}

class _ModernDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModernDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: scaffoldBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: cardBg,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((k) => DropdownMenuItem(
                value: k,
                child: Text(k),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
