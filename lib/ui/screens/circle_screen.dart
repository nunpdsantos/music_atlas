import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final isMajor = state.view == KeyView.values[0];

    // Theme-aware colors
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final cardBg = AppTheme.getCardBg(context);
    final majorLight = AppTheme.getMajorLight(context);
    final minorLight = AppTheme.getMinorLight(context);
    final isDark = AppTheme.isDark(context);

    final scaleBg = isMajor ? majorLight : minorLight;
    final scaleText = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
    final scaleBorder = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: scaffoldBg,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Circle of Fifths",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Circle Widget - Hero Section
                const SizedBox(height: 8),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
                    child: const InteractiveCircle(),
                  ),
                ),

                const SizedBox(height: 24),

                // Current Key Card - Redesigned
                _ModernKeyCard(pack: pack, state: state, ref: ref),

                // Minor Type Selector
                if (!isMajor)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _ModernMinorTypeSelector(
                      current: state.minorType,
                      onChanged: (t) => ref.read(circleProvider.notifier).setMinorType(t),
                    ),
                  ),

                const SizedBox(height: 28),

                // Scale Notes Section
                _SectionHeader(
                  title: "Scale Notes",
                  subtitle: "Tap to visualize on instruments",
                ),
                const SizedBox(height: 12),

                _ScaleNotesRow(
                  pack: pack,
                  state: state,
                  isMajor: isMajor,
                  scaleBg: scaleBg,
                  scaleText: scaleText,
                  scaleBorder: scaleBorder,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 28),

                // Chords Section
                _SectionHeader(
                  title: "Diatonic Chords",
                  subtitle: pack.keyLabel,
                ),
                const SizedBox(height: 12),

                // Chord Grid
                _ChordGrid(pack: pack, cardBg: cardBg),

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
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.getMajorLight(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.tonicBlue,
              ),
            ),
          ),
      ],
    );
  }
}

class _ModernKeyCard extends StatelessWidget {
  final TriadPack pack;
  final CircleState state;
  final WidgetRef ref;

  const _ModernKeyCard({required this.pack, required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isMajor = state.view == KeyView.values[0];
    final root = state.selectedMajorRoot;
    final relMinor = TheoryEngine.kRelativeMinors[root] ?? '?';

    final activeColor = isMajor ? AppTheme.tonicBlue : AppTheme.minorAmber;
    final activeBg = isMajor ? AppTheme.getMajorLight(context) : AppTheme.getMinorLight(context);

    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.getShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Key Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: activeBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: activeColor.withOpacity(0.2)),
                ),
                child: Text(
                  pack.keyLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Spacer(),
              // Key Signature Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  TheoryEngine.getKeySignatureDisplay(root),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Toggle + Relative Key Row
          Row(
            children: [
              // Major/Minor Toggle
              Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToggleButton(
                      label: "Major",
                      isActive: isMajor,
                      activeColor: AppTheme.tonicBlue,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(circleProvider.notifier).setView(KeyView.values[0]);
                      },
                    ),
                    _ToggleButton(
                      label: "Minor",
                      isActive: !isMajor,
                      activeColor: AppTheme.minorAmber,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(circleProvider.notifier).setView(KeyView.values[1]);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Relative Key
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isMajor ? "Relative Minor" : "Relative Major",
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMajor ? "${relMinor}m" : root,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
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

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppTheme.getTextSecondary(context);
    final cardBg = AppTheme.getCardBg(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: AppTheme.curveEaseOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: isActive ? AppTheme.shadowSm : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? activeColor : textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ModernMinorTypeSelector extends StatelessWidget {
  final MinorType current;
  final ValueChanged<MinorType> onChanged;

  const _ModernMinorTypeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final minorLight = AppTheme.getMinorLight(context);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scaffoldBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: MinorType.values.map((type) {
          final isActive = type == current;
          final label = type.name[0].toUpperCase() + type.name.substring(1);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(type);
              },
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                curve: AppTheme.curveEaseOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? cardBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: isActive ? AppTheme.shadowSm : [],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppTheme.minorAmber : textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScaleNotesRow extends StatelessWidget {
  final TriadPack pack;
  final CircleState state;
  final bool isMajor;
  final Color scaleBg;
  final Color scaleText;
  final Color scaleBorder;
  final Color cardBg;

  const _ScaleNotesRow({
    required this.pack,
    required this.state,
    required this.isMajor,
    required this.scaleBg,
    required this.scaleText,
    required this.scaleBorder,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
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
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isRoot ? scaleText : scaleBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: scaleBorder.withOpacity(isRoot ? 1.0 : 0.15),
                    width: isRoot ? 2 : 1,
                  ),
                  boxShadow: isRoot ? AppTheme.shadowGlow(scaleText) : [],
                ),
                child: Text(
                  note,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isRoot ? Colors.white : scaleText,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChordGrid extends StatelessWidget {
  final TriadPack pack;
  final Color cardBg;

  const _ChordGrid({required this.pack, required this.cardBg});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(pack.chordNames.length, (i) {
            final chordName = pack.chordNames[i];
            final chordNotes = pack.notes[i];

            return ChordCardGrid(
              width: itemWidth,
              name: chordName,
              notes: chordNotes,
              roman: pack.roman[i],
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
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
    );
  }
}
