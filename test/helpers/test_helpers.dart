/// Test helpers and utilities for Music Atlas tests
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget with necessary providers for testing
Widget createTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Wraps a widget with custom provider overrides
Widget createTestableWidgetWithOverrides(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Common test group wrapper for organized test output
void describeFeature(String feature, void Function() body) {
  group('Feature: $feature', body);
}

/// Helper to create test data for chords
class TestData {
  static const majorScaleC = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const majorScaleG = ['G', 'A', 'B', 'C', 'D', 'E', 'F#'];
  static const majorScaleF = ['F', 'G', 'A', 'Bb', 'C', 'D', 'E'];

  static const naturalMinorA = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  static const harmonicMinorA = ['A', 'B', 'C', 'D', 'E', 'F', 'G#'];
  static const melodicMinorA = ['A', 'B', 'C', 'D', 'E', 'F#', 'G#'];

  // All 12 keys in circle of fifths order
  static const circleOfFifths = [
    'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#', 'Ab', 'Eb', 'Bb', 'F',
  ];

  // Mode names in order
  static const modeNames = [
    'Ionian',
    'Dorian',
    'Phrygian',
    'Lydian',
    'Mixolydian',
    'Aeolian',
    'Locrian',
  ];
}

/// Matcher for lists that ignores order
Matcher containsAllInAnyOrder<T>(Iterable<T> expected) {
  return predicate<Iterable<T>>(
    (actual) {
      final actualList = actual.toList();
      final expectedList = expected.toList();
      if (actualList.length != expectedList.length) return false;
      for (final item in expectedList) {
        if (!actualList.contains(item)) return false;
      }
      return true;
    },
    'contains all items in any order: $expected',
  );
}
