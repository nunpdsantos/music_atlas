import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/persistence_service.dart';
import '../data/models.dart';
import '../data/repository.dart';
import 'guitar_view_controller.dart';
import 'theory_engine.dart';

/// ------------------------------------------------------------
/// 1) Core Services & App Initialization
/// ------------------------------------------------------------

/// Singleton persistence service for saving/loading settings.
final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});

/// Singleton repository for chord data access.
final repositoryProvider = Provider<MusicRepository>((ref) => MusicRepository());

/// Call this once (main.dart already watches it) to initialize all services.
/// Loads JSON data and restores persisted settings.
final appInitProvider = FutureProvider<void>((ref) async {
  // Initialize persistence first
  final persistence = ref.read(persistenceServiceProvider);
  await persistence.initialize();

  // Load chord repository
  await ref.read(repositoryProvider).initialize();

  // Restore saved settings
  final settings = ref.read(appSettingsProvider.notifier);
  settings.loadFromPersistence(persistence);

  // Restore last selected key
  final circle = ref.read(circleProvider.notifier);
  final lastKey = persistence.getLastSelectedKey();
  circle.selectKey(lastKey);
});

/// ------------------------------------------------------------
/// 2) Circle state (key selection + major/minor view)
/// ------------------------------------------------------------
final circleProvider =
    StateNotifierProvider<CircleNotifier, CircleState>((ref) {
  final persistence = ref.watch(persistenceServiceProvider);
  return CircleNotifier(persistence);
});

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
  CircleNotifier(this._persistence) : super(CircleState());

  final PersistenceService? _persistence;

  void selectKey(String majorRoot) {
    state = state.copyWith(selectedMajorRoot: majorRoot, clearDegree: true);
    _persistence?.setLastSelectedKey(majorRoot);
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
    this.showIntervalLabels = true,
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
  AppSettingsNotifier(this._persistence) : super(const AppSettings());

  final PersistenceService? _persistence;

  /// Load settings from persistence service.
  /// Called during app initialization.
  void loadFromPersistence(PersistenceService persistence) {
    state = AppSettings(
      isDarkMode: persistence.getDarkMode(),
      isLeftHanded: persistence.getLeftHanded(),
      defaultOctaves: persistence.getDefaultOctaves(),
      showIntervalLabels: persistence.getShowIntervalLabels(),
    );
  }

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    _persistence?.setDarkMode(value);
  }

  void setLeftHanded(bool value) {
    state = state.copyWith(isLeftHanded: value);
    _persistence?.setLeftHanded(value);
  }

  void setDefaultOctaves(int value) {
    final clamped = value.clamp(1, 2);
    state = state.copyWith(defaultOctaves: clamped);
    _persistence?.setDefaultOctaves(clamped);
  }

  void setShowIntervalLabels(bool value) {
    state = state.copyWith(showIntervalLabels: value);
    _persistence?.setShowIntervalLabels(value);
  }

  void reset() {
    state = const AppSettings();
    _persistence?.clearAll();
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final persistence = ref.watch(persistenceServiceProvider);
  return AppSettingsNotifier(persistence);
});
