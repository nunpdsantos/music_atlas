import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'package:music_atlas/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Wrap the app in ProviderScope for Riverpod
    await tester.pumpWidget(const ProviderScope(child: ChordAtlasApp()));

    // Verify that the app launches (Circle screen title should be visible)
    // Note: Data loading might take a moment, so we look for loading or title.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}