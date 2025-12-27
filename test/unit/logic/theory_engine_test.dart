import 'package:flutter_test/flutter_test.dart';
import 'package:music_atlas/logic/theory_engine.dart';

void main() {
  group('TheoryEngine', () {
    group('Circle of Fifths', () {
      test('contains all 12 major keys', () {
        expect(TheoryEngine.kCircleMajClock.length, 12);
        expect(TheoryEngine.kCircleMajClock, contains('C'));
        expect(TheoryEngine.kCircleMajClock, contains('G'));
        expect(TheoryEngine.kCircleMajClock, contains('F'));
        expect(TheoryEngine.kCircleMajClock, contains('F#'));
      });

      test('starts with C and progresses by fifths', () {
        expect(TheoryEngine.kCircleMajClock[0], 'C');
        expect(TheoryEngine.kCircleMajClock[1], 'G'); // 5th of C
        expect(TheoryEngine.kCircleMajClock[2], 'D'); // 5th of G
      });

      test('all relative minors are defined', () {
        for (final major in TheoryEngine.kCircleMajClock) {
          expect(
            TheoryEngine.kRelativeMinors.containsKey(major),
            isTrue,
            reason: 'Missing relative minor for $major',
          );
        }
      });

      test('relative minor is 3 semitones below major', () {
        // C major -> A minor (C=0, A=9, difference = 3 semitones down)
        expect(TheoryEngine.kRelativeMinors['C'], 'A');
        // G major -> E minor
        expect(TheoryEngine.kRelativeMinors['G'], 'E');
        // F major -> D minor
        expect(TheoryEngine.kRelativeMinors['F'], 'D');
      });
    });

    group('Major Scales', () {
      test('C major has no sharps or flats', () {
        final cMajor = TheoryEngine.kMajorScales['C'];
        expect(cMajor, ['C', 'D', 'E', 'F', 'G', 'A', 'B']);
        expect(cMajor!.any((note) => note.contains('#') || note.contains('b')), isFalse);
      });

      test('G major has one sharp (F#)', () {
        final gMajor = TheoryEngine.kMajorScales['G'];
        expect(gMajor, ['G', 'A', 'B', 'C', 'D', 'E', 'F#']);
        expect(gMajor!.where((n) => n.contains('#')).length, 1);
      });

      test('F major has one flat (Bb)', () {
        final fMajor = TheoryEngine.kMajorScales['F'];
        expect(fMajor, ['F', 'G', 'A', 'Bb', 'C', 'D', 'E']);
        expect(fMajor!.where((n) => n.contains('b')).length, 1);
      });

      test('all major scales have 7 notes', () {
        for (final entry in TheoryEngine.kMajorScales.entries) {
          expect(
            entry.value.length,
            7,
            reason: '${entry.key} major should have 7 notes',
          );
        }
      });

      test('F# major has E# (not F)', () {
        final fSharpMajor = TheoryEngine.kMajorScales['F#'];
        expect(fSharpMajor, contains('E#'));
        expect(fSharpMajor, isNot(contains('F')));
      });

      test('C# major has B# (not C)', () {
        final cSharpMajor = TheoryEngine.kMajorScales['C#'];
        expect(cSharpMajor, contains('B#'));
        expect(cSharpMajor, isNot(contains('C')));
      });

      test('Gb major has Cb (not B)', () {
        final gbMajor = TheoryEngine.kMajorScales['Gb'];
        expect(gbMajor, contains('Cb'));
        expect(gbMajor, isNot(contains('B')));
      });
    });

    group('Key Signatures', () {
      test('C has no sharps or flats', () {
        expect(TheoryEngine.kKeySignatures['C'], 0);
        expect(TheoryEngine.getKeySignatureDisplay('C'), '—');
      });

      test('sharp keys have positive values', () {
        expect(TheoryEngine.kKeySignatures['G'], 1);
        expect(TheoryEngine.kKeySignatures['D'], 2);
        expect(TheoryEngine.kKeySignatures['A'], 3);
        expect(TheoryEngine.kKeySignatures['E'], 4);
        expect(TheoryEngine.kKeySignatures['B'], 5);
        expect(TheoryEngine.kKeySignatures['F#'], 6);
        expect(TheoryEngine.kKeySignatures['C#'], 7);
      });

      test('flat keys have negative values', () {
        expect(TheoryEngine.kKeySignatures['F'], -1);
        expect(TheoryEngine.kKeySignatures['Bb'], -2);
        expect(TheoryEngine.kKeySignatures['Eb'], -3);
        expect(TheoryEngine.kKeySignatures['Ab'], -4);
        expect(TheoryEngine.kKeySignatures['Db'], -5);
        expect(TheoryEngine.kKeySignatures['Gb'], -6);
        expect(TheoryEngine.kKeySignatures['Cb'], -7);
      });

      test('display format includes symbols', () {
        expect(TheoryEngine.getKeySignatureDisplay('G'), '1♯');
        expect(TheoryEngine.getKeySignatureDisplay('D'), '2♯');
        expect(TheoryEngine.getKeySignatureDisplay('F'), '1♭');
        expect(TheoryEngine.getKeySignatureDisplay('Bb'), '2♭');
      });
    });

    group('Pitch Class', () {
      test('natural notes map correctly', () {
        expect(TheoryEngine.pitchClass('C'), 0);
        expect(TheoryEngine.pitchClass('D'), 2);
        expect(TheoryEngine.pitchClass('E'), 4);
        expect(TheoryEngine.pitchClass('F'), 5);
        expect(TheoryEngine.pitchClass('G'), 7);
        expect(TheoryEngine.pitchClass('A'), 9);
        expect(TheoryEngine.pitchClass('B'), 11);
      });

      test('sharps add one semitone', () {
        expect(TheoryEngine.pitchClass('C#'), 1);
        expect(TheoryEngine.pitchClass('F#'), 6);
        expect(TheoryEngine.pitchClass('G#'), 8);
      });

      test('flats subtract one semitone', () {
        expect(TheoryEngine.pitchClass('Db'), 1);
        expect(TheoryEngine.pitchClass('Eb'), 3);
        expect(TheoryEngine.pitchClass('Bb'), 10);
      });

      test('double sharps add two semitones', () {
        expect(TheoryEngine.pitchClass('C##'), 2);
        expect(TheoryEngine.pitchClass('F##'), 7); // Same as G
      });

      test('double flats subtract two semitones', () {
        expect(TheoryEngine.pitchClass('Dbb'), 0); // Same as C
        expect(TheoryEngine.pitchClass('Bbb'), 9); // Same as A
      });

      test('enharmonic equivalents have same pitch class', () {
        expect(TheoryEngine.pitchClass('C#'), TheoryEngine.pitchClass('Db'));
        expect(TheoryEngine.pitchClass('F#'), TheoryEngine.pitchClass('Gb'));
        expect(TheoryEngine.pitchClass('B'), TheoryEngine.pitchClass('Cb'));
        expect(TheoryEngine.pitchClass('E'), TheoryEngine.pitchClass('Fb'));
      });

      test('returns null for invalid input', () {
        expect(TheoryEngine.pitchClass(''), isNull);
        expect(TheoryEngine.pitchClass('X'), isNull);
        expect(TheoryEngine.pitchClass('H'), isNull);
      });
    });

    group('Pitch Class to Note', () {
      test('converts with sharps preference', () {
        expect(TheoryEngine.pitchClassToNote(0, preferFlats: false), 'C');
        expect(TheoryEngine.pitchClassToNote(1, preferFlats: false), 'C#');
        expect(TheoryEngine.pitchClassToNote(6, preferFlats: false), 'F#');
      });

      test('converts with flats preference', () {
        expect(TheoryEngine.pitchClassToNote(0, preferFlats: true), 'C');
        expect(TheoryEngine.pitchClassToNote(1, preferFlats: true), 'Db');
        expect(TheoryEngine.pitchClassToNote(6, preferFlats: true), 'Gb');
      });

      test('natural notes are same regardless of preference', () {
        for (final pc in [0, 2, 4, 5, 7, 9, 11]) {
          expect(
            TheoryEngine.pitchClassToNote(pc, preferFlats: true),
            TheoryEngine.pitchClassToNote(pc, preferFlats: false),
          );
        }
      });
    });

    group('Build Major Pack', () {
      test('C major pack has correct structure', () {
        final pack = TheoryEngine.buildMajorPack('C');

        expect(pack.keyLabel, 'C Major');
        expect(pack.scale, ['C', 'D', 'E', 'F', 'G', 'A', 'B']);
        expect(pack.roman, ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°']);
        expect(pack.chordNames, ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'B°']);
        expect(pack.qualities, ['Major', 'Minor', 'Minor', 'Major', 'Major', 'Minor', 'Diminished']);
      });

      test('chord notes are correct triads', () {
        final pack = TheoryEngine.buildMajorPack('C');

        // I chord (C major): C-E-G
        expect(pack.notes[0], ['C', 'E', 'G']);
        // ii chord (D minor): D-F-A
        expect(pack.notes[1], ['D', 'F', 'A']);
        // V chord (G major): G-B-D
        expect(pack.notes[4], ['G', 'B', 'D']);
        // vii° chord (B dim): B-D-F
        expect(pack.notes[6], ['B', 'D', 'F']);
      });

      test('all 7 chords are generated', () {
        final pack = TheoryEngine.buildMajorPack('G');
        expect(pack.chordNames.length, 7);
        expect(pack.notes.length, 7);
        expect(pack.qualities.length, 7);
      });
    });

    group('Build Minor Pack', () {
      test('natural minor has correct qualities', () {
        final pack = TheoryEngine.buildMinorPack('A', MinorType.natural);

        expect(pack.keyLabel, 'A Natural Minor');
        expect(pack.scale, ['A', 'B', 'C', 'D', 'E', 'F', 'G']);
        expect(pack.roman, ['i', 'ii°', 'III', 'iv', 'v', 'VI', 'VII']);
      });

      test('harmonic minor raises 7th degree', () {
        final pack = TheoryEngine.buildMinorPack('A', MinorType.harmonic);

        expect(pack.keyLabel, 'A Harmonic Minor');
        expect(pack.scale[6], 'G#'); // Raised 7th
        expect(pack.roman, ['i', 'ii°', 'III+', 'iv', 'V', 'VI', 'vii°']);
      });

      test('melodic minor raises 6th and 7th degrees', () {
        final pack = TheoryEngine.buildMinorPack('A', MinorType.melodic);

        expect(pack.keyLabel, 'A Melodic Minor');
        expect(pack.scale[5], 'F#'); // Raised 6th
        expect(pack.scale[6], 'G#'); // Raised 7th
      });
    });

    group('Build Mode Pack', () {
      test('Ionian is identical to major', () {
        final ionian = TheoryEngine.buildModePack('C', 0, 'Ionian');
        final major = TheoryEngine.buildMajorPack('C');

        expect(ionian.scale, major.scale);
      });

      test('Dorian starts on 2nd degree of parent major', () {
        final dorian = TheoryEngine.buildModePack('D', 1, 'Dorian');

        expect(dorian.keyLabel, 'D Dorian');
        expect(dorian.scale[0], 'D'); // Root
        expect(dorian.scale, ['D', 'E', 'F', 'G', 'A', 'B', 'C']);
      });

      test('Phrygian starts on 3rd degree', () {
        final phrygian = TheoryEngine.buildModePack('E', 2, 'Phrygian');

        expect(phrygian.keyLabel, 'E Phrygian');
        expect(phrygian.scale[0], 'E');
        expect(phrygian.scale[1], 'F'); // Flat 2nd characteristic
      });

      test('Lydian has raised 4th', () {
        final lydian = TheoryEngine.buildModePack('F', 3, 'Lydian');

        expect(lydian.keyLabel, 'F Lydian');
        expect(lydian.scale[3], 'B'); // Raised 4th (not Bb)
      });

      test('Mixolydian has lowered 7th', () {
        final mixolydian = TheoryEngine.buildModePack('G', 4, 'Mixolydian');

        expect(mixolydian.keyLabel, 'G Mixolydian');
        expect(mixolydian.scale[6], 'F'); // Lowered 7th (not F#)
      });

      test('Aeolian is natural minor', () {
        final aeolian = TheoryEngine.buildModePack('A', 5, 'Aeolian');
        final natMinor = TheoryEngine.buildMinorPack('A', MinorType.natural);

        expect(aeolian.scale, natMinor.scale);
      });

      test('Locrian has flat 2nd and flat 5th', () {
        final locrian = TheoryEngine.buildModePack('B', 6, 'Locrian');

        expect(locrian.keyLabel, 'B Locrian');
        expect(locrian.scale[1], 'C'); // Flat 2nd
        expect(locrian.scale[4], 'F'); // Flat 5th
      });
    });

    group('Mode Characteristics', () {
      test('all 7 modes have characteristics defined', () {
        final modes = ['Ionian', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Aeolian', 'Locrian'];

        for (final mode in modes) {
          expect(
            TheoryEngine.kModeCharacteristics.containsKey(mode),
            isTrue,
            reason: 'Missing characteristics for $mode',
          );
        }
      });

      test('each mode has required fields', () {
        for (final entry in TheoryEngine.kModeCharacteristics.entries) {
          expect(entry.value.containsKey('mood'), isTrue);
          expect(entry.value.containsKey('family'), isTrue);
          expect(entry.value.containsKey('color'), isTrue);
          expect(entry.value.containsKey('usage'), isTrue);
          expect(entry.value.containsKey('character'), isTrue);
        }
      });

      test('major family modes are correctly classified', () {
        expect(TheoryEngine.kModeCharacteristics['Ionian']!['family'], 'Major');
        expect(TheoryEngine.kModeCharacteristics['Lydian']!['family'], 'Major');
        expect(TheoryEngine.kModeCharacteristics['Mixolydian']!['family'], 'Major');
      });

      test('minor family modes are correctly classified', () {
        expect(TheoryEngine.kModeCharacteristics['Dorian']!['family'], 'Minor');
        expect(TheoryEngine.kModeCharacteristics['Phrygian']!['family'], 'Minor');
        expect(TheoryEngine.kModeCharacteristics['Aeolian']!['family'], 'Minor');
      });
    });

    group('Scale Formulas', () {
      test('major scale formula is correct', () {
        expect(TheoryEngine.kScaleFormulas['major'], [0, 2, 4, 5, 7, 9, 11]);
      });

      test('natural minor scale formula is correct', () {
        expect(TheoryEngine.kScaleFormulas['natural_minor'], [0, 2, 3, 5, 7, 8, 10]);
      });

      test('pentatonic scales have 5 notes', () {
        expect(TheoryEngine.kScaleFormulas['pentatonic_major']!.length, 5);
        expect(TheoryEngine.kScaleFormulas['pentatonic_minor']!.length, 5);
      });

      test('blues scale has 6 notes', () {
        expect(TheoryEngine.kScaleFormulas['blues']!.length, 6);
        expect(TheoryEngine.kScaleFormulas['blues'], [0, 3, 5, 6, 7, 10]);
      });
    });

    group('Build Scale Notes', () {
      test('builds C major scale correctly', () {
        final notes = TheoryEngine.buildScaleNotes('C', 'major');
        expect(notes, ['C', 'D', 'E', 'F', 'G', 'A', 'B']);
      });

      test('builds F major with flat', () {
        final notes = TheoryEngine.buildScaleNotes('F', 'major');
        expect(notes, ['F', 'G', 'A', 'Bb', 'C', 'D', 'E']);
      });

      test('builds A natural minor', () {
        final notes = TheoryEngine.buildScaleNotes('A', 'natural_minor');
        expect(notes, ['A', 'B', 'C', 'D', 'E', 'F', 'G']);
      });

      test('builds blues scale', () {
        final notes = TheoryEngine.buildScaleNotes('A', 'blues');
        expect(notes.length, 6);
        expect(notes[0], 'A'); // Root
      });

      test('returns empty for invalid scale type', () {
        final notes = TheoryEngine.buildScaleNotes('C', 'invalid_scale');
        expect(notes, isEmpty);
      });
    });

    group('Roman to Chord', () {
      test('converts major numerals in C', () {
        expect(TheoryEngine.romanToChord('I', 'C'), 'C');
        expect(TheoryEngine.romanToChord('IV', 'C'), 'F');
        expect(TheoryEngine.romanToChord('V', 'C'), 'G');
      });

      test('converts minor numerals in C', () {
        expect(TheoryEngine.romanToChord('ii', 'C'), 'Dm');
        expect(TheoryEngine.romanToChord('iii', 'C'), 'Em');
        expect(TheoryEngine.romanToChord('vi', 'C'), 'Am');
      });

      test('converts diminished numeral', () {
        expect(TheoryEngine.romanToChord('vii°', 'C'), 'B°');
      });

      test('works in different keys', () {
        expect(TheoryEngine.romanToChord('I', 'G'), 'G');
        expect(TheoryEngine.romanToChord('IV', 'G'), 'C');
        expect(TheoryEngine.romanToChord('V', 'G'), 'D');
        expect(TheoryEngine.romanToChord('ii', 'G'), 'Am');
      });
    });

    group('Query Normalization', () {
      test('converts unicode symbols', () {
        expect(TheoryEngine.normalizeUserChordQuery('C♯'), contains('#'));
        expect(TheoryEngine.normalizeUserChordQuery('B♭'), contains('b'));
      });

      test('converts word forms', () {
        expect(TheoryEngine.normalizeUserChordQuery('c sharp'), 'c#');
        expect(TheoryEngine.normalizeUserChordQuery('g flat'), 'gb');
      });

      test('normalizes common variations', () {
        expect(TheoryEngine.normalizeUserChordQuery('Cmajor'), 'cmaj');
        expect(TheoryEngine.normalizeUserChordQuery('Aminor'), 'am');
        expect(TheoryEngine.normalizeUserChordQuery('Cdim'), 'cdim');
      });

      test('removes whitespace and punctuation', () {
        expect(TheoryEngine.normalizeUserChordQuery('C - major'), 'cmaj');
        expect(TheoryEngine.normalizeUserChordQuery('C_7'), 'c7');
      });
    });

    group('Should Show Sounds Like', () {
      test('returns false when no double accidentals', () {
        expect(
          TheoryEngine.shouldShowSoundsLike(['C', 'E', 'G'], ['C', 'E', 'G']),
          isFalse,
        );
      });

      test('returns false when alt is null', () {
        expect(
          TheoryEngine.shouldShowSoundsLike(['F##', 'A#', 'C#'], null),
          isFalse,
        );
      });

      test('returns true when has double accidentals and different alt', () {
        expect(
          TheoryEngine.shouldShowSoundsLike(['F##', 'A#', 'C#'], ['G', 'A#', 'C#']),
          isTrue,
        );
      });

      test('returns false when has double accidentals but same as alt', () {
        expect(
          TheoryEngine.shouldShowSoundsLike(['C##', 'E#', 'G#'], ['C##', 'E#', 'G#']),
          isFalse,
        );
      });
    });

    group('Build Pack (Compat API)', () {
      test('returns major pack for major view', () {
        final pack = TheoryEngine.buildPack('C', KeyView.major, MinorType.natural);
        expect(pack.keyLabel, 'C Major');
      });

      test('returns relative minor pack for minor view', () {
        final pack = TheoryEngine.buildPack('C', KeyView.relativeMinor, MinorType.natural);
        expect(pack.keyLabel, 'A Natural Minor'); // A is relative minor of C
      });

      test('respects minor type parameter', () {
        final harmonic = TheoryEngine.buildPack('C', KeyView.relativeMinor, MinorType.harmonic);
        expect(harmonic.keyLabel, 'A Harmonic Minor');

        final melodic = TheoryEngine.buildPack('C', KeyView.relativeMinor, MinorType.melodic);
        expect(melodic.keyLabel, 'A Melodic Minor');
      });
    });
  });
}
