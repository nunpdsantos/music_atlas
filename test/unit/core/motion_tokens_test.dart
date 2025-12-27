import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_atlas/core/motion_tokens.dart';

void main() {
  group('MotionTokens', () {
    group('durations', () {
      test('quick is shortest', () {
        expect(MotionTokens.quick.inMilliseconds, 150);
      });

      test('standard is 250ms', () {
        expect(MotionTokens.standard.inMilliseconds, 250);
      });

      test('medium is 350ms', () {
        expect(MotionTokens.medium.inMilliseconds, 350);
      });

      test('complex is 500ms', () {
        expect(MotionTokens.complex.inMilliseconds, 500);
      });

      test('slow is longest', () {
        expect(MotionTokens.slow.inMilliseconds, 700);
      });

      test('durations increase in order', () {
        expect(
          MotionTokens.quick < MotionTokens.standard,
          isTrue,
        );
        expect(
          MotionTokens.standard < MotionTokens.medium,
          isTrue,
        );
        expect(
          MotionTokens.medium < MotionTokens.complex,
          isTrue,
        );
        expect(
          MotionTokens.complex < MotionTokens.slow,
          isTrue,
        );
      });
    });

    group('curves', () {
      test('enterCurve is easeOutCubic', () {
        expect(MotionTokens.enterCurve, Curves.easeOutCubic);
      });

      test('exitCurve is easeInCubic', () {
        expect(MotionTokens.exitCurve, Curves.easeInCubic);
      });

      test('smooth is easeInOut', () {
        expect(MotionTokens.smooth, Curves.easeInOut);
      });
    });

    group('staggerDelayForIndex', () {
      test('returns zero for index 0', () {
        final delay = MotionTokens.staggerDelayForIndex(0);
        expect(delay.inMilliseconds, 0);
      });

      test('increases by stagger delay per index', () {
        final delay1 = MotionTokens.staggerDelayForIndex(1);
        final delay2 = MotionTokens.staggerDelayForIndex(2);
        final delay3 = MotionTokens.staggerDelayForIndex(3);

        expect(delay1.inMilliseconds, 50);
        expect(delay2.inMilliseconds, 100);
        expect(delay3.inMilliseconds, 150);
      });

      test('caps at maxItems', () {
        final delay = MotionTokens.staggerDelayForIndex(20, maxItems: 5);
        expect(delay.inMilliseconds, 250); // 5 * 50
      });

      test('handles negative index', () {
        final delay = MotionTokens.staggerDelayForIndex(-1);
        expect(delay.inMilliseconds, 0);
      });
    });

    group('animation values', () {
      test('fade values are 0 to 1', () {
        expect(MotionTokens.fadeInStart, 0.0);
        expect(MotionTokens.fadeInEnd, 1.0);
      });

      test('scale starts slightly smaller', () {
        expect(MotionTokens.scaleStart, 0.95);
        expect(MotionTokens.scaleEnd, 1.0);
      });

      test('slide offset is positive', () {
        expect(MotionTokens.slideUpOffset, greaterThan(0));
      });
    });

    group('getStaggerInterval', () {
      test('first item starts at 0', () {
        final interval = MotionTokens.getStaggerInterval(0);
        expect(interval.begin, 0.0);
      });

      test('intervals progress for each item', () {
        final interval0 = MotionTokens.getStaggerInterval(0);
        final interval1 = MotionTokens.getStaggerInterval(1);
        final interval2 = MotionTokens.getStaggerInterval(2);

        expect(interval1.begin, greaterThan(interval0.begin));
        expect(interval2.begin, greaterThan(interval1.begin));
      });

      test('intervals end within 0-1 range', () {
        for (int i = 0; i < 10; i++) {
          final interval = MotionTokens.getStaggerInterval(i);
          expect(interval.begin, greaterThanOrEqualTo(0.0));
          expect(interval.end, lessThanOrEqualTo(1.0));
        }
      });
    });
  });

  group('DurationExtension', () {
    test('inSecondsDouble converts correctly', () {
      expect(const Duration(milliseconds: 250).inSecondsDouble, 0.25);
      expect(const Duration(milliseconds: 1000).inSecondsDouble, 1.0);
      expect(const Duration(milliseconds: 500).inSecondsDouble, 0.5);
    });
  });
}
