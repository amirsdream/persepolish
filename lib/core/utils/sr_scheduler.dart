/// SM-2 Spaced Repetition Scheduler (pure Dart, no Flutter dependencies).
///
/// Algorithm: SuperMemo 2 (SM-2)
/// Input quality scale: 0 = complete blackout, 1 = incorrect, 2 = incorrect with hint,
///   3 = correct with difficulty, 4 = correct, 5 = perfect recall
///
/// For vocabulary quiz: map correct answer → quality 4, incorrect → quality 1.
final class SrScheduler {
  const SrScheduler._();

  static SrResult schedule({
    required int repetitionCount,
    required double easinessFactor,
    required int intervalDays,
    required int answerQuality, // 0–5
    required DateTime now,
  }) {
    assert(answerQuality >= 0 && answerQuality <= 5);

    final int newRepetition;
    final int newInterval;

    if (answerQuality >= 3) {
      // Correct recall
      newRepetition = repetitionCount + 1;
      newInterval = switch (repetitionCount) {
        0 => 1,
        1 => 6,
        _ => (intervalDays * easinessFactor).round(),
      };
    } else {
      // Incorrect — reset repetition, short interval
      newRepetition = 0;
      newInterval = 1;
    }

    // Update easiness factor (clamped to minimum 1.3)
    final double newEf = (easinessFactor +
            0.1 -
            (5 - answerQuality) * (0.08 + (5 - answerQuality) * 0.02))
        .clamp(1.3, double.infinity);

    final DateTime nextReview = now.add(Duration(days: newInterval));
    final bool mastered = newRepetition >= 3;

    return SrResult(
      repetitionCount: newRepetition,
      easinessFactor: newEf,
      intervalDays: newInterval,
      nextReviewDate: nextReview,
      mastered: mastered,
    );
  }
}

final class SrResult {
  const SrResult({
    required this.repetitionCount,
    required this.easinessFactor,
    required this.intervalDays,
    required this.nextReviewDate,
    required this.mastered,
  });

  final int repetitionCount;
  final double easinessFactor;
  final int intervalDays;
  final DateTime nextReviewDate;
  final bool mastered;
}
