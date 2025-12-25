import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/guitar_data.dart';

/// Guitar-only visual state.
/// This is intentionally NOT shared with piano.
class GuitarViewState {
  /// One of: 0,5,7,9,12 (matches GuitarShapesRepo.positionBuckets)
  final int positionBucket;

  /// Where the fretboard viewport should start (fret index).
  /// For now we map this 1:1 to positionBucket (Open->0, Pos 5->5, etc.).
  final int startFret;

  const GuitarViewState({
    this.positionBucket = 0,
    this.startFret = 0,
  });

  GuitarViewState copyWith({
    int? positionBucket,
    int? startFret,
  }) {
    return GuitarViewState(
      positionBucket: positionBucket ?? this.positionBucket,
      startFret: startFret ?? this.startFret,
    );
  }
}

class GuitarViewController extends StateNotifier<GuitarViewState> {
  GuitarViewController() : super(const GuitarViewState());

  List<int> get buckets => GuitarShapesRepo.positionBuckets;

  void setPositionBucket(int bucket) {
    final allowed = buckets.contains(bucket) ? bucket : 0;
    if (state.positionBucket == allowed && state.startFret == allowed) return;
    state = state.copyWith(positionBucket: allowed, startFret: allowed);
  }

  /// Optional: later you might want a finer control than buckets.
  void setStartFret(int startFret) {
    final v = startFret.clamp(0, 24);
    if (state.startFret == v) return;
    state = state.copyWith(startFret: v);
  }

  void reset() {
    state = const GuitarViewState(positionBucket: 0, startFret: 0);
  }
}
