import 'package:flutter_test/flutter_test.dart';
import 'package:persepolish/core/utils/sr_scheduler.dart';

void main() {
  group('SrScheduler — SM-2 algorithm', () {
    final now = DateTime(2026, 5, 3);

    test('first correct answer (quality=4): repetition=1, interval=1', () {
      final result = SrScheduler.schedule(
        repetitionCount: 0,
        easinessFactor: 2.5,
        intervalDays: 0,
        answerQuality: 4,
        now: now,
      );
      expect(result.repetitionCount, equals(1));
      expect(result.intervalDays, equals(1));
      expect(result.mastered, isFalse);
    });

    test('second correct answer (quality=4): repetition=2, interval=6', () {
      final result = SrScheduler.schedule(
        repetitionCount: 1,
        easinessFactor: 2.5,
        intervalDays: 1,
        answerQuality: 4,
        now: now,
      );
      expect(result.repetitionCount, equals(2));
      expect(result.intervalDays, equals(6));
    });

    test('third correct answer: mastered=true, interval grows', () {
      final result = SrScheduler.schedule(
        repetitionCount: 2,
        easinessFactor: 2.5,
        intervalDays: 6,
        answerQuality: 4,
        now: now,
      );
      expect(result.repetitionCount, equals(3));
      expect(result.mastered, isTrue);
      expect(result.intervalDays, equals(15)); // 6 * 2.5 = 15
    });

    test('incorrect answer (quality=1): repetition resets to 0, interval=1', () {
      final result = SrScheduler.schedule(
        repetitionCount: 3,
        easinessFactor: 2.5,
        intervalDays: 15,
        answerQuality: 1,
        now: now,
      );
      expect(result.repetitionCount, equals(0));
      expect(result.intervalDays, equals(1));
      expect(result.mastered, isFalse);
    });

    test('easiness factor decreases on poor answer', () {
      final result = SrScheduler.schedule(
        repetitionCount: 1,
        easinessFactor: 2.5,
        intervalDays: 1,
        answerQuality: 2,
        now: now,
      );
      expect(result.easinessFactor, lessThan(2.5));
    });

    test('easiness factor never drops below 1.3', () {
      // Simulate many poor answers
      var ef = 2.5;
      var rep = 1;
      var interval = 1;
      for (var i = 0; i < 20; i++) {
        final r = SrScheduler.schedule(
          repetitionCount: rep,
          easinessFactor: ef,
          intervalDays: interval,
          answerQuality: 0,
          now: now,
        );
        ef = r.easinessFactor;
        rep = r.repetitionCount;
        interval = r.intervalDays;
      }
      expect(ef, greaterThanOrEqualTo(1.3));
    });

    test('nextReviewDate is set to now + intervalDays', () {
      final result = SrScheduler.schedule(
        repetitionCount: 0,
        easinessFactor: 2.5,
        intervalDays: 0,
        answerQuality: 4,
        now: now,
      );
      final expected = now.add(const Duration(days: 1));
      expect(result.nextReviewDate.year, equals(expected.year));
      expect(result.nextReviewDate.month, equals(expected.month));
      expect(result.nextReviewDate.day, equals(expected.day));
    });
  });
}
