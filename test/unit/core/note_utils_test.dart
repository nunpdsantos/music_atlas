import 'package:flutter_test/flutter_test.dart';
import 'package:music_atlas/core/note_utils.dart';

void main() {
  group('NoteUtils', () {
    group('pitchClass', () {
      test('natural notes map to correct pitch classes', () {
        expect(NoteUtils.pitchClass('C'), 0);
        expect(NoteUtils.pitchClass('D'), 2);
        expect(NoteUtils.pitchClass('E'), 4);
        expect(NoteUtils.pitchClass('F'), 5);
        expect(NoteUtils.pitchClass('G'), 7);
        expect(NoteUtils.pitchClass('A'), 9);
        expect(NoteUtils.pitchClass('B'), 11);
      });

      test('lowercase notes are handled', () {
        expect(NoteUtils.pitchClass('c'), 0);
        expect(NoteUtils.pitchClass('g'), 7);
      });

      test('sharp notes are one semitone higher', () {
        expect(NoteUtils.pitchClass('C#'), 1);
        expect(NoteUtils.pitchClass('D#'), 3);
        expect(NoteUtils.pitchClass('F#'), 6);
        expect(NoteUtils.pitchClass('G#'), 8);
        expect(NoteUtils.pitchClass('A#'), 10);
      });

      test('flat notes are one semitone lower', () {
        expect(NoteUtils.pitchClass('Db'), 1);
        expect(NoteUtils.pitchClass('Eb'), 3);
        expect(NoteUtils.pitchClass('Gb'), 6);
        expect(NoteUtils.pitchClass('Ab'), 8);
        expect(NoteUtils.pitchClass('Bb'), 10);
      });

      test('enharmonic equivalents have same pitch class', () {
        expect(NoteUtils.pitchClass('C#'), NoteUtils.pitchClass('Db'));
        expect(NoteUtils.pitchClass('D#'), NoteUtils.pitchClass('Eb'));
        expect(NoteUtils.pitchClass('F#'), NoteUtils.pitchClass('Gb'));
        expect(NoteUtils.pitchClass('G#'), NoteUtils.pitchClass('Ab'));
        expect(NoteUtils.pitchClass('A#'), NoteUtils.pitchClass('Bb'));
      });

      test('E# equals F and Fb equals E', () {
        expect(NoteUtils.pitchClass('E#'), NoteUtils.pitchClass('F'));
        expect(NoteUtils.pitchClass('Fb'), NoteUtils.pitchClass('E'));
      });

      test('B# equals C and Cb equals B', () {
        expect(NoteUtils.pitchClass('B#'), 0); // Same as C
        expect(NoteUtils.pitchClass('Cb'), 11); // Same as B
      });

      test('returns -1 for invalid input', () {
        expect(NoteUtils.pitchClass(''), -1);
        expect(NoteUtils.pitchClass('X'), -1);
        expect(NoteUtils.pitchClass('H'), -1);
        expect(NoteUtils.pitchClass('123'), -1);
      });

      test('handles whitespace', () {
        expect(NoteUtils.pitchClass('  C  '), 0);
        expect(NoteUtils.pitchClass(' F# '), 6);
      });
    });

    group('normalize', () {
      test('replaces sharp unicode symbol', () {
        expect(NoteUtils.normalize('C♯'), 'C#');
        expect(NoteUtils.normalize('F♯'), 'F#');
      });

      test('replaces flat unicode symbol', () {
        expect(NoteUtils.normalize('B♭'), 'Bb');
        expect(NoteUtils.normalize('E♭'), 'Eb');
      });

      test('trims whitespace', () {
        expect(NoteUtils.normalize('  C  '), 'C');
        expect(NoteUtils.normalize('\tD#\n'), 'D#');
      });

      test('handles already normalized input', () {
        expect(NoteUtils.normalize('C'), 'C');
        expect(NoteUtils.normalize('F#'), 'F#');
        expect(NoteUtils.normalize('Bb'), 'Bb');
      });

      test('handles multiple symbols', () {
        expect(NoteUtils.normalize('C♯♯'), 'C##');
        expect(NoteUtils.normalize('D♭♭'), 'Dbb');
      });
    });

    group('pitchClassToNote', () {
      test('returns natural notes correctly', () {
        expect(NoteUtils.pitchClassToNote(0), 'C');
        expect(NoteUtils.pitchClassToNote(2), 'D');
        expect(NoteUtils.pitchClassToNote(4), 'E');
        expect(NoteUtils.pitchClassToNote(5), 'F');
        expect(NoteUtils.pitchClassToNote(7), 'G');
        expect(NoteUtils.pitchClassToNote(9), 'A');
        expect(NoteUtils.pitchClassToNote(11), 'B');
      });

      test('defaults to sharps for accidentals', () {
        expect(NoteUtils.pitchClassToNote(1), 'C#');
        expect(NoteUtils.pitchClassToNote(3), 'D#');
        expect(NoteUtils.pitchClassToNote(6), 'F#');
        expect(NoteUtils.pitchClassToNote(8), 'G#');
        expect(NoteUtils.pitchClassToNote(10), 'A#');
      });

      test('returns flats when preferFlats is true', () {
        expect(NoteUtils.pitchClassToNote(1, preferFlats: true), 'Db');
        expect(NoteUtils.pitchClassToNote(3, preferFlats: true), 'Eb');
        expect(NoteUtils.pitchClassToNote(6, preferFlats: true), 'Gb');
        expect(NoteUtils.pitchClassToNote(8, preferFlats: true), 'Ab');
        expect(NoteUtils.pitchClassToNote(10, preferFlats: true), 'Bb');
      });

      test('natural notes are same regardless of preference', () {
        for (final pc in [0, 2, 4, 5, 7, 9, 11]) {
          expect(
            NoteUtils.pitchClassToNote(pc, preferFlats: true),
            NoteUtils.pitchClassToNote(pc, preferFlats: false),
            reason: 'Pitch class $pc should be same with either preference',
          );
        }
      });

      test('handles pitch classes outside 0-11 range', () {
        expect(NoteUtils.pitchClassToNote(12), 'C'); // Wraps to 0
        expect(NoteUtils.pitchClassToNote(13), 'C#'); // Wraps to 1
        expect(NoteUtils.pitchClassToNote(-1), 'B'); // Wraps to 11
        expect(NoteUtils.pitchClassToNote(24), 'C'); // Wraps to 0
      });
    });

    group('findByPitchClass', () {
      test('finds note with matching pitch class', () {
        final notes = ['C', 'E', 'G'];
        expect(NoteUtils.findByPitchClass(notes, 0), 'C');
        expect(NoteUtils.findByPitchClass(notes, 4), 'E');
        expect(NoteUtils.findByPitchClass(notes, 7), 'G');
      });

      test('returns null when no match', () {
        final notes = ['C', 'E', 'G'];
        expect(NoteUtils.findByPitchClass(notes, 1), isNull);
        expect(NoteUtils.findByPitchClass(notes, 6), isNull);
      });

      test('returns first match when duplicates exist', () {
        final notes = ['C', 'B#', 'G']; // C and B# are enharmonic
        expect(NoteUtils.findByPitchClass(notes, 0), 'C');
      });

      test('handles empty list', () {
        expect(NoteUtils.findByPitchClass([], 0), isNull);
      });

      test('finds enharmonic equivalents', () {
        final notes = ['Db', 'F', 'Ab'];
        expect(NoteUtils.findByPitchClass(notes, 1), 'Db'); // Could also be C#
      });
    });

    group('interval', () {
      test('calculates intervals from C', () {
        expect(NoteUtils.interval('C', 'C'), 0); // Unison
        expect(NoteUtils.interval('C', 'C#'), 1); // Minor 2nd
        expect(NoteUtils.interval('C', 'D'), 2); // Major 2nd
        expect(NoteUtils.interval('C', 'E'), 4); // Major 3rd
        expect(NoteUtils.interval('C', 'F'), 5); // Perfect 4th
        expect(NoteUtils.interval('C', 'G'), 7); // Perfect 5th
        expect(NoteUtils.interval('C', 'A'), 9); // Major 6th
        expect(NoteUtils.interval('C', 'B'), 11); // Major 7th
      });

      test('calculates intervals from other roots', () {
        expect(NoteUtils.interval('G', 'B'), 4); // Major 3rd
        expect(NoteUtils.interval('G', 'D'), 7); // Perfect 5th
        expect(NoteUtils.interval('F', 'A'), 4); // Major 3rd
      });

      test('handles sharps and flats', () {
        expect(NoteUtils.interval('C', 'Eb'), 3); // Minor 3rd
        expect(NoteUtils.interval('C', 'Bb'), 10); // Minor 7th
        expect(NoteUtils.interval('F#', 'A#'), 4); // Major 3rd
      });

      test('returns -1 for invalid notes', () {
        expect(NoteUtils.interval('X', 'C'), -1);
        expect(NoteUtils.interval('C', 'X'), -1);
        expect(NoteUtils.interval('', 'C'), -1);
      });

      test('wraps correctly for all intervals', () {
        // All intervals should be 0-11
        for (final root in ['C', 'D', 'E', 'F', 'G', 'A', 'B']) {
          for (final note in ['C', 'D', 'E', 'F', 'G', 'A', 'B']) {
            final result = NoteUtils.interval(root, note);
            expect(
              result >= 0 && result < 12,
              isTrue,
              reason: 'Interval from $root to $note should be 0-11, got $result',
            );
          }
        }
      });
    });
  });
}
