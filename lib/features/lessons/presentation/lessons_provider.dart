import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/lesson_repository.dart';
import '../domain/models/grammar_unit.dart';

part 'lessons_provider.g.dart';

@riverpod
Future<GrammarUnit> grammarUnit(
  GrammarUnitRef ref, {
  required String levelId,
  required String unitId,
}) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.loadUnit(levelId, unitId);
}

// Tracks session state for the currently active exercise runner
final exerciseSessionProvider =
    StateNotifierProvider.autoDispose<ExerciseSessionNotifier, ExerciseSessionState>(
  (_) => ExerciseSessionNotifier(),
);

final class ExerciseSessionState {
  const ExerciseSessionState({
    this.currentIndex = 0,
    this.correctCount = 0,
    this.totalAnswered = 0,
    this.isComplete = false,
    this.lastResult,
  });

  final int currentIndex;
  final int correctCount;
  final int totalAnswered;
  final bool isComplete;
  final bool? lastResult; // null = not yet answered this exercise

  double get accuracy =>
      totalAnswered == 0 ? 0 : correctCount / totalAnswered;

  ExerciseSessionState copyWith({
    int? currentIndex,
    int? correctCount,
    int? totalAnswered,
    bool? isComplete,
    bool? lastResult,
  }) => ExerciseSessionState(
        currentIndex: currentIndex ?? this.currentIndex,
        correctCount: correctCount ?? this.correctCount,
        totalAnswered: totalAnswered ?? this.totalAnswered,
        isComplete: isComplete ?? this.isComplete,
        lastResult: lastResult,
      );
}

class ExerciseSessionNotifier extends StateNotifier<ExerciseSessionState> {
  ExerciseSessionNotifier() : super(const ExerciseSessionState());

  void recordAnswer({required bool correct, required int totalExercises}) {
    final newCorrect = state.correctCount + (correct ? 1 : 0);
    final newTotal = state.totalAnswered + 1;
    final nextIndex = state.currentIndex + 1;
    final done = nextIndex >= totalExercises;

    state = state.copyWith(
      correctCount: newCorrect,
      totalAnswered: newTotal,
      currentIndex: done ? state.currentIndex : nextIndex,
      isComplete: done,
      lastResult: correct,
    );
  }

  void reset() => state = const ExerciseSessionState();
}
