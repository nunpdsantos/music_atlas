import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/note_utils.dart';
import 'guitar_fretboard.dart';
import 'piano_keyboard.dart';
import 'fretboard_overview.dart'; 

class InteractiveFretboardSheet extends StatefulWidget {
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
  State<InteractiveFretboardSheet> createState() => _InteractiveFretboardSheetState();
}

class _InteractiveFretboardSheetState extends State<InteractiveFretboardSheet> {
  int _selectedInstrument = 0; // 0 = Guitar, 1 = Piano
  late ScrollController _scrollController;
  
  // Player's View: Headstock on Right
  final bool _leftHanded = true; 

  @override
  void initState() {
    super.initState();
    _selectedInstrument = widget.defaultToPiano ? 1 : 0;
    _scrollController = ScrollController();
    
    // Default scroll to the far right (Open Position) since headstock is on right
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _selectedInstrument == 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final isDark = AppTheme.isDark(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300], 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          _buildHeader(context, cardBg, scaffoldBg, textPrimary, textSecondary, isDark),
          const SizedBox(height: 16),

          // DYNAMIC LEGEND (Only shows present intervals)
          if (_safeTones.isNotEmpty)
            _buildDynamicLegend(textSecondary),

          const SizedBox(height: 16),
          Divider(height: 1, color: borderColor),
          
          // Instrument View
          Expanded(
            child: _selectedInstrument == 0 
                ? _buildGuitarLayout(textSecondary, isDark) 
                : _buildPianoLayout(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color cardBg, Color scaffoldBg, Color textPrimary, Color textSecondary, bool isDark) {
    return Row(
      children: [
        // Chord name column - constrained to prevent overflow
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.chordName ?? widget.title ?? "Selection",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (widget.root.isNotEmpty)
                Text(
                  "${widget.root} Root",
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Toggle buttons - fixed width
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: scaffoldBg, 
            borderRadius: BorderRadius.circular(20),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive 
              ? [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 4)] 
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? textPrimary : textSecondary),
        ),
      ),
    );
  }

  // --- DYNAMIC LEGEND LOGIC ---
  Widget _buildDynamicLegend(Color textSecondary) {
    final rootPc = NoteUtils.pitchClass(widget.root);
    final Set<int> presentIntervals = {};
    
    // 1. Identify which intervals exist in the tones
    for (var tone in _safeTones) {
      int pc = NoteUtils.pitchClass(tone);
      if (pc != -1) {
        int interval = (pc - rootPc + 12) % 12;
        presentIntervals.add(interval);
      }
    }

    // 2. Use centralized theme colors and labels
    final allIntervals = List.generate(12, (i) => {
      'val': i,
      'label': AppTheme.getIntervalLabel(i),
      'color': AppTheme.getIntervalColor(i),
    });

    // 3. Filter and Build UI
    final activeItems = allIntervals.where((i) => presentIntervals.contains(i['val'])).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: activeItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _LegendItem(color: item['color'] as Color, label: item['label'] as String, textSecondary: textSecondary),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGuitarLayout(Color textSecondary, bool isDark) {
    // We want exactly 5 frets visible on screen.
    // The screen width (minus padding) divided by 5 gives us the fret width.
    final double screenWidth = MediaQuery.of(context).size.width - 40; 
    final double fretWidth = screenWidth / 5.0;
    
    // We render 12 frets total (plus open strings).
    // The content width is fretWidth * 12.
    final double contentWidth = fretWidth * 12;

    return Column(
      children: [
        Expanded(
          child: GuitarFretboard(
            tones: _safeTones,
            root: widget.root,
            octaves: 2,
            leftHanded: _leftHanded,
            scrollController: _scrollController,
            fretWidth: fretWidth, // Pass the calculated width
            totalFrets: 12, // Standard classical view usually goes to 12
          ),
        ),
        
        // Overview / Scrollbar
        const SizedBox(height: 8),
        Text("Scroll Neck", style: TextStyle(fontSize: 10, color: textSecondary)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: FretboardOverview(
            tones: _safeTones,
            root: widget.root,
            octaves: 2,
            leftHanded: _leftHanded,
            viewportWidth: screenWidth,
            contentWidth: contentWidth,
            scrollController: _scrollController,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPianoLayout(BuildContext context, bool isDark) {
    // Calculate starting pitch class based on root
    // This centers the piano view around the chord/scale root
    final rootPc = NoteUtils.pitchClass(widget.root);
    
    // Start from the root's pitch class, or C if invalid
    final startPc = rootPc >= 0 ? rootPc : 0;
    
    return Center(
      child: PianoKeyboard(
        tones: _safeTones,
        root: widget.root,
        octaves: 2,
        startPc: startPc,
        isDark: isDark,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color textSecondary;

  const _LegendItem({required this.color, required this.label, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
      ],
    );
  }
}
