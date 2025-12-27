import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../logic/providers.dart';
import '../../logic/theory_engine.dart';
import '../components/chord_card.dart';
import '../components/accidental_button.dart';

enum AccidentalMode { none, flat, sharp }

class TransposerScreen extends ConsumerStatefulWidget {
  const TransposerScreen({super.key});

  @override
  ConsumerState<TransposerScreen> createState() => _TransposerScreenState();
}

class _TransposerScreenState extends ConsumerState<TransposerScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  AccidentalMode _mode = AccidentalMode.none;
  int _prevLength = 0;

  String fromKey = "C";
  String toKey = "G";

  @override
  void initState() {
    super.initState();
    _prevLength = _controller.text.length;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setAccidentalMode(AccidentalMode newMode) {
    HapticFeedback.selectionClick();
    final text = _controller.text;

    if (text.isEmpty) {
      setState(() {
        _mode = (_mode == newMode) ? AccidentalMode.none : newMode;
      });
      _focusNode.requestFocus();
      return;
    }

    final accChar = newMode == AccidentalMode.flat ? 'b' : '#';

    int lastNoteIndex = -1;
    for (int i = text.length - 1; i >= 0; i--) {
      if (RegExp(r'[a-gA-G]').hasMatch(text[i])) {
        lastNoteIndex = i;
        break;
      }
    }

    if (lastNoteIndex >= 0) {
      final afterNoteIndex = lastNoteIndex + 1;
      if (afterNoteIndex < text.length) {
        final charAfterNote = text[afterNoteIndex];
        if (charAfterNote == '#' || charAfterNote == 'b' || charAfterNote == '♯' || charAfterNote == '♭') {
          final newText = text.replaceRange(afterNoteIndex, afterNoteIndex + 1, accChar);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.fromPosition(TextPosition(offset: afterNoteIndex + 1)),
          );
          _prevLength = newText.length;
          setState(() => _mode = AccidentalMode.none);
          _focusNode.requestFocus();
          return;
        }
      }

      final insertAt = lastNoteIndex + 1;
      final newText = text.substring(0, insertAt) + accChar + text.substring(insertAt);
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: insertAt + 1)),
      );
      _prevLength = newText.length;
      setState(() => _mode = AccidentalMode.none);
    } else {
      setState(() {
        _mode = (_mode == newMode) ? AccidentalMode.none : newMode;
      });
    }
    _focusNode.requestFocus();
  }

  void _swapKeys() {
    HapticFeedback.lightImpact();
    setState(() {
      final temp = fromKey;
      fromKey = toKey;
      toKey = temp;
    });
  }

  void _onTextChanged() {
    final val = _controller.text;

    if (val.length < _prevLength) {
      _mode = AccidentalMode.none;
    }
    _prevLength = val.length;

    if (val.isEmpty) {
      setState(() {});
      return;
    }

    final lastChar = val[val.length - 1];

    bool isStartOfChord = false;
    if (val.length == 1) {
      isStartOfChord = true;
    } else {
      final charBefore = val[val.length - 2];
      if (charBefore == ' ' || charBefore == '/') isStartOfChord = true;
    }

    if (isStartOfChord && RegExp(r'[a-gA-G]').hasMatch(lastChar)) {
      if (_mode == AccidentalMode.flat && (lastChar == 'b' || lastChar == 'B')) {
        // Do nothing
      } else if (_mode == AccidentalMode.flat || _mode == AccidentalMode.sharp) {
        final accChar = (_mode == AccidentalMode.flat) ? 'b' : '#';
        final newText = val + accChar;

        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
        );

        _prevLength = newText.length;
        _mode = AccidentalMode.none;
        setState(() {});
        return;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);

    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);

    const keys = <String>[
      "C", "G", "D", "A", "E", "B", "F#", "C#",
      "F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb",
    ];

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
                      "Transposer",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Convert chord progressions between keys",
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
                // Key Selector Card
                Container(
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
                      // Key Selectors Row
                      Row(
                        children: [
                          // From Key
                          Expanded(
                            child: _KeySelector(
                              label: "From",
                              value: fromKey,
                              keys: keys,
                              onChanged: (v) => setState(() => fromKey = v!),
                            ),
                          ),

                          // Swap Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: GestureDetector(
                              onTap: _swapKeys,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: majorLight,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: AppTheme.tonicBlue,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),

                          // To Key
                          Expanded(
                            child: _KeySelector(
                              label: "To",
                              value: toKey,
                              keys: keys,
                              onChanged: (v) => setState(() => toKey = v!),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Container(
                        height: 1,
                        color: borderColor,
                      ),

                      const SizedBox(height: 20),

                      // Input Section
                      Row(
                        children: [
                          Text(
                            "Chord Progression",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const Spacer(),
                          AccidentalButton(
                            label: '♭',
                            isActive: _mode == AccidentalMode.flat,
                            onTap: () => _setAccidentalMode(AccidentalMode.flat),
                          ),
                          const SizedBox(width: 8),
                          AccidentalButton(
                            label: '♯',
                            isActive: _mode == AccidentalMode.sharp,
                            onTap: () => _setAccidentalMode(AccidentalMode.sharp),
                          ),
                          if (_controller.text.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _controller.clear();
                                setState(() {
                                  _mode = AccidentalMode.none;
                                  _prevLength = 0;
                                });
                              },
                              child: Text(
                                "Clear",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.tonicBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Text Input
                      Container(
                        decoration: BoxDecoration(
                          color: scaffoldBg,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "e.g. C G Am F",
                            hintStyle: TextStyle(
                              color: textSecondary.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Results Section
                if (_controller.text.isNotEmpty) ...[
                  const SizedBox(height: 28),

                  // Section Header
                  Row(
                    children: [
                      Text(
                        "Transposed Result",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: majorLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          "$fromKey → $toKey",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tonicBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Result Cards
                  Builder(
                    builder: (context) {
                      final results = TheoryEngine.transposeProgression(
                        _controller.text,
                        fromKey,
                        toKey,
                        repo,
                      );

                      if (results.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              "Enter chords separated by spaces",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: results.asMap().entries.map<Widget>((entry) {
                          final idx = entry.key;
                          final t = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ChordCard(
                              name: t.name,
                              notes: t.notes,
                              badge: "${idx + 1}",
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ] else ...[
                  // Empty State
                  const SizedBox(height: 40),
                  _EmptyState(),
                ],

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeySelector extends StatelessWidget {
  final String label;
  final String value;
  final List<String> keys;
  final ValueChanged<String?> onChanged;

  const _KeySelector({
    required this.label,
    required this.value,
    required this.keys,
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              items: keys.map((k) => DropdownMenuItem(
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: majorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              size: 32,
              color: AppTheme.tonicBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Enter a chord progression",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Separate chords with spaces\ne.g. C G Am F",
            style: TextStyle(
              fontSize: 14,
              color: textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
