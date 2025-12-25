import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

class MusicRepository {
  List<ChordDefinition> _chords = [];
  final Map<String, ChordDefinition> _byAlias = {};
  final Map<String, Set<ChordDefinition>> _byPrefix = {};

  // ============================================================
  // ENHARMONIC EQUIVALENTS
  // ============================================================
  static const Map<String, String> _enharmonicMap = {
    // Theoretical flats → practical equivalents
    'cb': 'b', 'fb': 'e',
    // Theoretical sharps → practical equivalents  
    'b#': 'c', 'e#': 'f',
    // Standard enharmonics (both directions)
    'c#': 'db', 'db': 'c#',
    'd#': 'eb', 'eb': 'd#',
    'f#': 'gb', 'gb': 'f#',
    'g#': 'ab', 'ab': 'g#',
    'a#': 'bb', 'bb': 'a#',
  };

  // ============================================================
  // PREDICTIVE PATTERNS - What user might be typing
  // ============================================================
  static final Map<RegExp, String Function(Match)> _predictivePatterns = {
    // "gs", "gsh", "gsha", "gshar", "gsharp" → "g#"
    RegExp(r'^([a-g])s(h|ha|har|harp)?$'): (m) => '${m.group(1)}#',
    // "gf", "gfl", "gfla", "gflat" → "gb"  
    RegExp(r'^([a-g])f(l|la|lat)?$'): (m) => '${m.group(1)}b',
    // "g sharp" with space
    RegExp(r'^([a-g])\s*sharp$'): (m) => '${m.group(1)}#',
    // "g flat" with space
    RegExp(r'^([a-g])\s*flat$'): (m) => '${m.group(1)}b',
  };

  Future<void> initialize() async {
    String? chordsJson;
    Object? lastErr;

    for (final path in const [
      'assets/data/chords_dataset_enriched_from_split.patched.json',
      'assets/data/chords_dataset_enriched_from_split.json',
      'assets/chords_dataset_enriched_from_split.patched.json',
      'assets/chords_dataset_enriched_from_split.json',
    ]) {
      try {
        chordsJson = await rootBundle.loadString(path);
        break;
      } catch (e) {
        lastErr = e;
      }
    }

    if (chordsJson == null) {
      throw Exception('Failed to load any dataset asset. Last error: $lastErr');
    }

    final decoded = jsonDecode(chordsJson);
    if (decoded is! List) {
      throw Exception('Dataset JSON must be a List at the top level.');
    }

    _chords = decoded
        .map((e) => ChordDefinition.fromJson(e as Map<String, dynamic>))
        .toList();

    _buildIndexes();
  }

  void _buildIndexes() {
    _byAlias.clear();
    _byPrefix.clear();
    
    for (final chord in _chords) {
      // Index all standard aliases and tokens
      final keysToIndex = <String>{
        chord.displayName,
        ...chord.aliases,
        ...chord.searchTokens,
        chord.root,
      };
      
      for (final key in keysToIndex) {
        _indexAlias(chord, key);
        _indexPrefixes(chord, key);
      }
      
      // Index enharmonic equivalents
      _indexEnharmonics(chord);
    }
  }

  void _indexAlias(ChordDefinition chord, String alias) {
    final key = _normalize(alias);
    if (key.isEmpty) return;
    _byAlias[key] = chord;
  }

  void _indexPrefixes(ChordDefinition chord, String alias) {
    final key = _normalize(alias);
    if (key.isEmpty) return;
    
    // Index all prefixes for incremental/predictive search
    for (int i = 1; i <= key.length; i++) {
      final prefix = key.substring(0, i);
      _byPrefix.putIfAbsent(prefix, () => <ChordDefinition>{}).add(chord);
    }
  }

  void _indexEnharmonics(ChordDefinition chord) {
    final rootLower = chord.root.toLowerCase();
    final displayLower = chord.displayName.toLowerCase();
    final quality = displayLower.length > rootLower.length 
        ? displayLower.substring(rootLower.length) 
        : '';
    
    // Get enharmonic equivalent of the root
    final enharmonicRoot = _enharmonicMap[rootLower];
    if (enharmonicRoot != null) {
      final enharmonicKey = enharmonicRoot + quality;
      _byAlias[enharmonicKey] = chord;
      _indexPrefixes(chord, enharmonicKey);
    }
    
    // Also index reverse lookups (e.g., searching "cb" finds "b" chords)
    for (final entry in _enharmonicMap.entries) {
      if (entry.value == rootLower) {
        final reverseKey = entry.key + quality;
        _byAlias[reverseKey] = chord;
        _indexPrefixes(chord, reverseKey);
      }
    }
  }

  String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('♯', '#')
        .replaceAll('♭', 'b')
        .replaceAll(RegExp(r'\s+'), '');
  }

  /// Apply predictive patterns to convert partial typing to chord symbols
  String _applyPredictivePatterns(String input) {
    var result = _normalize(input);
    
    // Try each predictive pattern
    for (final entry in _predictivePatterns.entries) {
      final match = entry.key.firstMatch(result);
      if (match != null) {
        result = entry.value(match);
        break;
      }
    }
    
    // Also handle word replacements
    result = result
        .replaceAll('sharp', '#')
        .replaceAll('flat', 'b')
        .replaceAll('major', 'maj')
        .replaceAll('minor', 'min')
        .replaceAll('diminished', 'dim')
        .replaceAll('augmented', 'aug');
    
    return result;
  }

  // ============================================================
  // PUBLIC API
  // ============================================================

  List<ChordDefinition> getAll() => _chords;

  ChordDefinition? findByAlias(String query) {
    final key = _normalize(query);
    return _byAlias[key];
  }

  ChordDefinition? findByName(String name) {
    // Try exact match first
    final exact = findByAlias(name);
    if (exact != null) return exact;

    // Try with predictive patterns
    final predicted = _applyPredictivePatterns(name);
    if (predicted != name) {
      final predictedMatch = _byAlias[predicted];
      if (predictedMatch != null) return predictedMatch;
    }

    // Try enharmonic equivalent
    final enharmonicMatch = _findEnharmonicMatch(name);
    if (enharmonicMatch != null) return enharmonicMatch;

    return null;
  }

  /// Smart search with predictive matching, enharmonic awareness, and incremental refinement
  List<ChordDefinition> search(String query, {int limit = 50}) {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final results = <ChordDefinition>[];
    final seen = <String>{};
    
    // Get normalized and predicted versions
    final normalized = _normalize(q);
    final predicted = _applyPredictivePatterns(q);
    
    // 1. Exact matches (highest priority)
    _addIfNotSeen(results, seen, _byAlias[normalized], limit);
    _addIfNotSeen(results, seen, _byAlias[predicted], limit);
    
    // 2. Enharmonic matches
    final enharmonicKeys = _getEnharmonicQueries(normalized);
    for (final key in enharmonicKeys) {
      _addIfNotSeen(results, seen, _byAlias[key], limit);
      if (results.length >= limit) return _sortByRelevance(results, normalized);
    }
    
    // 3. Prefix matches (for incremental typing)
    _addPrefixMatches(results, seen, normalized, limit);
    _addPrefixMatches(results, seen, predicted, limit);
    
    // 4. Try all query expansions
    final expansions = _expandQuery(normalized);
    for (final expansion in expansions) {
      _addIfNotSeen(results, seen, _byAlias[expansion], limit);
      _addPrefixMatches(results, seen, expansion, limit);
      if (results.length >= limit) break;
    }
    
    // 5. Fuzzy/contains search as fallback
    if (results.length < limit) {
      _addContainsMatches(results, seen, normalized, limit);
    }
    
    return _sortByRelevance(results, normalized);
  }

  void _addIfNotSeen(List<ChordDefinition> results, Set<String> seen, ChordDefinition? chord, int limit) {
    if (chord != null && !seen.contains(chord.id) && results.length < limit) {
      results.add(chord);
      seen.add(chord.id);
    }
  }

  void _addPrefixMatches(List<ChordDefinition> results, Set<String> seen, String prefix, int limit) {
    final matches = _byPrefix[prefix];
    if (matches != null) {
      for (final chord in matches) {
        if (results.length >= limit) break;
        if (!seen.contains(chord.id)) {
          results.add(chord);
          seen.add(chord.id);
        }
      }
    }
  }

  void _addContainsMatches(List<ChordDefinition> results, Set<String> seen, String query, int limit) {
    for (final chord in _chords) {
      if (results.length >= limit) break;
      if (seen.contains(chord.id)) continue;
      
      final displayNorm = _normalize(chord.displayName);
      if (displayNorm.contains(query)) {
        results.add(chord);
        seen.add(chord.id);
        continue;
      }
      
      for (final token in chord.searchTokens) {
        if (_normalize(token).contains(query)) {
          results.add(chord);
          seen.add(chord.id);
          break;
        }
      }
    }
  }

  ChordDefinition? _findEnharmonicMatch(String query) {
    final enharmonicKeys = _getEnharmonicQueries(_normalize(query));
    for (final key in enharmonicKeys) {
      final match = _byAlias[key];
      if (match != null) return match;
    }
    return null;
  }

  /// Get all enharmonic query variations
  List<String> _getEnharmonicQueries(String query) {
    final results = <String>[];
    if (query.isEmpty) return results;
    
    // Extract root (1-2 characters)
    String root;
    String quality;
    
    if (query.length >= 2 && (query[1] == '#' || query[1] == 'b')) {
      root = query.substring(0, 2);
      quality = query.substring(2);
    } else if (query.isNotEmpty) {
      root = query.substring(0, 1);
      quality = query.substring(1);
    } else {
      return results;
    }
    
    // Find enharmonic equivalent
    final enharmonic = _enharmonicMap[root];
    if (enharmonic != null) {
      results.add(enharmonic + quality);
    }
    
    // Also check reverse mappings
    for (final entry in _enharmonicMap.entries) {
      if (entry.value == root) {
        results.add(entry.key + quality);
      }
    }
    
    return results;
  }

  /// Generate query expansions for fuzzy matching
  List<String> _expandQuery(String query) {
    final expansions = <String>[];
    
    // Quality expansions
    final qualityExpansions = {
      'maj': ['major', 'M', ''],
      'min': ['minor', 'm', '-'],
      'm': ['min', 'minor', '-'],
      'dim': ['diminished', '°', 'o'],
      'aug': ['augmented', '+', '#5'],
      '7': ['dom7', 'dominant7'],
      'maj7': ['major7', 'M7', 'Δ7'],
      'min7': ['minor7', 'm7', '-7'],
    };
    
    for (final entry in qualityExpansions.entries) {
      if (query.contains(entry.key)) {
        for (final expansion in entry.value) {
          expansions.add(query.replaceFirst(entry.key, expansion));
        }
      }
    }
    
    // If single letter, add common chord types
    if (query.length == 1 && RegExp(r'[a-g]').hasMatch(query)) {
      expansions.addAll([
        '${query}maj', '${query}min', '${query}7', 
        '${query}m', '${query}m7', '${query}maj7',
        '$query#', '${query}b',
      ]);
    }
    
    // If two letters ending in 's' or 'f', predict sharp/flat
    if (query.length == 2) {
      final root = query[0];
      final second = query[1];
      if (RegExp(r'[a-g]').hasMatch(root)) {
        if (second == 's') {
          expansions.add('$root#'); // gs → g#
        } else if (second == 'f' && root != 'b') {
          // gf → gb (but not bf which is B flat)
          expansions.add('${root}b');
        }
      }
    }
    
    return expansions;
  }

  /// Sort results by relevance to the query
  List<ChordDefinition> _sortByRelevance(List<ChordDefinition> results, String query) {
    results.sort((a, b) {
      final aNorm = _normalize(a.displayName);
      final bNorm = _normalize(b.displayName);
      
      // Exact match first
      if (aNorm == query && bNorm != query) return -1;
      if (bNorm == query && aNorm != query) return 1;
      
      // Starts with query
      final aStarts = aNorm.startsWith(query);
      final bStarts = bNorm.startsWith(query);
      if (aStarts && !bStarts) return -1;
      if (bStarts && !aStarts) return 1;
      
      // Shorter (simpler) chords first
      if (aNorm.length != bNorm.length) {
        return aNorm.length.compareTo(bNorm.length);
      }
      
      // Prefer triads and common chords
      final aScore = _getChordPriorityScore(a.quality);
      final bScore = _getChordPriorityScore(b.quality);
      if (aScore != bScore) return aScore.compareTo(bScore);
      
      // Alphabetical as last resort
      return aNorm.compareTo(bNorm);
    });
    
    return results;
  }

  int _getChordPriorityScore(String quality) {
    const priorities = {
      'maj': 0, 'min': 1, '7': 2, 'm7': 3, 'maj7': 4,
      'dim': 5, 'aug': 6, 'sus4': 7, 'sus2': 8,
      '9': 9, 'm9': 10, 'maj9': 11,
    };
    return priorities[quality] ?? 20;
  }

  // ============================================================
  // SUGGESTION API (for autocomplete UI)
  // ============================================================

  /// Get intelligent suggestions based on partial input
  List<SearchSuggestion> getSuggestions(String query, {int limit = 8}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    
    final suggestions = <SearchSuggestion>[];
    final seen = <String>{};
    
    // Single letter - suggest note variations
    if (q.length == 1 && RegExp(r'[a-g]').hasMatch(q)) {
      final note = q.toUpperCase();
      _addSuggestion(suggestions, seen, '$note', '$note major triad', limit);
      _addSuggestion(suggestions, seen, '${note}m', '$note minor triad', limit);
      _addSuggestion(suggestions, seen, '${note}7', '$note dominant 7th', limit);
      _addSuggestion(suggestions, seen, '$note#', '$note sharp', limit);
      _addSuggestion(suggestions, seen, '${note}b', '$note flat', limit);
    }
    
    // Detect "sharp" typing pattern (e.g., "gs", "gsh")
    final sharpMatch = RegExp(r'^([a-g])s(h|ha|har|harp)?$').firstMatch(q);
    if (sharpMatch != null) {
      final root = sharpMatch.group(1)!.toUpperCase();
      _addSuggestion(suggestions, seen, '$root#', '$root sharp', limit);
      _addSuggestion(suggestions, seen, '$root#m', '$root sharp minor', limit);
      _addSuggestion(suggestions, seen, '$root#7', '$root sharp dominant 7', limit);
    }
    
    // Detect "flat" typing pattern (e.g., "gf", "gfl")
    final flatMatch = RegExp(r'^([a-g])f(l|la|lat)?$').firstMatch(q);
    if (flatMatch != null) {
      final root = flatMatch.group(1)!.toUpperCase();
      _addSuggestion(suggestions, seen, '${root}b', '$root flat', limit);
      _addSuggestion(suggestions, seen, '${root}bm', '$root flat minor', limit);
      _addSuggestion(suggestions, seen, '${root}b7', '$root flat dominant 7', limit);
    }
    
    // Enharmonic suggestion (e.g., "cb" → "= B")
    if (q.length >= 2) {
      final potentialRoot = q.substring(0, 2);
      final enharmonic = _enharmonicMap[potentialRoot];
      if (enharmonic != null) {
        final quality = q.length > 2 ? q.substring(2) : '';
        final displayRoot = potentialRoot[0].toUpperCase() + potentialRoot.substring(1);
        final enharmonicDisplay = enharmonic[0].toUpperCase() + 
            (enharmonic.length > 1 ? enharmonic.substring(1) : '');
        _addSuggestion(
          suggestions, seen, 
          '$enharmonic$quality',
          '$displayRoot = $enharmonicDisplay (enharmonic)',
          limit
        );
      }
    }
    
    // Add actual search results
    final searchResults = search(q, limit: limit - suggestions.length);
    for (final chord in searchResults) {
      _addSuggestion(suggestions, seen, chord.displayName, chord.notes.join(' - '), limit);
    }
    
    return suggestions;
  }

  void _addSuggestion(List<SearchSuggestion> list, Set<String> seen, String text, String hint, int limit) {
    if (list.length >= limit) return;
    final key = text.toLowerCase();
    if (seen.contains(key)) return;
    seen.add(key);
    list.add(SearchSuggestion(text, hint));
  }

  // ============================================================
  // FILTER API
  // ============================================================

  List<String> getCategories() {
    final categories = <String>{};
    for (final c in _chords) {
      final cat = c.category;
      if (cat != null && cat.isNotEmpty) {
        categories.add(cat);
      }
    }
    return categories.toList()..sort();
  }

  List<ChordDefinition> getByCategory(String category) {
    return _chords.where((c) => c.category == category).toList();
  }

  List<ChordDefinition> getByRoot(String root) {
    final normRoot = _normalize(root);
    // Also match enharmonic roots
    final enharmonic = _enharmonicMap[normRoot];
    return _chords.where((c) {
      final chordRoot = _normalize(c.root);
      return chordRoot == normRoot || chordRoot == enharmonic;
    }).toList();
  }
}

/// Search suggestion for autocomplete UI
class SearchSuggestion {
  final String text;
  final String hint;
  
  const SearchSuggestion(this.text, this.hint);
}
