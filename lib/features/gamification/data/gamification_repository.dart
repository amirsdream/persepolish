import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/database/app_database.dart';
import '../domain/models/learner_progress.dart';

final class GamificationRepository {
  const GamificationRepository(this._db);

  final AppDatabase _db;

  Future<void> ensureProfileExists() async {
    final existing = await _db.select(_db.learnerProfiles).get();
    if (existing.isEmpty) {
      await _db.into(_db.learnerProfiles).insert(
            LearnerProfilesCompanion.insert(
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
    }
  }

  Future<LearnerProgress> getProgress() async {
    final profile = await (_db.select(_db.learnerProfiles)..limit(1)).getSingle();
    return LearnerProgress(
      totalXp: profile.totalXp,
      currentStreakDays: profile.currentStreakDays,
      lastActivityDate: profile.lastActivityDate != null
          ? DateTime.tryParse(profile.lastActivityDate!)
          : null,
      weeklyXpSoFar: await _weeklyXp(),
    );
  }

  Future<int> _weeklyXp() async {
    // XP earned in the last 7 days from unit_progress
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final rows = await (_db.select(_db.unitProgress)
          ..where((t) => t.lastAttemptAt.isNotNull()))
        .get();
    return rows
        .where((r) {
          final d = DateTime.tryParse(r.lastAttemptAt ?? '');
          return d != null && d.isAfter(cutoff);
        })
        .fold<int>(0, (sum, r) => sum + r.xpEarned);
  }

  Future<void> addXp(int amount) async {
    await (_db.update(_db.learnerProfiles)).write(
      LearnerProfilesCompanion(
        totalXp: Value(
          (await (_db.select(_db.learnerProfiles)..limit(1)).getSingle())
                  .totalXp +
              amount,
        ),
      ),
    );
  }

  Future<void> updateStreak({
    required int newStreak,
    required String todayIso,
  }) async {
    await (_db.update(_db.learnerProfiles)).write(
      LearnerProfilesCompanion(
        currentStreakDays: Value(newStreak),
        lastActivityDate: Value(todayIso),
      ),
    );
  }

  Future<void> updateUnitProgress({
    required String unitId,
    required String unitType,
    required String status,
    required int stars,
    required double accuracy,
    required int xpEarned,
    String? checkpointExerciseId,
  }) async {
    final existing = await (_db.select(_db.unitProgress)
          ..where((t) => t.unitId.equals(unitId)))
        .getSingleOrNull();

    final now = DateTime.now().toIso8601String();

    if (existing == null) {
      await _db.into(_db.unitProgress).insert(
            UnitProgressCompanion.insert(
              learnerId: 1,
              unitId: unitId,
              unitType: unitType,
              status: Value(status),
              stars: Value(stars),
              bestAccuracy: Value(accuracy),
              xpEarned: Value(xpEarned),
              lastAttemptAt: Value(now),
              sessionCheckpoint: Value(checkpointExerciseId),
            ),
          );
    } else {
      // Never decrease stars
      final newStars = stars > existing.stars ? stars : existing.stars;
      final newAccuracy =
          accuracy > existing.bestAccuracy ? accuracy : existing.bestAccuracy;
      await (_db.update(_db.unitProgress)
            ..where((t) => t.unitId.equals(unitId)))
          .write(
        UnitProgressCompanion(
          status: Value(status),
          stars: Value(newStars),
          bestAccuracy: Value(newAccuracy),
          xpEarned: Value(existing.xpEarned + xpEarned),
          lastAttemptAt: Value(now),
          sessionCheckpoint: Value(checkpointExerciseId),
        ),
      );
    }
  }
}

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(appDatabaseProvider));
});
