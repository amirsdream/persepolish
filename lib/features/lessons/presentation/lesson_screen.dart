import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/models/grammar_unit.dart';
import 'exercise_runner_widget.dart';
import 'lessons_provider.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    super.key,
    required this.levelId,
    required this.unitId,
  });

  final String levelId;
  final String unitId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _showingExercises = false;

  @override
  Widget build(BuildContext context) {
    final unitAsync = ref.watch(grammarUnitProvider(
      levelId: widget.levelId,
      unitId: widget.unitId,
    ));

    return unitAsync.when(
      data: (unit) => _LessonView(
        unit: unit,
        showingExercises: _showingExercises,
        onStartExercises: () => setState(() => _showingExercises = true),
        onComplete: (accuracy) => _onComplete(context, ref, unit, accuracy),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load lesson: $e')),
      ),
    );
  }

  void _onComplete(
      BuildContext context, WidgetRef ref, GrammarUnit unit, double accuracy) {
    final stars = starsForAccuracy(accuracy);
    final xp = _xpForStars(stars);

    context.pushReplacementNamed(
      'lesson-complete',
      pathParameters: {
        'levelId': widget.levelId,
        'unitId': widget.unitId,
      },
      queryParameters: {
        'stars': '$stars',
        'xp': '$xp',
        'accuracy': '${(accuracy * 100).round()}',
      },
    );
  }

  int _xpForStars(int stars) => switch (stars) {
        3 => 30,
        2 => 20,
        _ => 10,
      };
}

class _LessonView extends StatelessWidget {
  const _LessonView({
    required this.unit,
    required this.showingExercises,
    required this.onStartExercises,
    required this.onComplete,
  });

  final GrammarUnit unit;
  final bool showingExercises;
  final VoidCallback onStartExercises;
  final OnSessionComplete onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.onSurface),
        title: Text(unit.title,
            style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: AnimatedSwitcher(
            duration: Durations.medium,
            child: showingExercises
                ? ExerciseRunnerWidget(
                    key: const ValueKey('runner'),
                    exercises: unit.exercises,
                    onComplete: onComplete,
                  )
                : _ExplanationCard(unit: unit, onStart: onStartExercises),
          ),
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.unit, required this.onStart});
  final GrammarUnit unit;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explanation
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explanation',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: AppColors.primary)),
                        const SizedBox(height: Spacing.sm),
                        Semantics(
                          label: unit.explanation,
                          child: Text(unit.explanation,
                              style: theme.textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),

                // Examples
                if (unit.examples.isNotEmpty) ...[
                  Text('Examples',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: Spacing.sm),
                  ...unit.examples.map((ex) => _ExampleTile(example: ex)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        Semantics(
          label: 'Start exercises — ${unit.exercises.length} questions',
          child: ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: Text('Start Exercises (${unit.exercises.length} questions)'),
          ),
        ),
      ],
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example});
  final GrammarExample example;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Polish: ${example.polish}',
                child: Text(
                  example.polish,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Semantics(
                label: 'English: ${example.english}',
                child: Text(
                  example.english,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (example.note != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  example.note!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),
      );
}
