class ChordDefinition {
  final String id;
  final String root;
  final String quality;
  final List<int> semitones;
  final String displayName;

  /// Strict theoretical spelling (may contain ## / bb)
  final List<String> notes;

  /// Optional: a "sounds like" enharmonic line (only used when notes contain ##/bb)
  final List<String>? notesEnharmonicAlt;

  final List<String> aliases;
  final List<String> searchTokens;
  
  /// Category for filtering (e.g., 'triad', 'dominant', 'altered_dominant')
  final String? category;

  ChordDefinition({
    required this.id,
    required this.root,
    required this.quality,
    required this.semitones,
    required this.displayName,
    required this.notes,
    required this.aliases,
    this.searchTokens = const [],
    this.notesEnharmonicAlt,
    this.category,
  });

  bool get needsSoundsLikeLine {
    return notes.any((n) => n.contains('##') || n.contains('bb'));
  }

  factory ChordDefinition.fromJson(Map<String, dynamic> json) {
    return ChordDefinition(
      id: json['chord_id'] as String,
      root: json['root'] as String,
      quality: json['quality'] as String,
      semitones: List<int>.from(json['formula_semitones'] ?? const <int>[]),
      displayName: (json['display_name'] as String?) ?? '',
      notes: List<String>.from(json['notes'] ?? const <String>[]),
      notesEnharmonicAlt: json['notes_enharmonic_alt'] == null
          ? null
          : List<String>.from(json['notes_enharmonic_alt'] ?? const <String>[]),
      aliases: List<String>.from(json['aliases'] ?? const <String>[]),
      searchTokens: List<String>.from(json['search_tokens'] ?? const <String>[]),
      category: json['category'] as String?,
    );
  }
}

class ChordQuality {
  final String id;
  final String name;
  final List<int> formula;
  final List<String> aliasesPattern;
  final List<String> aliases;

  ChordQuality({
    required this.id,
    required this.name,
    required this.formula,
    required this.aliasesPattern,
    required this.aliases,
  });

  factory ChordQuality.fromJson(Map<String, dynamic> json) {
    return ChordQuality(
      id: json['quality_id'] as String,
      name: json['name'] as String,
      formula: List<int>.from(json['formula'] ?? const <int>[]),
      aliasesPattern: List<String>.from(json['aliases_pattern'] ?? const <String>[]),
      aliases: List<String>.from(json['aliases'] ?? const <String>[]),
    );
  }
}

class TriadPack {
  final String keyLabel;
  final List<String> scale;
  final List<String> roman;
  final List<String> chordNames;
  final List<List<String>> notes;
  final List<String> qualities;

  TriadPack({
    required this.keyLabel,
    required this.scale,
    required this.roman,
    required this.chordNames,
    required this.notes,
    required this.qualities,
  });
}

class TransposedChord {
  final String name;
  final List<String> notes;
  final List<String>? notesEnharmonicAlt;
  TransposedChord(this.name, this.notes, {this.notesEnharmonicAlt});
}
