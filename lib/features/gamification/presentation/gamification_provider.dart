import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/gamification_repository.dart';
import '../domain/models/learner_progress.dart';

part 'gamification_provider.g.dart';

@riverpod
Future<LearnerProgress> learnerProgress(LearnerProgressRef ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getProgress();
}
