import 'package:flutter_test/flutter_test.dart';
import 'package:music_atlas/data/models.dart';

void main() {
  group('ChordDefinition', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'chord_id': 'C_major',
          'root': 'C',
          'quality': 'major',
          'formula_semitones': [0, 4, 7],
          'display_name': 'C Major',
          'notes': ['C', 'E', 'G'],
          'aliases': ['CM', 'Cmaj'],
          'search_tokens': ['c', 'cmaj', 'cmajor'],
          'category': 'triad',
        };

        final chord = ChordDefinition.fromJson(json);

        expect(chord.id, 'C_major');
        expect(chord.root, 'C');
        expect(chord.quality, 'major');
        expect(chord.semitones, [0, 4, 7]);
        expect(chord.displayName, 'C Major');
        expect(chord.notes, ['C', 'E', 'G']);
        expect(chord.aliases, ['CM', 'Cmaj']);
        expect(chord.searchTokens, ['c', 'cmaj', 'cmajor']);
        expect(chord.category, 'triad');
      });

      test('handles missing optional fields', () {
        final json = {
          'chord_id': 'test',
          'root': 'C',
          'quality': 'major',
        };

        final chord = ChordDefinition.fromJson(json);

        expect(chord.semitones, isEmpty);
        expect(chord.displayName, '');
        expect(chord.notes, isEmpty);
        expect(chord.aliases, isEmpty);
        expect(chord.searchTokens, isEmpty);
        expect(chord.notesEnharmonicAlt, isNull);
        expect(chord.category, isNull);
      });

      test('parses enharmonic alternatives', () {
        final json = {
          'chord_id': 'F##_major',
          'root': 'F##',
          'quality': 'major',
          'notes': ['F##', 'A#', 'C#'],
          'notes_enharmonic_alt': ['G', 'A#', 'C#'],
        };

        final chord = ChordDefinition.fromJson(json);

        expect(chord.notes, ['F##', 'A#', 'C#']);
        expect(chord.notesEnharmonicAlt, ['G', 'A#', 'C#']);
      });
    });

    group('needsSoundsLikeLine', () {
      test('returns true for double sharps', () {
        final chord = ChordDefinition(
          id: 'test',
          root: 'F##',
          quality: 'major',
          semitones: [0, 4, 7],
          displayName: 'Test',
          notes: ['F##', 'A#', 'C#'],
          aliases: [],
        );

        expect(chord.needsSoundsLikeLine, isTrue);
      });

      test('returns true for double flats', () {
        final chord = ChordDefinition(
          id: 'test',
          root: 'Bbb',
          quality: 'major',
          semitones: [0, 4, 7],
          displayName: 'Test',
          notes: ['Bbb', 'Db', 'Fb'],
          aliases: [],
        );

        expect(chord.needsSoundsLikeLine, isTrue);
      });

      test('returns false for normal accidentals', () {
        final chord = ChordDefinition(
          id: 'test',
          root: 'F#',
          quality: 'major',
          semitones: [0, 4, 7],
          displayName: 'F# Major',
          notes: ['F#', 'A#', 'C#'],
          aliases: [],
        );

        expect(chord.needsSoundsLikeLine, isFalse);
      });

      test('returns false for natural notes', () {
        final chord = ChordDefinition(
          id: 'test',
          root: 'C',
          quality: 'major',
          semitones: [0, 4, 7],
          displayName: 'C Major',
          notes: ['C', 'E', 'G'],
          aliases: [],
        );

        expect(chord.needsSoundsLikeLine, isFalse);
      });
    });
  });

  group('ChordQuality', () {
    test('fromJson parses correctly', () {
      final json = {
        'quality_id': 'major',
        'name': 'Major',
        'formula': [0, 4, 7],
        'aliases_pattern': ['M', 'maj', ''],
        'aliases': ['Major', 'Maj'],
      };

      final quality = ChordQuality.fromJson(json);

      expect(quality.id, 'major');
      expect(quality.name, 'Major');
      expect(quality.formula, [0, 4, 7]);
      expect(quality.aliasesPattern, ['M', 'maj', '']);
      expect(quality.aliases, ['Major', 'Maj']);
    });

    test('handles missing optional fields', () {
      final json = {
        'quality_id': 'test',
        'name': 'Test',
      };

      final quality = ChordQuality.fromJson(json);

      expect(quality.formula, isEmpty);
      expect(quality.aliasesPattern, isEmpty);
      expect(quality.aliases, isEmpty);
    });
  });

  group('TriadPack', () {
    test('creates valid pack with all fields', () {
      final pack = TriadPack(
        keyLabel: 'C Major',
        scale: ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
        roman: ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'],
        chordNames: ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'B°'],
        notes: [
          ['C', 'E', 'G'],
          ['D', 'F', 'A'],
          ['E', 'G', 'B'],
          ['F', 'A', 'C'],
          ['G', 'B', 'D'],
          ['A', 'C', 'E'],
          ['B', 'D', 'F'],
        ],
        qualities: ['Major', 'Minor', 'Minor', 'Major', 'Major', 'Minor', 'Diminished'],
      );

      expect(pack.keyLabel, 'C Major');
      expect(pack.scale.length, 7);
      expect(pack.roman.length, 7);
      expect(pack.chordNames.length, 7);
      expect(pack.notes.length, 7);
      expect(pack.qualities.length, 7);
    });

    test('each triad has 3 notes', () {
      final pack = TriadPack(
        keyLabel: 'Test',
        scale: ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
        roman: ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'],
        chordNames: ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'B°'],
        notes: [
          ['C', 'E', 'G'],
          ['D', 'F', 'A'],
          ['E', 'G', 'B'],
          ['F', 'A', 'C'],
          ['G', 'B', 'D'],
          ['A', 'C', 'E'],
          ['B', 'D', 'F'],
        ],
        qualities: ['Major', 'Minor', 'Minor', 'Major', 'Major', 'Minor', 'Diminished'],
      );

      for (final triad in pack.notes) {
        expect(triad.length, 3, reason: 'Each triad should have exactly 3 notes');
      }
    });
  });

  group('TransposedChord', () {
    test('creates with name and notes', () {
      final chord = TransposedChord('Dm', ['D', 'F', 'A']);

      expect(chord.name, 'Dm');
      expect(chord.notes, ['D', 'F', 'A']);
      expect(chord.notesEnharmonicAlt, isNull);
    });

    test('creates with enharmonic alternative', () {
      final chord = TransposedChord(
        'F##m',
        ['F##', 'A#', 'C#'],
        notesEnharmonicAlt: ['G', 'A#', 'C#'],
      );

      expect(chord.name, 'F##m');
      expect(chord.notes, ['F##', 'A#', 'C#']);
      expect(chord.notesEnharmonicAlt, ['G', 'A#', 'C#']);
    });

    test('handles empty notes', () {
      final chord = TransposedChord('Unknown', []);

      expect(chord.name, 'Unknown');
      expect(chord.notes, isEmpty);
    });
  });
}
