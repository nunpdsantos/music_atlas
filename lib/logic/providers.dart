import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository.dart';
import '../data/models.dart';
import 'theory_engine.dart';
import 'guitar_view_controller.dart';

/// ------------------------------------------------------------
/// 1) Repository & App init
/// ------------------------------------------------------------
final repositoryProvider = Provider<MusicRepository>((ref) => MusicRepository());

/// Call this once (main.dart already watches it) so JSON data is loaded.
final appInitProvider = FutureProvider<void>((ref) async {
  await ref.read(repositoryProvider).initialize();
});

/// ------------------------------------------------------------
/// 2) Circle state (key selection + major/minor view)
/// ------------------------------------------------------------
final circleProvider =
    StateNotifierProvider<CircleNotifier, CircleState>((ref) => CircleNotifier());

class CircleState {
  /// Always store the Major parent (e.g. "C")
  final String selectedMajorRoot;

  final KeyView view;
  final MinorType minorType;

  /// Optional selected scale degree index (0..6), used by UI.
  final int? selectedDegree;

  CircleState({
    this.selectedMajorRoot = 'C',
    this.view = KeyView.major,
    this.minorType = MinorType.natural,
    this.selectedDegree,
  });

  CircleState copyWith({
    String? selectedMajorRoot,
    KeyView? view,
    MinorType? minorType,
    int? selectedDegree,
    bool clearDegree = false,
  }) {
    return CircleState(
      selectedMajorRoot: selectedMajorRoot ?? this.selectedMajorRoot,
      view: view ?? this.view,
      minorType: minorType ?? this.minorType,
      selectedDegree: clearDegree ? null : (selectedDegree ?? this.selectedDegree),
    );
  }
}

class CircleNotifier extends StateNotifier<CircleState> {
  CircleNotifier() : super(CircleState());

  void selectKey(String majorRoot) {
    state = state.copyWith(selectedMajorRoot: majorRoot, clearDegree: true);
  }

  void setView(KeyView view) {
    state = state.copyWith(view: view, clearDegree: true);
  }

  void setMinorType(MinorType type) {
    state = state.copyWith(minorType: type, clearDegree: true);
  }

  void selectDegree(int? degree) {
    state = state.copyWith(selectedDegree: degree);
  }
}

/// Builds the currently selected triad/scale pack for the Circle screen.
final triadPackProvider = Provider<TriadPack>((ref) {
  final state = ref.watch(circleProvider);
  return TheoryEngine.buildPack(state.selectedMajorRoot, state.view, state.minorType);
});

/// ------------------------------------------------------------
/// 3) Fretboard / Piano shared view settings
/// ------------------------------------------------------------
enum FretboardInstrument { guitar, piano }

class FretboardViewState {
  final FretboardInstrument instrument;

  /// These are global UI preferences (not "music theory" state).
  final int octaves; // 1 or 2
  final bool leftHanded;

  const FretboardViewState({
    this.instrument = FretboardInstrument.guitar,
    this.octaves = 1,
    this.leftHanded = true,
  });

  FretboardViewState copyWith({
    FretboardInstrument? instrument,
    int? octaves,
    bool? leftHanded,
  }) {
    return FretboardViewState(
      instrument: instrument ?? this.instrument,
      octaves: octaves ?? this.octaves,
      leftHanded: leftHanded ?? this.leftHanded,
    );
  }
}

class FretboardViewController extends StateNotifier<FretboardViewState> {
  FretboardViewController() : super(const FretboardViewState());

  void setInstrument(FretboardInstrument instrument) {
    state = state.copyWith(instrument: instrument);
  }

  void setOctaves(int octaves) {
    final v = octaves.clamp(1, 2);
    state = state.copyWith(octaves: v);
  }

  void setLeftHanded(bool leftHanded) {
    state = state.copyWith(leftHanded: leftHanded);
  }
}

final fretboardViewProvider =
    StateNotifierProvider<FretboardViewController, FretboardViewState>((ref) {
  return FretboardViewController();
});

/// ------------------------------------------------------------
/// 4) Guitar-only controller (position / start fret)
/// ------------------------------------------------------------
final guitarViewProvider =
    StateNotifierProvider<GuitarViewController, GuitarViewState>((ref) {
  return GuitarViewController();
});

/// ------------------------------------------------------------
/// 5) App Settings
/// ------------------------------------------------------------

class AppSettings {
  final bool isDarkMode;
  final bool isLeftHanded;
  final int defaultOctaves;
  final bool showIntervalLabels;

  const AppSettings({
    this.isDarkMode = false,
    this.isLeftHanded = true,
    this.defaultOctaves = 2,
    this.showIntervalLabels = false,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isLeftHanded,
    int? defaultOctaves,
    bool? showIntervalLabels,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
      defaultOctaves: defaultOctaves ?? this.defaultOctaves,
      showIntervalLabels: showIntervalLabels ?? this.showIntervalLabels,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }

  void setLeftHanded(bool value) {
    state = state.copyWith(isLeftHanded: value);
  }

  void setDefaultOctaves(int value) {
    state = state.copyWith(defaultOctaves: value.clamp(1, 2));
  }

  void setShowIntervalLabels(bool value) {
    state = state.copyWith(showIntervalLabels: value);
  }

  void reset() {
    state = const AppSettings();
  }
}

final appSettingsProvider = 
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
