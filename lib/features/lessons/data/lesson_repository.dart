import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/content_loader.dart';
import '../domain/models/grammar_unit.dart';

final class LessonRepository {
  const LessonRepository();

  Future<GrammarUnit> loadUnit(String levelId, String unitId) async {
    final path = 'assets/content/$levelId/grammar/$unitId.json';
    final data = await ContentLoader.loadJson(path);
    return GrammarUnit.fromJson(data);
  }

  String? checkpointFromJson(String? json) => json;
}

final lessonRepositoryProvider = Provider<LessonRepository>(
  (_) => const LessonRepository(),
);
