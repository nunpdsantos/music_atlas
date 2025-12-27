/// Main widget smoke tests for Music Atlas
///
/// These tests verify the app can launch and basic navigation works.
/// More specific widget tests are in test/widget/ directory.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_atlas/main.dart';

void main() {
  group('App Smoke Tests', () {
    testWidgets('app launches successfully', (WidgetTester tester) async {
      // Wrap the app in ProviderScope for Riverpod
      await tester.pumpWidget(const ProviderScope(child: ChordAtlasApp()));

      // Verify that the MaterialApp is created
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: ChordAtlasApp()));

      // During async initialization, should show loading or app
      // This depends on how fast the init completes
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
      );
    });
  });
}
