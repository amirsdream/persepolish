import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'features/gamification/data/gamification_repository.dart';
import 'features/gamification/domain/use_cases/update_streak_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  // Update daily streak on every app launch
  await _initializeAndUpdateStreak(db);

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const LinguaLeapApp(),
    ),
  );
}

Future<void> _initializeAndUpdateStreak(AppDatabase db) async {
  final repo = GamificationRepository(db);

  // Ensure at least one learner profile exists
  await repo.ensureProfileExists();

  final useCase = UpdateStreakUseCase(repo);
  await useCase.execute();
}
