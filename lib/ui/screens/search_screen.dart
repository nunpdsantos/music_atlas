import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../logic/providers.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../components/accidental_button.dart';
import '../components/interactive_fretboard_sheet.dart';

enum AccidentalMode { none, flat, sharp }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = "";
  AccidentalMode _mode = AccidentalMode.none;
  int _prevLength = 0;
  Timer? _debounceTimer;
  bool _showSuggestions = false;
  List<SearchSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
      setState(() => _showSuggestions = true);
    }
  }

  void _toggleMode(AccidentalMode newMode) {
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
    
    // Find the last note letter in the text
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
          _performSearch(newText);
          _updateSuggestions(newText);
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
      _performSearch(newText);
      _updateSuggestions(newText);
      setState(() => _mode = AccidentalMode.none);
    } else {
      // No note found, just toggle mode
      setState(() {
        _mode = (_mode == newMode) ? AccidentalMode.none : newMode;
      });
    }
    _focusNode.requestFocus();
  }
  
  // Keep the old _insertAccidental for backward compatibility with onTextChanged
  void _insertAccidental(String accChar) {
    final text = _controller.text;
    final selection = _controller.selection;
    
    int insertAt = text.length;
    if (selection.isValid && selection.baseOffset >= 0) {
      insertAt = selection.baseOffset;
    }
    
    if (insertAt > 0) {
      final charBefore = text.substring(insertAt - 1, insertAt);
      if (charBefore == '#' || charBefore == 'b' || charBefore == '♯' || charBefore == '♭') {
        final newText = text.replaceRange(insertAt - 1, insertAt, accChar);
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(TextPosition(offset: insertAt)),
        );
        _prevLength = newText.length;
        _performSearch(newText);
        _updateSuggestions(newText);
        return;
      }
    }
    
    final newText = text.substring(0, insertAt) + accChar + text.substring(insertAt);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.fromPosition(TextPosition(offset: insertAt + 1)),
    );
    _prevLength = newText.length;
    _performSearch(newText);
    _updateSuggestions(newText);
  }

  void _updateSuggestions(String value) {
    final repo = ref.read(repositoryProvider);
    setState(() {
      _suggestions = repo.getSuggestions(value, limit: 6);
      _showSuggestions = value.isNotEmpty && _suggestions.isNotEmpty;
    });
  }

  void _performSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _query = value;
          _showSuggestions = false;
        });
      }
    });
  }

  void _onTextChanged(String val) {
    final isDeleting = val.length < _prevLength;
    _prevLength = val.length;

    _updateSuggestions(val);

    if (!isDeleting && val.isNotEmpty && _mode != AccidentalMode.none) {
      final match = RegExp(r'^([a-gA-G])$').firstMatch(val);
      if (match != null) {
        final accChar = (_mode == AccidentalMode.flat) ? 'b' : '#';
        final newText = val + accChar;
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
        );
        _performSearch(newText);
        _prevLength = newText.length;
        _updateSuggestions(newText);
        return;
      }
    }

    bool hasSharp = val.contains('#') || val.contains('♯');
    bool hasFlat = val.contains('b') || val.contains('♭');

    if (hasFlat) {
      if (val == "b" || val == "B") {
        hasFlat = false;
      }
    }

    if (hasSharp) {
      if (_mode != AccidentalMode.sharp) setState(() => _mode = AccidentalMode.sharp);
    } else if (hasFlat) {
      if (_mode != AccidentalMode.flat) setState(() => _mode = AccidentalMode.flat);
    }

    _performSearch(val);
  }

  void _selectSuggestion(SearchSuggestion suggestion) {
    _controller.text = suggestion.text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.text.length),
    );
    setState(() {
      _query = suggestion.text;
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final results = _query.isEmpty ? <ChordDefinition>[] : repo.search(_query);

    // Theme-aware colors
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBgCol = AppTheme.getCardBg(context);
    final borderCol = AppTheme.getBorderColor(context);
    final textSecCol = AppTheme.getTextSecondary(context);
    final isDark = AppTheme.isDark(context);
    
    // Check if keyboard is visible
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("Chord Finder"),
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          setState(() => _showSuggestions = false);
        },
        child: Column(
          children: [
            // Search Header - Fixed at top
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              color: scaffoldBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Type a chord symbol, name, or notes",
                    style: TextStyle(color: textSecCol, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  
                  // Search Row - fixed with proper constraints
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.tonicBlue,
                          ),
                          decoration: InputDecoration(
                            hintText: "e.g. Cm7, G#, Bb...",
                            hintStyle: TextStyle(
                              color: textSecCol.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: Icon(Icons.search, color: textSecCol),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close, color: textSecCol, size: 20),
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {
                                        _query = "";
                                        _prevLength = 0;
                                        _suggestions = [];
                                        _showSuggestions = false;
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: cardBgCol,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderCol),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderCol),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.tonicBlue, width: 1.5),
                            ),
                          ),
                          onChanged: _onTextChanged,
                          onTap: () {
                            if (_controller.text.isNotEmpty) {
                              _updateSuggestions(_controller.text);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      AccidentalButton(
                        label: '♭',
                        isActive: _mode == AccidentalMode.flat,
                        onTap: () => _toggleMode(AccidentalMode.flat),
                      ),
                      const SizedBox(width: 8),
                      AccidentalButton(
                        label: '♯',
                        isActive: _mode == AccidentalMode.sharp,
                        onTap: () => _toggleMode(AccidentalMode.sharp),
                      ),
                    ],
                  ),
                  
                  // Suggestions Dropdown
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: BoxConstraints(
                        maxHeight: keyboardVisible ? 150 : 300,
                      ),
                      decoration: BoxDecoration(
                        color: cardBgCol,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          final isLast = index == _suggestions.length - 1;
                          
                          return InkWell(
                            onTap: () => _selectSuggestion(suggestion),
                            borderRadius: BorderRadius.vertical(
                              top: index == 0 ? const Radius.circular(12) : Radius.zero,
                              bottom: isLast ? const Radius.circular(12) : Radius.zero,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: isLast ? null : Border(
                                  bottom: BorderSide(color: borderCol.withOpacity(0.5)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Chord symbol - constrained width
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 80),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getMajorLight(context),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      suggestion.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.tonicBlue,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Hint text - expanded to take remaining space
                                  Expanded(
                                    child: Text(
                                      suggestion.hint,
                                      style: TextStyle(
                                        color: textSecCol.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: textSecCol,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            
            // Results - Flexible with proper keyboard handling
            Expanded(
              child: results.isEmpty
                  ? (_query.isEmpty 
                      ? _EmptySearchState(keyboardVisible: keyboardVisible)
                      : _NoResultsState(query: _query, keyboardVisible: keyboardVisible))
                  : ListView.separated(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        left: 20, 
                        right: 20, 
                        top: 10, 
                        bottom: keyboardVisible ? 10 : 20,
                      ),
                      shrinkWrap: false,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chord = results[index];
                        return _ChordResultCard(chord: chord);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline chord result card with proper overflow handling
class _ChordResultCard extends StatelessWidget {
  final ChordDefinition chord;

  const _ChordResultCard({required this.chord});

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final cardBgCol = AppTheme.getCardBg(context);
    final borderCol = AppTheme.getBorderColor(context);
    final textPrimCol = AppTheme.getTextPrimary(context);
    final textSecCol = AppTheme.getTextSecondary(context);
    final isDark = AppTheme.isDark(context);
    
    // Determine chord quality from name
    final name = chord.displayName.toLowerCase();
    final bool isDim = name.contains('dim') || name.contains('°');
    final bool isAug = name.contains('aug') || name.contains('+');
    final bool isMinor = !isDim && !isAug && (name.contains('m') && !name.contains('maj'));
    final bool isMajor = !isDim && !isMinor && !isAug;

    // Color scheme based on chord quality
    Color badgeBg;
    Color badgeText;

    if (isDim) {
      badgeBg = isDark ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = const Color(0xFFD32F2F);
    } else if (isAug) {
      badgeBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = const Color(0xFF7C3AED);
    } else if (isMajor) {
      badgeBg = AppTheme.getMajorLight(context);
      badgeText = AppTheme.tonicBlue;
    } else {
      badgeBg = AppTheme.getMinorLight(context);
      badgeText = AppTheme.minorAmber;
    }

    // Extract root for fretboard
    String root = chord.displayName.isNotEmpty ? chord.displayName[0] : 'C';
    if (chord.displayName.length > 1 && 
        (chord.displayName[1] == '#' || chord.displayName[1] == 'b' || 
         chord.displayName[1] == '♯' || chord.displayName[1] == '♭')) {
      root = chord.displayName.substring(0, 2);
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => InteractiveFretboardSheet(
            chordName: chord.displayName,
            tones: chord.notes,
            root: root,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBgCol,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol),
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
            // Chord name badge - with max width constraint
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                chord.displayName,
                style: TextStyle(
                  color: badgeText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Notes display - takes remaining space
            Expanded(
              child: Text(
                chord.notes.join(' • '),
                style: TextStyle(
                  color: textPrimCol,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Arrow indicator
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: textSecCol,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final bool keyboardVisible;
  
  const _EmptySearchState({this.keyboardVisible = false});

  @override
  Widget build(BuildContext context) {
    final cardBgCol = AppTheme.cardBackground(context);
    final borderCol = AppTheme.border(context);
    final textPrimCol = AppTheme.textPrimaryColor(context);
    final textSecCol = AppTheme.textSecondaryColor(context);
    final majorLightCol = AppTheme.majorLightColor(context);

    // Use ListView instead of Column to handle overflow gracefully
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 32, 
        vertical: keyboardVisible ? 12 : 24,
      ),
      children: [
        if (!keyboardVisible) ...[
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: majorLightCol,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note,
                size: 40,
                color: AppTheme.tonicBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            "Search for any chord",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimCol,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            "Try typing a chord symbol or partial text",
            style: TextStyle(
              fontSize: 14,
              color: textSecCol,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
        
        // Search tips - always show but more compact when keyboard is up
        Container(
          padding: EdgeInsets.all(keyboardVisible ? 12 : 16),
          decoration: BoxDecoration(
            color: cardBgCol,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SearchTip(example: 'Cm7', description: 'Standard chord symbols'),
              SizedBox(height: keyboardVisible ? 6 : 8),
              _SearchTip(example: 'gsh → G#', description: 'Type "sh" for sharp'),
              SizedBox(height: keyboardVisible ? 6 : 8),
              _SearchTip(example: 'bfl → Bb', description: 'Type "fl" for flat'),
              SizedBox(height: keyboardVisible ? 6 : 8),
              _SearchTip(example: 'Cb → B', description: 'Enharmonic equivalents'),
            ],
          ),
        ),
        if (!keyboardVisible) const SizedBox(height: 20),
      ],
    );
  }
}

class _SearchTip extends StatelessWidget {
  final String example;
  final String description;
  
  const _SearchTip({required this.example, required this.description});

  @override
  Widget build(BuildContext context) {
    final scaffoldBgCol = AppTheme.scaffoldBackground(context);
    final textSecCol = AppTheme.textSecondaryColor(context);

    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 70),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scaffoldBgCol,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            example,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.tonicBlue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: textSecCol,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  final bool keyboardVisible;
  
  const _NoResultsState({required this.query, this.keyboardVisible = false});

  @override
  Widget build(BuildContext context) {
    final textSecCol = AppTheme.textSecondaryColor(context);
    final borderCol = AppTheme.border(context);
    final isEnharmonic = _checkEnharmonic(query.toLowerCase());
    
    // Use ListView to handle overflow gracefully
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 32, 
        vertical: keyboardVisible ? 16 : 24,
      ),
      children: [
        SizedBox(height: keyboardVisible ? 20 : 40),
        Center(child: Icon(Icons.search_off, size: 48, color: borderCol)),
        const SizedBox(height: 16),
        Text(
          'No chords found for "$query"',
          style: TextStyle(
            color: textSecCol,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (isEnharmonic != null)
          Text(
            'Try searching for "$isEnharmonic" instead',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.tonicBlue,
            ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            'Try a different spelling or use ♯/♭ buttons',
            style: TextStyle(
              fontSize: 13,
              color: textSecCol.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        SizedBox(height: keyboardVisible ? 20 : 40),
      ],
    );
  }
  
  String? _checkEnharmonic(String query) {
    const enharmonics = {
      'cb': 'B', 'fb': 'E', 'b#': 'C', 'e#': 'F',
    };
    
    for (final entry in enharmonics.entries) {
      if (query.startsWith(entry.key)) {
        final quality = query.length > 2 ? query.substring(2) : '';
        return entry.value + quality;
      }
    }
    return null;
  }
}
