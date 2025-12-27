import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          _performSearch(newText);
          _updateSuggestions(newText);
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
      _performSearch(newText);
      _updateSuggestions(newText);
      setState(() => _mode = AccidentalMode.none);
    } else {
      setState(() {
        _mode = (_mode == newMode) ? AccidentalMode.none : newMode;
      });
    }
    _focusNode.requestFocus();
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

    if (hasFlat && (val == "b" || val == "B")) {
      hasFlat = false;
    }

    if (hasSharp && _mode != AccidentalMode.sharp) {
      setState(() => _mode = AccidentalMode.sharp);
    } else if (hasFlat && _mode != AccidentalMode.flat) {
      setState(() => _mode = AccidentalMode.flat);
    }

    _performSearch(val);
  }

  void _selectSuggestion(SearchSuggestion suggestion) {
    HapticFeedback.selectionClick();
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

    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final isDark = AppTheme.isDark(context);

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: scaffoldBg,
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          setState(() => _showSuggestions = false);
        },
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with Search
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: scaffoldBg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chord Finder",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Search from 5000+ chord voicings",
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

            // Search Bar Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Input Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              boxShadow: AppTheme.getShadow(context),
                            ),
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: "e.g. Cm7, G#, Bbmaj7...",
                                hintStyle: TextStyle(
                                  color: textSecondary.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: textSecondary,
                                ),
                                suffixIcon: _controller.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.close_rounded, color: textSecondary, size: 20),
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
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
                                fillColor: cardBg,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  borderSide: const BorderSide(color: AppTheme.tonicBlue, width: 2),
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
                          maxHeight: keyboardVisible ? 150 : 280,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: borderColor),
                          boxShadow: AppTheme.getShadow(context, size: 'lg'),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              final isLast = index == _suggestions.length - 1;

                              return InkWell(
                                onTap: () => _selectSuggestion(suggestion),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: isLast ? null : Border(
                                      bottom: BorderSide(color: borderColor.withOpacity(0.5)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 60),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.getMajorLight(context),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                        ),
                                        child: Text(
                                          suggestion.text,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.tonicBlue,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          suggestion.hint,
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.north_west_rounded,
                                        size: 14,
                                        color: textSecondary.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Results or Empty State
            if (results.isEmpty && _query.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptySearchState(keyboardVisible: keyboardVisible),
              )
            else if (results.isEmpty && _query.isNotEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _NoResultsState(query: _query),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: keyboardVisible ? 16 : 32,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chord = results[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ChordResultCard(chord: chord),
                      );
                    },
                    childCount: results.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChordResultCard extends StatelessWidget {
  final ChordDefinition chord;

  const _ChordResultCard({required this.chord});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    final name = chord.displayName.toLowerCase();
    final bool isDim = name.contains('dim') || name.contains('°');
    final bool isAug = name.contains('aug') || name.contains('+');
    final bool isMinor = !isDim && !isAug && (name.contains('m') && !name.contains('maj'));
    final bool isMajor = !isDim && !isMinor && !isAug;

    Color badgeBg;
    Color badgeText;

    if (isDim) {
      badgeBg = AppTheme.isDark(context) ? const Color(0xFF4A1515) : const Color(0xFFFFEBEE);
      badgeText = AppTheme.accentRed;
    } else if (isAug) {
      badgeBg = AppTheme.isDark(context) ? const Color(0xFF2D1B4E) : const Color(0xFFF3E8FF);
      badgeText = AppTheme.accentPurple;
    } else if (isMajor) {
      badgeBg = AppTheme.getMajorLight(context);
      badgeText = AppTheme.tonicBlue;
    } else {
      badgeBg = AppTheme.getMinorLight(context);
      badgeText = AppTheme.minorAmber;
    }

    String root = chord.displayName.isNotEmpty ? chord.displayName[0] : 'C';
    if (chord.displayName.length > 1 &&
        (chord.displayName[1] == '#' || chord.displayName[1] == 'b' ||
         chord.displayName[1] == '♯' || chord.displayName[1] == '♭')) {
      root = chord.displayName.substring(0, 2);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor),
          boxShadow: AppTheme.getShadow(context, size: 'sm'),
        ),
        child: Row(
          children: [
            // Chord Name Badge
            Container(
              constraints: const BoxConstraints(minWidth: 70),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                chord.displayName,
                style: TextStyle(
                  color: badgeText,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 14),

            // Notes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chord.notes.join(' • '),
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${chord.notes.length} notes",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.getScaffoldBg(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: textSecondary,
              ),
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
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: keyboardVisible ? 16 : 32,
      ),
      child: Column(
        mainAxisAlignment: keyboardVisible ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          if (!keyboardVisible) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    majorLight,
                    AppTheme.tonicBlue.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 36,
                color: AppTheme.tonicBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Find any chord",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Search by symbol, name, or notes",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Quick Tips
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick tips",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _SearchTip(icon: Icons.music_note, example: 'Cm7', description: 'Standard symbols'),
                const SizedBox(height: 12),
                _SearchTip(icon: Icons.tag, example: 'gsh → G#', description: 'Type "sh" for sharp'),
                const SizedBox(height: 12),
                _SearchTip(icon: Icons.tag, example: 'bfl → Bb', description: 'Type "fl" for flat'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTip extends StatelessWidget {
  final IconData icon;
  final String example;
  final String description;

  const _SearchTip({required this.icon, required this.example, required this.description});

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scaffoldBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 16, color: AppTheme.tonicBlue),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.getMajorLight(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;

  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppTheme.getTextSecondary(context);
    final borderColor = AppTheme.getBorderColor(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 28,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No results for "$query"',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different spelling or use the ♯/♭ buttons',
            style: TextStyle(
              fontSize: 13,
              color: textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
