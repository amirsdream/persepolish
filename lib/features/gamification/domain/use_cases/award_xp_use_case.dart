import '../../../gamification/data/gamification_repository.dart';

final class XpAwardResult {
  const XpAwardResult({
    required this.xpAwarded,
    required this.totalXp,
    required this.milestoneReached,
  });

  final int xpAwarded;
  final int totalXp;
  final String? milestoneReached; // null | 'weekly_xp' | 'streak_7' | 'streak_14' | 'streak_30'
}

final class AwardXpUseCase {
  const AwardXpUseCase(this._repo);

  final GamificationRepository _repo;

  // XP amounts per event (see data-model.md XP Award Table)
  static int xpForStars(int stars, {bool isUpgrade = false}) => switch (stars) {
        3 when isUpgrade => 15,
        3 => 30,
        2 => 20,
        _ => 10,
      };

  static const int xpForVocabSetMastered = 25;
  static const int xpForExamSession = 20;
  static const int xpForStreakMilestone = 50;
  static const int xpForWeeklyTarget = 100;
  static const int weeklyTarget = 500;

  Future<XpAwardResult> execute({
    required int xpToAdd,
  }) async {
    await _repo.addXp(xpToAdd);
    final progress = await _repo.getProgress();

    String? milestone;
    if (progress.weeklyXpSoFar >= weeklyTarget &&
        progress.weeklyXpSoFar - xpToAdd < weeklyTarget) {
      // Just crossed the weekly target this session
      milestone = 'weekly_xp';
      await _repo.addXp(xpForWeeklyTarget);
    }

    return XpAwardResult(
      xpAwarded: xpToAdd,
      totalXp: progress.totalXp,
      milestoneReached: milestone,
    );
  }
}
