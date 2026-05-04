import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/progress_repository.dart';
import '../domain/models/level.dart';
import '../domain/use_cases/get_levels_use_case.dart';

part 'levels_provider.g.dart';

@riverpod
Future<List<Level>> levels(LevelsRef ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final useCase = GetLevelsUseCase(repo);
  return useCase.execute();
}
