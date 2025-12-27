import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'note_utils.dart';

/// Audio playback service for playing notes and chords.
///
/// Provides a clean interface for playing musical sounds throughout the app.
/// Uses just_audio for playback with piano samples.
///
/// ## Usage
/// ```dart
/// final audioService = AudioService();
/// await audioService.initialize();
///
/// // Play a single note
/// audioService.playNote('C');
///
/// // Play a chord
/// audioService.playChord(['C', 'E', 'G']);
///
/// // Clean up when done
/// audioService.dispose();
/// ```
class AudioService {
  /// Whether audio playback is enabled
  bool _enabled = true;

  /// Whether the service has been initialized
  bool _initialized = false;

  /// Audio players for polyphonic playback (one per voice)
  final List<AudioPlayer> _players = [];

  /// Number of simultaneous voices supported
  static const int _voiceCount = 6;

  /// Current voice index for round-robin playback
  int _currentVoice = 0;

  /// Base path for audio assets
  static const String _audioAssetPath = 'assets/audio/';

  /// Supported note names for audio files
  static const List<String> _noteNames = [
    'C', 'Cs', 'D', 'Ds', 'E', 'F', 'Fs', 'G', 'Gs', 'A', 'As', 'B'
  ];

  /// Get whether audio is enabled
  bool get isEnabled => _enabled;

  /// Get whether service is initialized
  bool get isInitialized => _initialized;

  /// Initialize the audio service.
  ///
  /// Must be called before playing any sounds.
  /// Returns true if initialization was successful.
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Create audio players for polyphonic playback
      for (int i = 0; i < _voiceCount; i++) {
        final player = AudioPlayer();
        _players.add(player);
      }

      _initialized = true;
      debugPrint('AudioService: Initialized with $_voiceCount voices');
      return true;
    } catch (e) {
      debugPrint('AudioService: Failed to initialize - $e');
      return false;
    }
  }

  /// Enable or disable audio playback.
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      stopAll();
    }
  }

  /// Play a single note by name.
  ///
  /// [note] - The note name (e.g., 'C', 'F#', 'Bb')
  /// [octave] - The octave (default 4, middle C)
  /// [velocity] - Volume from 0.0 to 1.0 (default 0.8)
  Future<void> playNote(String note, {int octave = 4, double velocity = 0.8}) async {
    if (!_enabled || !_initialized) return;

    final pitchClass = NoteUtils.pitchClass(note);
    if (pitchClass < 0) {
      debugPrint('AudioService: Invalid note "$note"');
      return;
    }

    await _playPitchClass(pitchClass, octave: octave, velocity: velocity);
  }

  /// Play multiple notes simultaneously (chord).
  ///
  /// [notes] - List of note names
  /// [octave] - Base octave for all notes
  /// [velocity] - Volume from 0.0 to 1.0
  /// [arpeggiate] - If true, plays notes in sequence with slight delay
  Future<void> playChord(
    List<String> notes, {
    int octave = 4,
    double velocity = 0.8,
    bool arpeggiate = false,
    Duration arpeggiateDelay = const Duration(milliseconds: 50),
  }) async {
    if (!_enabled || !_initialized || notes.isEmpty) return;

    if (arpeggiate) {
      // Play notes one by one with delay
      for (int i = 0; i < notes.length; i++) {
        if (i > 0) {
          await Future<void>.delayed(arpeggiateDelay);
        }
        await playNote(notes[i], octave: octave, velocity: velocity);
      }
    } else {
      // Play all notes simultaneously
      await Future.wait(
        notes.map((note) => playNote(note, octave: octave, velocity: velocity)),
      );
    }
  }

  /// Play a note by its pitch class (0-11).
  ///
  /// [pitchClass] - 0=C, 1=C#, 2=D, etc.
  /// [octave] - The octave (4 = middle C octave)
  /// [velocity] - Volume from 0.0 to 1.0
  Future<void> playPitchClass(int pitchClass, {int octave = 4, double velocity = 0.8}) async {
    if (!_enabled || !_initialized) return;
    await _playPitchClass(pitchClass, octave: octave, velocity: velocity);
  }

  /// Internal method to play a pitch class.
  Future<void> _playPitchClass(int pitchClass, {int octave = 4, double velocity = 0.8}) async {
    // Get next available player (round-robin)
    final player = _players[_currentVoice];
    _currentVoice = (_currentVoice + 1) % _voiceCount;

    // Build asset path for this note
    final noteName = _noteNames[pitchClass % 12];
    final assetPath = '$_audioAssetPath$noteName$octave.mp3';

    try {
      // Set volume based on velocity
      await player.setVolume(velocity.clamp(0.0, 1.0));

      // Try to load and play the audio asset
      await player.setAsset(assetPath);
      await player.seek(Duration.zero);
      await player.play();

      debugPrint('AudioService: Playing $noteName$octave');
    } catch (e) {
      // Audio file not found - this is expected until samples are added
      // Log only in debug mode to avoid spam
      debugPrint('AudioService: Sample not found for $noteName$octave ($assetPath)');
    }
  }

  /// Stop all currently playing sounds.
  Future<void> stopAll() async {
    for (final player in _players) {
      await player.stop();
    }
  }

  /// Clean up resources.
  Future<void> dispose() async {
    for (final player in _players) {
      await player.dispose();
    }
    _players.clear();
    _initialized = false;
  }
}

/// Singleton instance of AudioService for easy access.
///
/// Use this for simple cases, or create your own instance for more control.
final audioService = AudioService();
