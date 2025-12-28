import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/note_utils.dart';
import '../../logic/providers.dart';
import 'guitar_fretboard.dart';
import 'piano_keyboard.dart';
import 'fretboard_overview.dart';

/// Premium interactive instrument sheet with elegant design.
/// Provides a polished interface for visualizing chords and scales
/// on guitar fretboard and piano keyboard.
class InteractiveFretboardSheet extends ConsumerStatefulWidget {
  final String? chordName;
  final String? title;
  final List<String>? tones;
  final List<String>? chordNotes;
  final String root;
  final bool? isScale;
  final bool defaultToPiano;

  const InteractiveFretboardSheet({
    super.key,
    this.chordName,
    this.title,
    this.tones,
    this.chordNotes,
    required this.root,
    this.isScale,
    this.defaultToPiano = false,
  });

  @override
  ConsumerState<InteractiveFretboardSheet> createState() => _InteractiveFretboardSheetState();
}

class _InteractiveFretboardSheetState extends ConsumerState<InteractiveFretboardSheet> {
  int _selectedInstrument = 0; // 0 = Guitar, 1 = Piano
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedInstrument = widget.defaultToPiano ? 1 : 0;
    _scrollController = ScrollController();

    // Default scroll position based on left-handed setting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _selectedInstrument == 0) {
        final settings = ref.read(appSettingsProvider);
        // If left-handed (headstock on right), scroll to far right (open position)
        if (settings.isLeftHanded) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> get _safeTones => widget.tones ?? widget.chordNotes ?? [];

  @override
  Widget build(BuildContext context) {
    // Read settings from provider
    final settings = ref.watch(appSettingsProvider);
    final isLeftHanded = settings.isLeftHanded;
    final octaves = settings.defaultOctaves;
    final showIntervalLabels = settings.showIntervalLabels;

    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final isDark = AppTheme.isDark(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[350],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHeader(context, cardBg, scaffoldBg, textPrimary, textSecondary, isDark),
          ),
          const SizedBox(height: 16),

          // DYNAMIC LEGEND (Only shows present intervals)
          if (_safeTones.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDynamicLegend(textSecondary, isDark),
            ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: borderColor.withOpacity(0.5)),
          ),

          // Instrument View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _selectedInstrument == 0
                  ? _buildGuitarLayout(textSecondary, isDark, isLeftHanded, showIntervalLabels)
                  : _buildPianoLayout(context, isDark, octaves, showIntervalLabels),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color cardBg, Color scaffoldBg, Color textPrimary, Color textSecondary, bool isDark) {
    return Row(
      children: [
        // Chord name column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.chordName ?? widget.title ?? "Selection",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (widget.root.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.tonicBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${widget.root} Root",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Toggle buttons
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: scaffoldBg,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleBtn("Guitar", 0, cardBg, textPrimary, textSecondary, isDark),
              _buildToggleBtn("Piano", 1, cardBg, textPrimary, textSecondary, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleBtn(String label, int index, Color cardBg, Color textPrimary, Color textSecondary, bool isDark) {
    final bool isActive = _selectedInstrument == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedInstrument = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
            color: isActive ? textPrimary : textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicLegend(Color textSecondary, bool isDark) {
    final rootPc = NoteUtils.pitchClass(widget.root);
    final Set<int> presentIntervals = {};

    for (var tone in _safeTones) {
      int pc = NoteUtils.pitchClass(tone);
      if (pc != -1) {
        int interval = (pc - rootPc + 12) % 12;
        presentIntervals.add(interval);
      }
    }

    final allIntervals = List.generate(12, (i) => {
      'val': i,
      'label': AppTheme.getIntervalLabel(i),
      'color': AppTheme.getIntervalColor(i),
    });

    final activeItems = allIntervals.where((i) => presentIntervals.contains(i['val'])).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: activeItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _PremiumLegendItem(
                color: item['color'] as Color,
                label: item['label'] as String,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGuitarLayout(Color textSecondary, bool isDark, bool isLeftHanded, bool showIntervalLabels) {
    final double screenWidth = MediaQuery.of(context).size.width - 40;
    final double fretWidth = screenWidth / 5.0;
    final double contentWidth = fretWidth * 12;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GuitarFretboard(
                tones: _safeTones,
                root: widget.root,
                octaves: 2,
                leftHanded: isLeftHanded,
                scrollController: _scrollController,
                fretWidth: fretWidth,
                totalFrets: 12,
                showIntervalLabels: showIntervalLabels,
              ),
            ),
          ),
        ),

        // Navigation hint and overview
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.swipe,
              size: 14,
              color: textSecondary.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              "Slide to navigate",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FretboardOverview(
          tones: _safeTones,
          root: widget.root,
          octaves: 2,
          leftHanded: isLeftHanded,
          viewportWidth: screenWidth,
          contentWidth: contentWidth,
          scrollController: _scrollController,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPianoLayout(BuildContext context, bool isDark, int octaves, bool showIntervalLabels) {
    return Center(
      child: PianoKeyboard(
        tones: _safeTones,
        root: widget.root,
        octaves: octaves,
        startPc: 0, // Always start from C for correct piano layout
        isDark: isDark,
        showIntervalLabels: showIntervalLabels,
      ),
    );
  }
}

/// Premium styled legend item with subtle effects.
class _PremiumLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color textSecondary;
  final bool isDark;

  const _PremiumLegendItem({
    required this.color,
    required this.label,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.lerp(color, Colors.white, 0.25)!,
                color,
              ],
              center: const Alignment(-0.3, -0.3),
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
