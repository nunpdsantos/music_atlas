import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting app settings to local storage.
///
/// Uses SharedPreferences for simple key-value persistence.
/// Settings are automatically saved when changed and loaded on app start.
class PersistenceService {
  static const String _keyDarkMode = 'settings_dark_mode';
  static const String _keyLeftHanded = 'settings_left_handed';
  static const String _keyDefaultOctaves = 'settings_default_octaves';
  static const String _keyShowIntervalLabels = 'settings_show_interval_labels';
  static const String _keyLastSelectedKey = 'state_last_selected_key';

  SharedPreferences? _prefs;

  /// Initialize the persistence service.
  /// Must be called before using other methods.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if service is initialized
  bool get isInitialized => _prefs != null;

  // ---------------------------------------------------------------------------
  // Dark Mode
  // ---------------------------------------------------------------------------

  /// Get the saved dark mode preference.
  /// Returns `false` if not set (default to light mode).
  bool getDarkMode() {
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }

  /// Save the dark mode preference.
  Future<bool> setDarkMode(bool value) async {
    return await _prefs?.setBool(_keyDarkMode, value) ?? false;
  }

  // ---------------------------------------------------------------------------
  // Left Handed Mode
  // ---------------------------------------------------------------------------

  /// Get the saved left-handed preference.
  /// Returns `true` if not set (default to left-handed for guitar).
  bool getLeftHanded() {
    return _prefs?.getBool(_keyLeftHanded) ?? true;
  }

  /// Save the left-handed preference.
  Future<bool> setLeftHanded(bool value) async {
    return await _prefs?.setBool(_keyLeftHanded, value) ?? false;
  }

  // ---------------------------------------------------------------------------
  // Default Octaves
  // ---------------------------------------------------------------------------

  /// Get the saved default octaves preference.
  /// Returns `2` if not set.
  int getDefaultOctaves() {
    return _prefs?.getInt(_keyDefaultOctaves) ?? 2;
  }

  /// Save the default octaves preference.
  Future<bool> setDefaultOctaves(int value) async {
    return await _prefs?.setInt(_keyDefaultOctaves, value.clamp(1, 2)) ?? false;
  }

  // ---------------------------------------------------------------------------
  // Show Interval Labels
  // ---------------------------------------------------------------------------

  /// Get the saved show interval labels preference.
  /// Returns `true` if not set.
  bool getShowIntervalLabels() {
    return _prefs?.getBool(_keyShowIntervalLabels) ?? true;
  }

  /// Save the show interval labels preference.
  Future<bool> setShowIntervalLabels(bool value) async {
    return await _prefs?.setBool(_keyShowIntervalLabels, value) ?? false;
  }

  // ---------------------------------------------------------------------------
  // Last Selected Key (for restoring state)
  // ---------------------------------------------------------------------------

  /// Get the last selected musical key.
  /// Returns `'C'` if not set.
  String getLastSelectedKey() {
    return _prefs?.getString(_keyLastSelectedKey) ?? 'C';
  }

  /// Save the last selected musical key.
  Future<bool> setLastSelectedKey(String key) async {
    return await _prefs?.setString(_keyLastSelectedKey, key) ?? false;
  }

  // ---------------------------------------------------------------------------
  // Bulk Operations
  // ---------------------------------------------------------------------------

  /// Load all settings at once.
  /// Returns a map of all persisted settings.
  Map<String, dynamic> loadAllSettings() {
    return {
      'isDarkMode': getDarkMode(),
      'isLeftHanded': getLeftHanded(),
      'defaultOctaves': getDefaultOctaves(),
      'showIntervalLabels': getShowIntervalLabels(),
      'lastSelectedKey': getLastSelectedKey(),
    };
  }

  /// Clear all saved settings (reset to defaults).
  Future<bool> clearAll() async {
    if (_prefs == null) return false;

    await _prefs!.remove(_keyDarkMode);
    await _prefs!.remove(_keyLeftHanded);
    await _prefs!.remove(_keyDefaultOctaves);
    await _prefs!.remove(_keyShowIntervalLabels);
    await _prefs!.remove(_keyLastSelectedKey);

    return true;
  }
}
