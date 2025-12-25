// lib/data/guitar_data.dart
//
// Guitar chord/triad grip repository.
// - Keeps UI/theory spelling separate: grips work on pitch-classes (12-TET) + standard tuning.
// - Provides barre grips (E/A shapes) + triad grips (3-string sets) across positions with inversions.

import 'dart:math' as math;
import '../logic/theory_engine.dart';

// Map string index (0=Low E, 5=High E) to Fret Number.
// -1 indicates a muted/unplayed string. 0 is an open string.
typedef StringFretMap = Map<int, int>;

class GuitarChordShape {
  /// Short human label shown in the UI (do NOT put theory spellings here; it’s a grip label).
  final String label;

  /// Frets per string index (0..5). Missing keys are treated as muted.
  final StringFretMap frets;

  /// Lowest played fret in this shape (0 for open shapes). Used for “position” bucketing.
  final int baseFret;

  /// 0=root position, 1=1st inversion, 2=2nd inversion. Null means “not applicable / unknown”.
  final int? inversion;

  /// One of: 0, 5, 7, 9, 12 (or other). Null means “not bucketed”.
  final int? positionBucket;

  /// True if this is a 3-note triad grip.
  final bool isTriad;

  /// Optional descriptor: e.g. "DGB", "GBE", "ADG", "EAD"
  final String? stringSet;

  const GuitarChordShape({
    required this.label,
    required this.frets,
    required this.baseFret,
    this.inversion,
    this.positionBucket,
    this.isTriad = false,
    this.stringSet,
  });

  /// Convenience for creating a shape from a full 6-string list.
  factory GuitarChordShape.fromList({
    required String label,
    required List<int> frets6,
    int? inversion,
    int? positionBucket,
    bool isTriad = false,
    String? stringSet,
  }) {
    assert(frets6.length == 6);
    final map = <int, int>{};
    for (int i = 0; i < 6; i++) {
      map[i] = frets6[i];
    }
    final bf = _computeBaseFret(map);
    return GuitarChordShape(
      label: label,
      frets: map,
      baseFret: bf,
      inversion: inversion,
      positionBucket: positionBucket,
      isTriad: isTriad,
      stringSet: stringSet,
    );
  }

  static int _computeBaseFret(StringFretMap frets) {
    int? minF;
    for (final f in frets.values) {
      if (f < 0) continue;
      if (minF == null || f < minF) minF = f;
    }
    return minF ?? 0;
  }
}

/// Standard tuning (E A D G B E).
/// - Pitch-class for each open string (mod 12)
/// - Absolute MIDI-ish semitone numbers for each open string to enforce ascending voicings.
class _Tuning {
  // Pitch classes: E=4, A=9, D=2, G=7, B=11, E=4
  static const List<int> openPc = [4, 9, 2, 7, 11, 4];

  // MIDI numbers for open strings: E2=40, A2=45, D3=50, G3=55, B3=59, E4=64
  static const List<int> openMidi = [40, 45, 50, 55, 59, 64];
}

/// Repo provides:
/// - Barre grips for major/minor triads (E-shape and A-shape)
/// - Triad grips on 3-string sets (EAD, ADG, DGB, GBE) across positions with inversions
class GuitarShapesRepo {
  /// Positions exposed in UI.
  static const List<int> positionBuckets = [0, 5, 7, 9, 12];

  static List<GuitarChordShape> getShapesFor(String root, String quality) {
    final q = quality.trim().toLowerCase();

    final bool isDiminished = q.contains('dim') || q.contains('°');
    final bool isAugmented = q.contains('aug') || q.contains('+');
    final bool isMinor = _isMinorQuality(q) && !isDiminished && !isAugmented;

    final int? rootPc = TheoryEngine.pitchClass(root);
    if (rootPc == null) return const [];

    // Triad pitch-classes.
    // Major: R, M3, P5
    // Minor: R, m3, P5
    // Dim:   R, m3, d5
    // Aug:   R, M3, #5
    final int thirdPc = (isMinor || isDiminished) ? (rootPc + 3) % 12 : (rootPc + 4) % 12;
    final int fifthPc = isDiminished
        ? (rootPc + 6) % 12
        : (isAugmented ? (rootPc + 8) % 12 : (rootPc + 7) % 12);

    final triadPcs = <int>{rootPc, thirdPc, fifthPc};

    final shapes = <GuitarChordShape>[];

    // 1) Common barre grips (very playable). Skip dim/aug here.
    shapes.addAll(_barreGrips(rootPc, isMinor, isDiminished, isAugmented));

    // 2) Triad grips across positions + inversions.
    for (final pos in positionBuckets) {
      shapes.addAll(_triadsForPosition(
        pos: pos,
        triadPcs: triadPcs,
        rootPc: rootPc,
        thirdPc: thirdPc,
        fifthPc: fifthPc,
        qualityLabel: _qualityLabel(isMinor: isMinor, isDim: isDiminished, isAug: isAugmented),
      ));
    }

    // Stable ordering for UI:
    shapes.sort((a, b) {
      final pa = a.positionBucket ?? 999;
      final pb = b.positionBucket ?? 999;
      if (pa != pb) return pa.compareTo(pb);
      if (a.baseFret != b.baseFret) return a.baseFret.compareTo(b.baseFret);
      if (a.isTriad != b.isTriad) return (a.isTriad ? 0 : 1) - (b.isTriad ? 0 : 1);
      return a.label.compareTo(b.label);
    });

    return shapes;
  }

  static bool _isMinorQuality(String q) {
    // "m" but NOT "maj" to avoid "maj7".
    if (q.contains('minor')) return true;
    if (q.contains('m') && !q.contains('maj')) return true;
    return false;
  }

  static String _qualityLabel({required bool isMinor, required bool isDim, required bool isAug}) {
    if (isDim) return 'dim';
    if (isAug) return 'aug';
    if (isMinor) return 'm';
    return '';
  }

  // ---------- Barre grips (E-shape and A-shape) ----------

  static List<GuitarChordShape> _barreGrips(int rootPc, bool isMinor, bool isDim, bool isAug) {
    if (isDim || isAug) return const [];

    final out = <GuitarChordShape>[];

    // E-shape barre (root on low E string)
    final eRootFret = _nearestFretForPcOnString(targetPc: rootPc, stringIndex: 0, minFret: 0);
    if (eRootFret != null) {
      final f = eRootFret;
      final frets = isMinor
          ? [f, f + 2, f + 2, f, f, f] // Em-shape barre
          : [f, f + 2, f + 2, f + 1, f, f]; // E-shape barre
      out.add(GuitarChordShape.fromList(
        label: isMinor ? 'E-shape barre (m)' : 'E-shape barre',
        frets6: frets,
        inversion: 0,
        positionBucket: _bucketForBaseFret(f),
        isTriad: false,
        stringSet: 'EADGBE',
      ));
    }

    // A-shape barre (root on A string)
    final aRootFret = _nearestFretForPcOnString(targetPc: rootPc, stringIndex: 1, minFret: 0);
    if (aRootFret != null) {
      final f = aRootFret;
      final frets = isMinor
          ? [-1, f, f + 2, f + 2, f + 1, f] // Am-shape barre
          : [-1, f, f + 2, f + 2, f + 2, f]; // A-shape barre
      out.add(GuitarChordShape.fromList(
        label: isMinor ? 'A-shape barre (m)' : 'A-shape barre',
        frets6: frets,
        inversion: 0,
        positionBucket: _bucketForBaseFret(f),
        isTriad: false,
        stringSet: 'ADGBE',
      ));
    }

    return out;
  }

  static int _bucketForBaseFret(int baseFret) {
    if (baseFret <= 1) return 0;
    int best = 5;
    int bestDist = (baseFret - 5).abs();
    for (final p in positionBuckets.skip(1)) {
      final d = (baseFret - p).abs();
      if (d < bestDist) {
        best = p;
        bestDist = d;
      }
    }
    return best;
  }

  static int? _nearestFretForPcOnString({
    required int targetPc,
    required int stringIndex,
    required int minFret,
    int maxFret = 12,
  }) {
    int? best;
    int bestDist = 999;
    for (int f = minFret; f <= maxFret; f++) {
      final pc = (_Tuning.openPc[stringIndex] + f) % 12;
      if (pc != targetPc) continue;
      final dist = (f - minFret).abs();
      if (dist < bestDist) {
        bestDist = dist;
        best = f;
      }
    }
    return best;
  }

  // ---------- Triads (3-string grips + inversions) ----------

  static const List<_StringSet> _triadStringSets = [
    _StringSet(name: 'EAD', strings: [0, 1, 2]),
    _StringSet(name: 'ADG', strings: [1, 2, 3]),
    _StringSet(name: 'DGB', strings: [2, 3, 4]),
    _StringSet(name: 'GBE', strings: [3, 4, 5]),
  ];

  static List<GuitarChordShape> _triadsForPosition({
    required int pos,
    required Set<int> triadPcs,
    required int rootPc,
    required int thirdPc,
    required int fifthPc,
    required String qualityLabel,
  }) {
    final out = <GuitarChordShape>[];

    final bassPcs = [rootPc, thirdPc, fifthPc];

    for (final set in _triadStringSets) {
      for (int inv = 0; inv < 3; inv++) {
        final desiredBassPc = bassPcs[inv];

        final cand = _searchTriadGrip(
          set: set,
          pos: pos,
          triadPcs: triadPcs,
          desiredBassPc: desiredBassPc,
        );

        if (cand == null) continue;

        final label = _buildTriadLabel(
          setName: set.name,
          pos: pos,
          inv: inv,
          qualityLabel: qualityLabel,
        );

        out.add(GuitarChordShape.fromList(
          label: label,
          frets6: cand.frets6,
          inversion: inv,
          positionBucket: pos,
          isTriad: true,
          stringSet: set.name,
        ));
      }
    }

    return out;
  }

  static String _buildTriadLabel({
    required String setName,
    required int pos,
    required int inv,
    required String qualityLabel,
  }) {
    final invLabel = inv == 0 ? 'Root' : (inv == 1 ? '1st inv' : '2nd inv');
    final posLabel = pos == 0 ? 'Open' : 'Pos $pos';
    final q = qualityLabel.isEmpty ? '' : ' $qualityLabel';
    return 'Triad$q • $setName • $invLabel • $posLabel';
  }

  static _TriadCandidate? _searchTriadGrip({
    required _StringSet set,
    required int pos,
    required Set<int> triadPcs,
    required int desiredBassPc,
  }) {
    // Search window:
    // - Open bucket: allow frets 0..5 (captures open-string triads)
    // - Other buckets: allow pos..pos+5
    final int minF = (pos == 0) ? 0 : pos;
    final int maxF = (pos == 0) ? 5 : math.min(12, pos + 5);

    final s0 = set.strings[0];
    final s1 = set.strings[1];
    final s2 = set.strings[2];

    _TriadCandidate? best;
    double bestScore = 1e9;

    for (int f0 = minF; f0 <= maxF; f0++) {
      final pc0 = (_Tuning.openPc[s0] + f0) % 12;
      if (pc0 != desiredBassPc) continue;
      if (!triadPcs.contains(pc0)) continue;

      final p0 = _Tuning.openMidi[s0] + f0;

      for (int f1 = minF; f1 <= maxF; f1++) {
        final pc1 = (_Tuning.openPc[s1] + f1) % 12;
        if (!triadPcs.contains(pc1)) continue;

        final p1 = _Tuning.openMidi[s1] + f1;
        if (p1 <= p0) continue;

        for (int f2 = minF; f2 <= maxF; f2++) {
          final pc2 = (_Tuning.openPc[s2] + f2) % 12;
          if (!triadPcs.contains(pc2)) continue;

          final p2 = _Tuning.openMidi[s2] + f2;
          if (p2 <= p1) continue;

          final pcsUsed = {pc0, pc1, pc2};
          if (pcsUsed.length != 3) continue; // must include all triad tones

          final span = math.max(f0, math.max(f1, f2)) - math.min(f0, math.min(f1, f2));
          if (pos != 0 && span > 4) continue; // keep compact in higher positions

          final avg = (f0 + f1 + f2) / 3.0;

          // Score: span first, then average, then closeness to position start.
          final score = (span * 10.0) +
              avg +
              (pos == 0 ? 0.0 : (math.min(f0, math.min(f1, f2)) - pos).abs() * 0.5);

          if (score < bestScore) {
            bestScore = score;

            final frets6 = List<int>.filled(6, -1);
            frets6[s0] = f0;
            frets6[s1] = f1;
            frets6[s2] = f2;

            best = _TriadCandidate(frets6: frets6);
          }
        }
      }
    }

    return best;
  }
}

class _StringSet {
  final String name;
  final List<int> strings; // length 3, low->high
  const _StringSet({required this.name, required this.strings});
}

class _TriadCandidate {
  final List<int> frets6; // 6-length, -1 muted
  const _TriadCandidate({required this.frets6});
}
