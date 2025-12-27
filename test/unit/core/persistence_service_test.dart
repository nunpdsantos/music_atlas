import 'package:flutter_test/flutter_test.dart';
import 'package:music_atlas/core/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PersistenceService', () {
    late PersistenceService service;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      service = PersistenceService();
      await service.initialize();
    });

    group('initialization', () {
      test('isInitialized returns true after initialize()', () async {
        final newService = PersistenceService();
        expect(newService.isInitialized, isFalse);

        SharedPreferences.setMockInitialValues({});
        await newService.initialize();

        expect(newService.isInitialized, isTrue);
      });
    });

    group('dark mode', () {
      test('returns false by default', () {
        expect(service.getDarkMode(), isFalse);
      });

      test('saves and retrieves value', () async {
        await service.setDarkMode(true);
        expect(service.getDarkMode(), isTrue);

        await service.setDarkMode(false);
        expect(service.getDarkMode(), isFalse);
      });
    });

    group('left handed', () {
      test('returns true by default', () {
        expect(service.getLeftHanded(), isTrue);
      });

      test('saves and retrieves value', () async {
        await service.setLeftHanded(false);
        expect(service.getLeftHanded(), isFalse);

        await service.setLeftHanded(true);
        expect(service.getLeftHanded(), isTrue);
      });
    });

    group('default octaves', () {
      test('returns 2 by default', () {
        expect(service.getDefaultOctaves(), 2);
      });

      test('saves and retrieves value', () async {
        await service.setDefaultOctaves(1);
        expect(service.getDefaultOctaves(), 1);

        await service.setDefaultOctaves(2);
        expect(service.getDefaultOctaves(), 2);
      });

      test('clamps value to valid range', () async {
        await service.setDefaultOctaves(0);
        expect(service.getDefaultOctaves(), 1);

        await service.setDefaultOctaves(5);
        expect(service.getDefaultOctaves(), 2);
      });
    });

    group('show interval labels', () {
      test('returns true by default', () {
        expect(service.getShowIntervalLabels(), isTrue);
      });

      test('saves and retrieves value', () async {
        await service.setShowIntervalLabels(false);
        expect(service.getShowIntervalLabels(), isFalse);

        await service.setShowIntervalLabels(true);
        expect(service.getShowIntervalLabels(), isTrue);
      });
    });

    group('last selected key', () {
      test('returns C by default', () {
        expect(service.getLastSelectedKey(), 'C');
      });

      test('saves and retrieves value', () async {
        await service.setLastSelectedKey('G');
        expect(service.getLastSelectedKey(), 'G');

        await service.setLastSelectedKey('F#');
        expect(service.getLastSelectedKey(), 'F#');
      });
    });

    group('loadAllSettings', () {
      test('returns all default values', () {
        final settings = service.loadAllSettings();

        expect(settings['isDarkMode'], isFalse);
        expect(settings['isLeftHanded'], isTrue);
        expect(settings['defaultOctaves'], 2);
        expect(settings['showIntervalLabels'], isTrue);
        expect(settings['lastSelectedKey'], 'C');
      });

      test('returns all saved values', () async {
        await service.setDarkMode(true);
        await service.setLeftHanded(false);
        await service.setDefaultOctaves(1);
        await service.setShowIntervalLabels(false);
        await service.setLastSelectedKey('Bb');

        final settings = service.loadAllSettings();

        expect(settings['isDarkMode'], isTrue);
        expect(settings['isLeftHanded'], isFalse);
        expect(settings['defaultOctaves'], 1);
        expect(settings['showIntervalLabels'], isFalse);
        expect(settings['lastSelectedKey'], 'Bb');
      });
    });

    group('clearAll', () {
      test('resets all values to defaults', () async {
        // Set non-default values
        await service.setDarkMode(true);
        await service.setLeftHanded(false);
        await service.setDefaultOctaves(1);
        await service.setShowIntervalLabels(false);
        await service.setLastSelectedKey('Bb');

        // Clear all
        await service.clearAll();

        // Verify defaults
        expect(service.getDarkMode(), isFalse);
        expect(service.getLeftHanded(), isTrue);
        expect(service.getDefaultOctaves(), 2);
        expect(service.getShowIntervalLabels(), isTrue);
        expect(service.getLastSelectedKey(), 'C');
      });
    });

    group('persistence across instances', () {
      test('values persist when creating new service instance', () async {
        // Set values in first instance
        await service.setDarkMode(true);
        await service.setLastSelectedKey('E');

        // Create new instance with same SharedPreferences
        final newService = PersistenceService();
        await newService.initialize();

        // Values should persist
        expect(newService.getDarkMode(), isTrue);
        expect(newService.getLastSelectedKey(), 'E');
      });
    });
  });
}
