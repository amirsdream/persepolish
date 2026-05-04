import '../../../core/utils/content_loader.dart';
import '../data/progress_repository.dart';
import '../domain/models/level.dart';

final class GetLevelsUseCase {
  const GetLevelsUseCase(this._progressRepo);

  final ProgressRepository _progressRepo;

  Future<List<Level>> execute() async {
    final data = await ContentLoader.loadJson('assets/content/levels.json');
    final levelsJson = data['levels'] as List<dynamic>;

    final List<Level> levels = [];
    double? previousLevelProgress;

    for (final (index, levelJson) in levelsJson.indexed) {
      final map = levelJson as Map<String, dynamic>;
      final id = map['id'] as String;
      final status = map['status'] as String;

      if (status == 'coming_soon') {
        levels.add(_buildComingSoon(map));
        continue;
      }

      final progress = await _progressRepo.getLevelProgress(id);
      final statuses = await _progressRepo.getUnitStatuses(id);
      final stars = await _progressRepo.getUnitStars(id);

      // Level 0 (A1) is always unlocked; others require prev level ≥ threshold
      final threshold = map['unlock_threshold'] as int;
      final isUnlocked = index == 0 ||
          (previousLevelProgress != null &&
              previousLevelProgress * 100 >= threshold);

      levels.add(_buildAvailable(
        map: map,
        progressPercent: progress * 100,
        isUnlocked: isUnlocked,
        statuses: statuses,
        stars: stars,
      ));

      previousLevelProgress = progress;
    }

    return levels;
  }

  Level _buildAvailable({
    required Map<String, dynamic> map,
    required double progressPercent,
    required bool isUnlocked,
    required Map<String, String> statuses,
    required Map<String, int> stars,
  }) {
    List<UnitSummary> buildSummaries(
        List<dynamic> units, UnitType type) {
      return units.map((u) {
        final m = u as Map<String, dynamic>;
        final id = m['id'] as String;
        return UnitSummary(
          id: id,
          title: m['title'] as String,
          unitType: type,
          order: m['order'] as int,
          status: statuses[id] ?? 'not_started',
          stars: stars[id] ?? 0,
        );
      }).toList();
    }

    return Level(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      status: LevelStatus.available,
      unlockThreshold: map['unlock_threshold'] as int,
      colorHex: map['color_hex'] as String,
      progressPercent: progressPercent,
      isUnlocked: isUnlocked,
      grammarUnits: buildSummaries(
          map['grammar_units'] as List<dynamic>, UnitType.grammar),
      vocabularySets: buildSummaries(
          map['vocabulary_sets'] as List<dynamic>, UnitType.vocabulary),
      examSets: buildSummaries(
          map['exam_sets'] as List<dynamic>, UnitType.exam),
    );
  }

  Level _buildComingSoon(Map<String, dynamic> map) => Level(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        status: LevelStatus.comingSoon,
        unlockThreshold: map['unlock_threshold'] as int,
        colorHex: map['color_hex'] as String,
        progressPercent: 0,
        isUnlocked: false,
        grammarUnits: const [],
        vocabularySets: const [],
        examSets: const [],
      );
}
