import 'package:flutter/material.dart';
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
  String toKey = "C";

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
    final text = _controller.text;
    
    // If text is empty, just set mode for next typed character
    if (text.isEmpty) {
      setState(() {
        _mode = (_mode == newMode) ? AccidentalMode.none : newMode;
      });
      _focusNode.requestFocus();
      return;
    }
    
    // Get the accidental character
    final accChar = newMode == AccidentalMode.flat ? 'b' : '#';
    
    // Find the last note letter in the text (accounting for spaces between chords)
    int lastNoteIndex = -1;
    for (int i = text.length - 1; i >= 0; i--) {
      if (RegExp(r'[a-gA-G]').hasMatch(text[i])) {
        lastNoteIndex = i;
        break;
      }
    }
    
    if (lastNoteIndex >= 0) {
      // Check if there's already an accidental after this note
      final afterNoteIndex = lastNoteIndex + 1;
      if (afterNoteIndex < text.length) {
        final charAfterNote = text[afterNoteIndex];
        if (charAfterNote == '#' || charAfterNote == 'b' || charAfterNote == '♯' || charAfterNote == '♭') {
          // Replace existing accidental
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
      
      // Insert accidental after the last note letter
      final insertAt = lastNoteIndex + 1;
      final newText = text.substring(0, insertAt) + accChar + text.substring(insertAt);
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: insertAt + 1)),
      );
      _prevLength = newText.length;
      setState(() => _mode = AccidentalMode.none);
    } else {
      // No note found, just toggle mode
      setState(() {
        _mode = (_mode == newMode) ? AccidentalMode.none : newMode;
      });
    }
    _focusNode.requestFocus();
  }
  
  void _insertAccidental(String accChar) {
    final text = _controller.text;
    final selection = _controller.selection;
    
    // Find insertion point
    int insertAt = text.length; // default to end
    if (selection.isValid && selection.baseOffset >= 0) {
      insertAt = selection.baseOffset;
    }
    
    // Check if we should replace an existing accidental
    if (insertAt > 0) {
      final charBefore = text.substring(insertAt - 1, insertAt);
      // If char before is already an accidental, replace it
      if (charBefore == '#' || charBefore == 'b' || charBefore == '♯' || charBefore == '♭') {
        final newText = text.replaceRange(insertAt - 1, insertAt, accChar);
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(TextPosition(offset: insertAt)),
        );
        _prevLength = newText.length;
        setState(() => _mode = AccidentalMode.none);
        return;
      }
    }
    
    // Insert at cursor position
    final newText = text.substring(0, insertAt) + accChar + text.substring(insertAt);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.fromPosition(TextPosition(offset: insertAt + 1)),
    );
    _prevLength = newText.length;
    
    // Reset mode after insertion
    setState(() => _mode = AccidentalMode.none);
  }

  void _swapKeys() {
    setState(() {
      final temp = fromKey;
      fromKey = toKey;
      toKey = temp;
    });
  }

  void _onTextChanged() {
    final val = _controller.text;

    // If user is deleting, reset mode
    if (val.length < _prevLength) {
      _mode = AccidentalMode.none;
    }
    _prevLength = val.length;

    if (val.isEmpty) {
      setState(() {});
      return;
    }

    final lastChar = val[val.length - 1];

    // Detect "start of chord token"
    bool isStartOfChord = false;
    if (val.length == 1) {
      isStartOfChord = true;
    } else {
      final charBefore = val[val.length - 2];
      if (charBefore == ' ' || charBefore == '/') isStartOfChord = true;
    }

    if (isStartOfChord && RegExp(r'[a-gA-G]').hasMatch(lastChar)) {
      // If we are in Flat Mode, and the user typed 'b' as the note B,
      // do not auto-append a flat. (keeps B working naturally)
      if (_mode == AccidentalMode.flat && (lastChar == 'b' || lastChar == 'B')) {
        // Do nothing.
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

    // Theme-aware colors
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final inputFillColor = AppTheme.getInputFillColor(context);
    final majorLight = AppTheme.getMajorLight(context);
    final isDark = AppTheme.isDark(context);

    // Keys list (strict spellings handled by TheoryEngine; this UI list is just options)
    const keys = <String>[
      "C", "G", "D", "A", "E", "B", "F#", "C#",
      "F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb",
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: Text(
          "Transposer",
          style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: ListView(
            children: [
              // Intro Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cardBg,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transpose chords to a new key.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Key selectors with SWAP BUTTON
                    Row(
                      children: [
                        // FROM KEY
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: inputFillColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: fromKey,
                                dropdownColor: cardBg,
                                style: TextStyle(color: textPrimary, fontSize: 16),
                                icon: Icon(Icons.arrow_drop_down, color: textSecondary),
                                items: keys
                                    .map((k) => DropdownMenuItem(
                                          value: k,
                                          child: Text(k),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => fromKey = v!),
                              ),
                            ),
                          ),
                        ),
                        
                        // SWAP BUTTON
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            onPressed: _swapKeys,
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: 'Swap keys',
                            style: IconButton.styleFrom(
                              // Dark mode: bright blue button with white icon
                              // Light mode: subtle blue background with blue icon
                              backgroundColor: isDark ? AppTheme.tonicBlue : majorLight,
                              foregroundColor: isDark ? Colors.white : AppTheme.tonicBlue,
                            ),
                          ),
                        ),
                        
                        // TO KEY
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: inputFillColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: toKey,
                                dropdownColor: cardBg,
                                style: TextStyle(color: textPrimary, fontSize: 16),
                                icon: Icon(Icons.arrow_drop_down, color: textSecondary),
                                items: keys
                                    .map((k) => DropdownMenuItem(
                                          value: k,
                                          child: Text(k),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => toKey = v!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Accidental buttons
                    Row(
                      children: [
                        AccidentalButton(
                          label: '♭',
                          isActive: _mode == AccidentalMode.flat,
                          onTap: () => _setAccidentalMode(AccidentalMode.flat),
                        ),
                        const SizedBox(width: 10),
                        AccidentalButton(
                          label: '♯',
                          isActive: _mode == AccidentalMode.sharp,
                          onTap: () => _setAccidentalMode(AccidentalMode.sharp),
                        ),
                        const Spacer(),
                        if (_controller.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _mode = AccidentalMode.none;
                                _prevLength = 0;
                              });
                            },
                            child: const Text("Clear"),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Type chords (e.g. C G Am F)...",
                          hintStyle: TextStyle(
                            color: textSecondary.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.tonicBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_controller.text.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  "RESULT",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                Builder(
                  builder: (context) {
                    final results = TheoryEngine.transposeProgression(
                      _controller.text,
                      fromKey,
                      toKey,
                      repo,
                    );

                    return Column(
                      children: results.asMap().entries.map<Widget>((entry) {
                        final idx = entry.key;
                        final t = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
