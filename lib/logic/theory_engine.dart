// lib/logic/theory_engine.dart
import '../data/models.dart';
import '../data/repository.dart';
import '../core/note_utils.dart';

/// Represents the current view mode for displaying keys.
enum KeyView {
  /// Display major key information
  major,
  /// Display relative minor key information
  relativeMinor
}

/// Types of minor scales supported.
enum MinorType {
  /// Natural minor (Aeolian mode)
  natural,
  /// Harmonic minor (raised 7th)
  harmonic,
  /// Melodic minor (raised 6th and 7th ascending)
  melodic
}

/// Core music theory computation engine.
///
/// Provides static methods for generating scales, chords, and music theory
/// data used throughout the application. Contains all the musical knowledge
/// including key signatures, modes, and chord construction rules.
///
/// ## Usage
/// ```dart
/// // Build a triad pack for a major key
/// final pack = TheoryEngine.buildMajorTriadPack('C');
///
/// // Get the relative minor of a key
/// final relMinor = TheoryEngine.kRelativeMinors['C']; // 'A'
///
/// // Build a mode's scale and chords
/// final dorian = TheoryEngine.buildModePack('D', 1, 'Dorian');
/// ```
class TheoryEngine {
  static const List<String> kCircleMajClock = [
    'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#', 'Ab', 'Eb', 'Bb', 'F'
  ];

  static const Map<String, String> kRelativeMinors = {
    'C': 'A',
    'G': 'E',
    'D': 'B',
    'A': 'F#',
    'E': 'C#',
    'B': 'G#',
    'F#': 'D#',
    'C#': 'A#',
    'F': 'D',
    'Bb': 'G',
    'Eb': 'C',
    'Ab': 'F',
  };

  /// Strict major scales (includes E#/B#/Cb/Fb where theory requires them).
  static const Map<String, List<String>> kMajorScales = {
    'C':  ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
    'G':  ['G', 'A', 'B', 'C', 'D', 'E', 'F#'],
    'D':  ['D', 'E', 'F#', 'G', 'A', 'B', 'C#'],
    'A':  ['A', 'B', 'C#', 'D', 'E', 'F#', 'G#'],
    'E':  ['E', 'F#', 'G#', 'A', 'B', 'C#', 'D#'],
    'B':  ['B', 'C#', 'D#', 'E', 'F#', 'G#', 'A#'],
    'F#': ['F#', 'G#', 'A#', 'B', 'C#', 'D#', 'E#'],
    'C#': ['C#', 'D#', 'E#', 'F#', 'G#', 'A#', 'B#'],
    'F':  ['F', 'G', 'A', 'Bb', 'C', 'D', 'E'],
    'Bb': ['Bb', 'C', 'D', 'Eb', 'F', 'G', 'A'],
    'Eb': ['Eb', 'F', 'G', 'Ab', 'Bb', 'C', 'D'],
    'Ab': ['Ab', 'Bb', 'C', 'Db', 'Eb', 'F', 'G'],
    'Db': ['Db', 'Eb', 'F', 'Gb', 'Ab', 'Bb', 'C'],
    'Gb': ['Gb', 'Ab', 'Bb', 'Cb', 'Db', 'Eb', 'F'],
    'Cb': ['Cb', 'Db', 'Eb', 'Fb', 'Gb', 'Ab', 'Bb'],
  };

  // ---------------------------------------------------------------------------
  // KEY SIGNATURES
  // ---------------------------------------------------------------------------

  /// Key signatures: positive = sharps, negative = flats
  static const Map<String, int> kKeySignatures = {
    'C': 0,
    'G': 1, 'D': 2, 'A': 3, 'E': 4, 'B': 5, 'F#': 6, 'C#': 7,
    'F': -1, 'Bb': -2, 'Eb': -3, 'Ab': -4, 'Db': -5, 'Gb': -6, 'Cb': -7,
  };

  /// Returns formatted key signature string (e.g., "2♯" or "3♭")
  static String getKeySignatureDisplay(String key) {
    final sig = kKeySignatures[key];
    if (sig == null) return '—';
    if (sig == 0) return '—';
    if (sig > 0) return '$sig♯';
    return '${sig.abs()}♭';
  }

  // ---------------------------------------------------------------------------
  // MODE CHARACTERISTICS
  // ---------------------------------------------------------------------------

  /// Mode characteristics for educational display
  static const Map<String, Map<String, String>> kModeCharacteristics = {
    'Ionian': {
      'mood': 'Happy, Bright, Stable',
      'family': 'Major',
      'color': 'Bright',
      'usage': 'Pop, Classical, Happy songs',
      'character': 'The standard major scale. Sounds resolved and complete.',
    },
    'Dorian': {
      'mood': 'Jazzy, Soulful, Sophisticated',
      'family': 'Minor',
      'color': 'Warm',
      'usage': 'Jazz, Funk, Soul, Folk',
      'character': 'Minor with a raised 6th. Less sad than natural minor.',
    },
    'Phrygian': {
      'mood': 'Spanish, Dark, Exotic',
      'family': 'Minor',
      'color': 'Dark',
      'usage': 'Flamenco, Metal, Middle Eastern',
      'character': 'The flat 2nd gives it a distinctive Spanish flavor.',
    },
    'Lydian': {
      'mood': 'Dreamy, Floating, Mystical',
      'family': 'Major',
      'color': 'Ethereal',
      'usage': 'Film scores, Progressive rock, Jazz',
      'character': 'The raised 4th creates a sense of wonder and suspension.',
    },
    'Mixolydian': {
      'mood': 'Bluesy, Rock, Laid-back',
      'family': 'Major',
      'color': 'Warm',
      'usage': 'Rock, Blues, Country, Folk',
      'character': 'Major with a flat 7th. Classic rock sound.',
    },
    'Aeolian': {
      'mood': 'Sad, Melancholic, Natural',
      'family': 'Minor',
      'color': 'Dark',
      'usage': 'Pop ballads, Rock, Classical',
      'character': 'The natural minor scale. Straightforward sad sound.',
    },
    'Locrian': {
      'mood': 'Unstable, Tense, Dissonant',
      'family': 'Diminished',
      'color': 'Very Dark',
      'usage': 'Jazz, Metal, Experimental',
      'character': 'Rarely used as a key center due to the diminished tonic.',
    },
  };

  // ---------------------------------------------------------------------------
  // SCALE FORMULAS
  // ---------------------------------------------------------------------------

  /// Common scale formulas (intervals from root)
  static const Map<String, List<int>> kScaleFormulas = {
    'major': [0, 2, 4, 5, 7, 9, 11],
    'natural_minor': [0, 2, 3, 5, 7, 8, 10],
    'harmonic_minor': [0, 2, 3, 5, 7, 8, 11],
    'melodic_minor': [0, 2, 3, 5, 7, 9, 11],
    'pentatonic_major': [0, 2, 4, 7, 9],
    'pentatonic_minor': [0, 3, 5, 7, 10],
    'blues': [0, 3, 5, 6, 7, 10],
    'whole_tone': [0, 2, 4, 6, 8, 10],
    'diminished_hw': [0, 1, 3, 4, 6, 7, 9, 10],
    'diminished_wh': [0, 2, 3, 5, 6, 8, 9, 11],
    'spanish_phrygian': [0, 1, 4, 5, 7, 8, 10],
  };

  /// Scale display names
  static const Map<String, String> kScaleNames = {
    'major': 'Major',
    'natural_minor': 'Natural Minor',
    'harmonic_minor': 'Harmonic Minor',
    'melodic_minor': 'Melodic Minor',
    'pentatonic_major': 'Major Pentatonic',
    'pentatonic_minor': 'Minor Pentatonic',
    'blues': 'Blues',
    'whole_tone': 'Whole Tone',
    'diminished_hw': 'Diminished (H-W)',
    'diminished_wh': 'Diminished (W-H)',
    'spanish_phrygian': 'Spanish Phrygian',
  };

  /// Build scale notes from root and scale type
  static List<String> buildScaleNotes(String root, String scaleType) {
    final formula = kScaleFormulas[scaleType];
    if (formula == null) return [];
    
    final rootPc = pitchClass(root);
    if (rootPc == null) return [];
    
    // Determine if we should prefer flats based on root
    final flatRoots = {'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb'};
    final preferFlats = flatRoots.contains(root);
    
    return formula.map((interval) {
      final pc = (rootPc + interval) % 12;
      return pitchClassToNote(pc, preferFlats: preferFlats) ?? '?';
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // CHORD PROGRESSIONS
  // ---------------------------------------------------------------------------

  /// Common chord progressions by genre
  static const Map<String, List<Map<String, dynamic>>> kProgressions = {
    'Pop/Rock': [
      {
        'name': 'I - V - vi - IV',
        'roman': ['I', 'V', 'vi', 'IV'],
        'description': 'The most popular progression in modern pop music',
        'examples': ['Let It Be', 'No Woman No Cry', 'With or Without You'],
      },
      {
        'name': 'I - IV - V',
        'roman': ['I', 'IV', 'V'],
        'description': 'Classic rock and roll progression',
        'examples': ['La Bamba', 'Twist and Shout', 'Wild Thing'],
      },
      {
        'name': 'vi - IV - I - V',
        'roman': ['vi', 'IV', 'I', 'V'],
        'description': 'Emotional pop progression',
        'examples': ['Despacito', 'Grenade', 'Africa'],
      },
      {
        'name': 'I - vi - IV - V',
        'roman': ['I', 'vi', 'IV', 'V'],
        'description': '50s doo-wop progression',
        'examples': ['Stand By Me', 'Every Breath You Take'],
      },
    ],
    'Jazz': [
      {
        'name': 'ii - V - I',
        'roman': ['ii', 'V', 'I'],
        'description': 'The most important jazz progression',
        'examples': ['Autumn Leaves', 'All The Things You Are'],
      },
      {
        'name': 'I - vi - ii - V',
        'roman': ['I', 'vi', 'ii', 'V'],
        'description': 'Rhythm changes / turnaround',
        'examples': ['I Got Rhythm', 'Anthropology'],
      },
      {
        'name': 'iii - vi - ii - V',
        'roman': ['iii', 'vi', 'ii', 'V'],
        'description': 'Extended turnaround',
        'examples': ['Fly Me To The Moon'],
      },
    ],
    'Blues': [
      {
        'name': '12-Bar Blues',
        'roman': ['I', 'I', 'I', 'I', 'IV', 'IV', 'I', 'I', 'V', 'IV', 'I', 'V'],
        'description': 'Foundation of blues and rock',
        'examples': ['Sweet Home Chicago', 'Pride and Joy'],
      },
      {
        'name': 'Quick Change Blues',
        'roman': ['I', 'IV', 'I', 'I', 'IV', 'IV', 'I', 'I', 'V', 'IV', 'I', 'V'],
        'description': '12-bar with early IV chord',
        'examples': ['Stormy Monday'],
      },
    ],
    'Classical': [
      {
        'name': 'I - IV - V - I',
        'roman': ['I', 'IV', 'V', 'I'],
        'description': 'Authentic cadence progression',
        'examples': ['Countless classical pieces'],
      },
      {
        'name': 'i - iv - V - i',
        'roman': ['i', 'iv', 'V', 'i'],
        'description': 'Minor key cadence',
        'examples': ['Toccata and Fugue in D minor'],
      },
    ],
  };

  /// Convert roman numeral to chord name in a given key
  static String romanToChord(String roman, String key) {
    final scale = kMajorScales[key];
    if (scale == null) return roman;
    
    final romanMap = {
      'I': 0, 'i': 0,
      'II': 1, 'ii': 1,
      'III': 2, 'iii': 2,
      'IV': 3, 'iv': 3,
      'V': 4, 'v': 4,
      'VI': 5, 'vi': 5,
      'VII': 6, 'vii': 6,
    };
    
    // Extract base roman (without suffixes like °)
    final baseRoman = roman.replaceAll(RegExp(r'[°+]'), '');
    final degree = romanMap[baseRoman];
    if (degree == null) return roman;
    
    final root = scale[degree];
    final isMinor = roman[0] == roman[0].toLowerCase();
    final isDim = roman.contains('°');
    final isAug = roman.contains('+');
    
    if (isDim) return '$root°';
    if (isAug) return '$root+';
    if (isMinor) return '${root}m';
    return root;
  }

  // ---------------------------------------------------------------------------
  // Public "compat" API for your providers.dart
  // ---------------------------------------------------------------------------

  /// This method exists because your providers.dart expects it.
  /// It returns the current pack depending on major/relative-minor view.
  static TriadPack buildPack(String selectedMajorRoot, KeyView view, MinorType minorType) {
    if (view == KeyView.major) {
      return buildMajorPack(selectedMajorRoot);
    }
    final relMinor = kRelativeMinors[selectedMajorRoot] ?? 'A';
    return buildMinorPack(relMinor, minorType);
  }

  // ---------------------------------------------------------------------------
  // NOTE PARSING / PITCH-CLASS HELPERS (supports ## and bb)
  // ---------------------------------------------------------------------------

  static (String, int)? _parseNote(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final m = RegExp(r'^([A-Ga-g])((?:bb|##|b|#)?)$').firstMatch(s);
    if (m == null) return null;

    final letter = (m.group(1) ?? '').toUpperCase();
    final accStr = m.group(2) ?? '';

    final acc = switch (accStr) {
      'bb' => -2,
      'b'  => -1,
      ''   => 0,
      '#'  => 1,
      '##' => 2,
      _    => 0,
    };

    return (letter, acc);
  }

  /// Extended pitch class parser that handles double accidentals (## and bb).
  /// For simple cases, prefer NoteUtils.pitchClass() from core/note_utils.dart.
  /// This method exists for theoretical spellings like F## or Dbb.
  static int? pitchClass(String note) {
    final parsed = _parseNote(note);
    if (parsed == null) return null;
    final (letter, acc) = parsed;

    final base = switch (letter) {
      'C' => 0,
      'D' => 2,
      'E' => 4,
      'F' => 5,
      'G' => 7,
      'A' => 9,
      'B' => 11,
      _ => 0,
    };

    final pc = (base + acc) % 12;
    return (pc + 12) % 12;
  }

  static String? pitchClassToNote(int pc, {required bool preferFlats}) {
    final idx = ((pc % 12) + 12) % 12;
    const sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    const flats  = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];
    return preferFlats ? flats[idx] : sharps[idx];
  }

  static bool _hasDoubleAccidentals(List<String> notes) {
    return notes.any((n) => n.contains('##') || n.contains('bb'));
  }

  /// Raise/alter a note by semitones BUT keep the same letter.
  /// This is what enforces strict theoretical spelling.
  static String _raiseSameLetter(String note, int semitones) {
    final parsed = _parseNote(note);
    if (parsed == null) return note;
    final (letter, acc) = parsed;
    final newAcc = acc + semitones;

    String suffix;
    if (newAcc == -2) suffix = 'bb';
    else if (newAcc == -1) suffix = 'b';
    else if (newAcc == 0) suffix = '';
    else if (newAcc == 1) suffix = '#';
    else if (newAcc == 2) suffix = '##';
    else {
      // For completeness if you ever go beyond double accidentals.
      suffix = newAcc > 0 ? ('#' * newAcc) : ('b' * (-newAcc));
    }

    return '$letter$suffix';
  }

  // ---------------------------------------------------------------------------
  // MAJOR / MINOR PACKS
  // ---------------------------------------------------------------------------

  static TriadPack buildMajorPack(String key) {
    final scale = kMajorScales[key] ?? const <String>[];
    const romans = ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'];
    const qualities = ['Major', 'Minor', 'Minor', 'Major', 'Major', 'Minor', 'Diminished'];

    final chordNames = <String>[];
    final notes = <List<String>>[];

    for (int i = 0; i < 7; i++) {
      final n1 = scale[i % 7];
      final n3 = scale[(i + 2) % 7];
      final n5 = scale[(i + 4) % 7];
      notes.add([n1, n3, n5]);

      final qual = qualities[i];
      chordNames.add(switch (qual) {
        'Major' => n1,
        'Minor' => '${n1}m',
        'Diminished' => '${n1}°',
        _ => n1,
      });
    }

    return TriadPack(
      keyLabel: '$key Major',
      scale: scale,
      roman: romans,
      chordNames: chordNames,
      notes: notes,
      qualities: qualities,
    );
  }

  static TriadPack buildMinorPack(String key, MinorType type) {
    final parentMajor = _getRelativeMajorFromMinor(key);
    final parentScale = kMajorScales[parentMajor] ?? const <String>[];

    if (parentScale.isEmpty) {
      return TriadPack(
        keyLabel: 'Unknown',
        scale: const [],
        roman: const [],
        chordNames: const [],
        notes: const [],
        qualities: const [],
      );
    }

    // Natural minor = Aeolian rotation of parent major (start at degree 6).
    const aeolianIdx = 5;
    final naturalMinor = <String>[];
    for (int i = 0; i < 7; i++) {
      naturalMinor.add(parentScale[(i + aeolianIdx) % 7]);
    }

    final minorScale = List<String>.from(naturalMinor);

    // Harmonic minor: raise 7th (same letter)
    if (type == MinorType.harmonic || type == MinorType.melodic) {
      minorScale[6] = _raiseSameLetter(minorScale[6], 1);
    }

    // Melodic minor: also raise 6th (same letter)
    if (type == MinorType.melodic) {
      minorScale[5] = _raiseSameLetter(minorScale[5], 1);
    }

    final typeLabel = switch (type) {
      MinorType.natural => 'Natural',
      MinorType.harmonic => 'Harmonic',
      MinorType.melodic => 'Melodic',
    };

    // Keep your existing chord-quality teaching scheme stable.
    final romans = switch (type) {
      MinorType.natural => const ['i', 'ii°', 'III', 'iv', 'v', 'VI', 'VII'],
      MinorType.harmonic => const ['i', 'ii°', 'III+', 'iv', 'V', 'VI', 'vii°'],
      MinorType.melodic => const ['i', 'ii', 'III+', 'IV', 'V', 'vi°', 'vii°'],
    };

    final qualities = switch (type) {
      MinorType.natural => const ['Minor', 'Diminished', 'Major', 'Minor', 'Minor', 'Major', 'Major'],
      MinorType.harmonic => const ['Minor', 'Diminished', 'Augmented', 'Minor', 'Major', 'Major', 'Diminished'],
      MinorType.melodic => const ['Minor', 'Minor', 'Augmented', 'Major', 'Major', 'Diminished', 'Diminished'],
    };

    final chordNames = <String>[];
    final notes = <List<String>>[];

    for (int i = 0; i < 7; i++) {
      final n1 = minorScale[i % 7];
      final n3 = minorScale[(i + 2) % 7];
      final n5 = minorScale[(i + 4) % 7];
      notes.add([n1, n3, n5]);

      final qual = qualities[i];
      chordNames.add(switch (qual) {
        'Major' => n1,
        'Minor' => '${n1}m',
        'Diminished' => '${n1}°',
        'Augmented' => '${n1}+',
        _ => n1,
      });
    }

    return TriadPack(
      keyLabel: '$key $typeLabel Minor',
      scale: minorScale,
      roman: romans,
      chordNames: chordNames,
      notes: notes,
      qualities: qualities,
    );
  }

  static String _getRelativeMajorFromMinor(String minorRoot) {
    for (final e in kRelativeMinors.entries) {
      if (e.value == minorRoot) return e.key;
    }
    return minorRoot;
  }

  // ---------------------------------------------------------------------------
  // MODES
  // ---------------------------------------------------------------------------

  static const _modeIntervals = [2, 2, 1, 2, 2, 2, 1];

  static String getParentMajorForMode(String root, int modeIndex) {
    final rPc = pitchClass(root);
    if (rPc == null) return '?';

    int back = 0;
    for (int i = 0; i < modeIndex; i++) back += _modeIntervals[i];
    final pPc = (rPc - back) % 12;

    final pFlat = pitchClassToNote(pPc, preferFlats: true);
    final pSharp = pitchClassToNote(pPc, preferFlats: false);

    if (pFlat != null && kMajorScales.containsKey(pFlat)) return pFlat;
    if (pSharp != null && kMajorScales.containsKey(pSharp)) return pSharp;
    return pSharp ?? '?';
  }

  static TriadPack buildModePack(String root, int modeIdx, String modeName) {
    final parent = getParentMajorForMode(root, modeIdx);
    final pScale = kMajorScales[parent];

    if (pScale == null) {
      return TriadPack(
        keyLabel: 'Unknown',
        scale: const [],
        roman: const [],
        chordNames: const [],
        notes: const [],
        qualities: const [],
      );
    }

    final scale = <String>[];
    for (int i = 0; i < 7; i++) {
      scale.add(pScale[(i + modeIdx) % 7]);
    }

    const majQuals = ['Major', 'Minor', 'Minor', 'Major', 'Major', 'Minor', 'Diminished'];
    const majRom = ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'];

    final quals = <String>[];
    final roms = <String>[];
    for (int i = 0; i < 7; i++) {
      quals.add(majQuals[(i + modeIdx) % 7]);
      roms.add(majRom[(i + modeIdx) % 7]);
    }

    final names = <String>[];
    final notes = <List<String>>[];

    for (int i = 0; i < 7; i++) {
      final n1 = scale[i % 7];
      final n3 = scale[(i + 2) % 7];
      final n5 = scale[(i + 4) % 7];
      notes.add([n1, n3, n5]);

      final q = quals[i];
      names.add(switch (q) {
        'Major' => n1,
        'Minor' => '${n1}m',
        'Diminished' => '${n1}°',
        _ => n1,
      });
    }

    return TriadPack(
      keyLabel: '$root $modeName',
      scale: scale,
      roman: roms,
      chordNames: names,
      notes: notes,
      qualities: quals,
    );
  }

  // ---------------------------------------------------------------------------
  // QUERY NORMALIZATION (search uses this)
  // ---------------------------------------------------------------------------

  static String normalizeUserChordQuery(String input) {
    var s = input.trim().toLowerCase();
    s = s.replaceAll('♯', '#').replaceAll('♭', 'b');
    s = s.replaceAll(RegExp(r'[\-_\.\,]+'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll(RegExp(r'\b([a-g])\s+sharp\b'), r'$1#')
         .replaceAll(RegExp(r'\b([a-g])\s+flat\b'), r'$1b');
    s = s.replaceAll(' ', '');
    s = s.replaceAll(RegExp(r'([a-g])sharp'), r'$1#')
         .replaceAll(RegExp(r'([a-g])flat'), r'$1b');
    s = s.replaceAll('major', 'maj')
         .replaceAll('minor', 'm')
         .replaceAll('diminished', 'dim')
         .replaceAll('augmented', '+');
    // Keep strict: do not rewrite E#/Cb/etc. This is search normalization only.
    return s;
  }

  // ---------------------------------------------------------------------------
  // SMART CHORD PARSING (matches repository logic for consistency)
  // ---------------------------------------------------------------------------

  /// Predictive patterns for parsing user input like "gsh" -> "G#", "bfl" -> "Bb"
  static final Map<RegExp, String Function(Match)> _predictivePatterns = {
    // "gs", "gsh", "gsha", "gshar", "gsharp" → "G#"
    RegExp(r'^([a-gA-G])s(h|ha|har|harp)?(.*)$'): (m) => 
        '${m.group(1)!.toUpperCase()}#${m.group(3) ?? ''}',
    // "gf", "gfl", "gfla", "gflat" → "Gb"
    RegExp(r'^([a-gA-G])f(l|la|lat)?(.*)$'): (m) => 
        '${m.group(1)!.toUpperCase()}b${m.group(3) ?? ''}',
    // "g sharp" with space
    RegExp(r'^([a-gA-G])\s*sharp(.*)$'): (m) => 
        '${m.group(1)!.toUpperCase()}#${m.group(2) ?? ''}',
    // "g flat" with space
    RegExp(r'^([a-gA-G])\s*flat(.*)$'): (m) => 
        '${m.group(1)!.toUpperCase()}b${m.group(2) ?? ''}',
  };

  /// Normalize a chord token for parsing
  static String _normalizeChordToken(String input) {
    var s = input.trim();
    
    // Handle unicode symbols
    s = s.replaceAll('♯', '#').replaceAll('♭', 'b');
    
    // Try each predictive pattern
    for (final entry in _predictivePatterns.entries) {
      final match = entry.key.firstMatch(s.toLowerCase());
      if (match != null) {
        s = entry.value(match);
        break;
      }
    }
    
    // Handle word replacements
    s = s.replaceAll(RegExp(r'sharp', caseSensitive: false), '#')
         .replaceAll(RegExp(r'flat', caseSensitive: false), 'b')
         .replaceAll(RegExp(r'major', caseSensitive: false), 'maj')
         .replaceAll(RegExp(r'minor', caseSensitive: false), 'm')
         .replaceAll(RegExp(r'diminished', caseSensitive: false), 'dim')
         .replaceAll(RegExp(r'augmented', caseSensitive: false), 'aug');
    
    return s;
  }

  /// Parse a chord string into root and quality components
  static (String root, String quality)? _parseChord(String input) {
    final normalized = _normalizeChordToken(input);
    if (normalized.isEmpty) return null;
    
    // Extended regex to match root with optional double accidentals
    final chordRegex = RegExp(r'^([a-gA-G](?:bb|##|b|#)?)(.*)$');
    final match = chordRegex.firstMatch(normalized);
    
    if (match == null) return null;
    
    final rootRaw = match.group(1) ?? '';
    final quality = match.group(2) ?? '';
    
    // Capitalize root note, preserve accidentals
    String cleanRoot = rootRaw[0].toUpperCase();
    if (rootRaw.length > 1) cleanRoot += rootRaw.substring(1).toLowerCase();
    
    return (cleanRoot, quality);
  }

  // ---------------------------------------------------------------------------
  // TRANSPOSITION ENGINE (with smart chord parsing)
  // ---------------------------------------------------------------------------

  static List<TransposedChord> transposeProgression(
    String raw,
    String from,
    String to,
    MusicRepository repo,
  ) {
    raw = raw.trim();
    if (raw.isEmpty) return const [];

    // Pre-normalize the entire input
    final normalizedInput = raw.replaceAll('♯', '#').replaceAll('♭', 'b');
    final tokens = normalizedInput.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final fromPc = pitchClass(from);
    final toPc = pitchClass(to);
    if (fromPc == null || toPc == null) return const [];
    final diff = (toPc - fromPc + 12) % 12;

    // Choose # vs b based on target key
    final flatKeys = {'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb'};
    final preferFlats = flatKeys.contains(to);

    String transposeRoot(String root) {
      final pc = pitchClass(root);
      if (pc == null) return root;
      final newPc = (pc + diff) % 12;
      return pitchClassToNote(newPc, preferFlats: preferFlats) ?? root;
    }

    final results = <TransposedChord>[];

    for (final token in tokens) {
      // Use smart parsing
      final parsed = _parseChord(token);
      
      if (parsed == null) {
        // Token couldn't be parsed as a chord, keep as-is
        results.add(TransposedChord(token, const []));
        continue;
      }

      final (root, quality) = parsed;
      final newRoot = transposeRoot(root);
      final newName = newRoot + quality;

      final def = repo.findByName(newName);
      results.add(
        TransposedChord(
          newName,
          def?.notes ?? const [],
          notesEnharmonicAlt: def?.notesEnharmonicAlt,
        ),
      );
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // UI policy: show "sounds like" only when ## or bb exist (and alt differs)
  // ---------------------------------------------------------------------------

  static bool shouldShowSoundsLike(List<String> notes, List<String>? alt) {
    if (alt == null || alt.isEmpty) return false;
    if (!_hasDoubleAccidentals(notes)) return false;

    if (notes.length != alt.length) return true;
    for (int i = 0; i < notes.length; i++) {
      if (notes[i] != alt[i]) return true;
    }
    return false;
  }
}
