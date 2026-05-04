import '../../../gamification/data/gamification_repository.dart';

final class UpdateStreakUseCase {
  const UpdateStreakUseCase(this._repo);

  final GamificationRepository _repo;

  Future<int> execute() async {
    final progress = await _repo.getProgress();
    final today = _dateOnly(DateTime.now().toUtc());
    final last = progress.lastActivityDate != null
        ? _dateOnly(progress.lastActivityDate!.toUtc())
        : null;

    final int newStreak;

    if (last == null) {
      newStreak = 0;
    } else if (last == today) {
      // Same day — no change
      newStreak = progress.currentStreakDays;
    } else if (_daysDiff(last, today) == 1) {
      // Consecutive day
      newStreak = progress.currentStreakDays + 1;
    } else {
      // Gap — reset
      newStreak = 0;
    }

    await _repo.updateStreak(
      newStreak: newStreak,
      todayIso: today.toIso8601String().split('T').first,
    );
    return newStreak;
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime.utc(dt.year, dt.month, dt.day);

  static int _daysDiff(DateTime a, DateTime b) =>
      b.difference(a).inDays;
}
