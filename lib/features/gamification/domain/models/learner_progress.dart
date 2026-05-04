final class LearnerProgress {
  const LearnerProgress({
    required this.totalXp,
    required this.currentStreakDays,
    required this.lastActivityDate,
    required this.weeklyXpSoFar,
  });

  final int totalXp;
  final int currentStreakDays;
  final DateTime? lastActivityDate;
  final int weeklyXpSoFar;

  static const int weeklyXpTarget = 500;

  bool get hasStreak => currentStreakDays > 0;
  bool get weeklyTargetReached => weeklyXpSoFar >= weeklyXpTarget;

  LearnerProgress copyWith({
    int? totalXp,
    int? currentStreakDays,
    DateTime? lastActivityDate,
    int? weeklyXpSoFar,
  }) => LearnerProgress(
        totalXp: totalXp ?? this.totalXp,
        currentStreakDays: currentStreakDays ?? this.currentStreakDays,
        lastActivityDate: lastActivityDate ?? this.lastActivityDate,
        weeklyXpSoFar: weeklyXpSoFar ?? this.weeklyXpSoFar,
      );
}
