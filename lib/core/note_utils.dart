// lib/core/note_utils.dart

/// Shared utilities for note/pitch class operations.
/// Consolidates duplicated logic from multiple files.
class NoteUtils {
  static const Map<String, int> _baseValues = {
    'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11,
  };

  /// Converts a note name to its pitch class (0-11).
  /// Returns -1 for invalid input.
  /// 
  /// Examples:
  /// - pitchClass('C') => 0
  /// - pitchClass('F#') => 6
  /// - pitchClass('Bb') => 10
  static int pitchClass(String note) {
    final s = normalize(note);
    if (s.isEmpty) return -1;

    final letter = s[0].toUpperCase();
    final baseValue = _baseValues[letter];
    if (baseValue == null) return -1;

    int val = baseValue;
    final rest = s.substring(1);
    
    for (int i = 0; i < rest.length; i++) {
      final ch = rest[i];
      if (ch == '#') val += 1;
      if (ch == 'b' && !(i == 0 && letter == 'B')) val -= 1;
    }

    return ((val % 12) + 12) % 12;
  }

  /// Normalizes a note string by replacing Unicode symbols with ASCII.
  /// 
  /// Examples:
  /// - normalize('C♯') => 'C#'
  /// - normalize('B♭') => 'Bb'
  static String normalize(String note) {
    return note
        .trim()
        .replaceAll('♯', '#')
        .replaceAll('♭', 'b')
        .replaceAll('â™¯', '#')
        .replaceAll('â™­', 'b');
  }

  /// Converts pitch class back to note name.
  /// 
  /// [preferFlats] - if true, returns 'Bb' instead of 'A#'
  static String pitchClassToNote(int pc, {bool preferFlats = false}) {
    final idx = ((pc % 12) + 12) % 12;
    const sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    const flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];
    return preferFlats ? flats[idx] : sharps[idx];
  }

  /// Finds the first note in a set that matches the given pitch class.
  static String? findByPitchClass(Iterable<String> notes, int targetPc) {
    for (final note in notes) {
      if (pitchClass(note) == targetPc) return note;
    }
    return null;
  }

  /// Calculates the interval (in semitones) from root to note.
  static int interval(String root, String note) {
    final rootPc = pitchClass(root);
    final notePc = pitchClass(note);
    if (rootPc == -1 || notePc == -1) return -1;
    return ((notePc - rootPc) % 12 + 12) % 12;
  }
}
