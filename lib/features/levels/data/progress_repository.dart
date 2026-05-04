import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProgressRepository {
  const ProgressRepository(this._db);

  final AppDatabase _db;

  Future<double> getLevelProgress(String levelId) async {
    // Sum units where status == 'complete' / total units for this level
    final allUnits = await (_db.select(_db.unitProgress)
          ..where((t) => t.unitId.like('$levelId-%')))
        .get();

    if (allUnits.isEmpty) return 0.0;

    final completed = allUnits.where((u) => u.status == 'complete').length;
    return completed / allUnits.length;
  }

  Future<Map<String, String>> getUnitStatuses(String levelId) async {
    final rows = await (_db.select(_db.unitProgress)
          ..where((t) => t.unitId.like('$levelId-%')))
        .get();
    return {for (final r in rows) r.unitId: r.status};
  }

  Future<Map<String, int>> getUnitStars(String levelId) async {
    final rows = await (_db.select(_db.unitProgress)
          ..where((t) => t.unitId.like('$levelId-%')))
        .get();
    return {for (final r in rows) r.unitId: r.stars};
  }

  Future<int> getLearnerId() async {
    final profiles = await _db.select(_db.learnerProfiles).get();
    return profiles.first.id;
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(appDatabaseProvider));
});
