import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/content_loader.dart';
import '../../lessons/domain/models/grammar_unit.dart';
import '../../lessons/presentation/exercise_runner_widget.dart';

// ---------------------------------------------------------------------------
// Provider: loads exam JSON from assets/content/<level>/exam/<setId>.json
// ---------------------------------------------------------------------------

final _examUnitProvider = FutureProvider.autoDispose
    .family<GrammarUnit, ({String levelId, String setId})>((ref, args) async {
  final path =
      'assets/content/${args.levelId}/exam/${args.setId}.json';
  final data = await ContentLoader.loadJson(path);
  return GrammarUnit.fromJson(data);
});

// ---------------------------------------------------------------------------

class ExamSessionScreen extends ConsumerStatefulWidget {
  const ExamSessionScreen({
    super.key,
    required this.levelId,
    required this.setId,
  });

  final String levelId;
  final String setId;

  @override
  ConsumerState<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends ConsumerState<ExamSessionScreen> {
  @override
  Widget build(BuildContext context) {
    final args = (levelId: widget.levelId, setId: widget.setId);
    final unitAsync = ref.watch(_examUnitProvider(args));

    return unitAsync.when(
      data: (unit) => _ExamSessionView(
        unit: unit,
        onComplete: (accuracy) => _onComplete(context, accuracy),
      ),
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: const BackButton()),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.incorrectRed),
                const SizedBox(height: Spacing.md),
                Text(
                  'Could not load exam.\n$e',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onComplete(BuildContext context, double accuracy) {
    // Readiness score: 0-100, proportional to accuracy
    final readiness = (accuracy * 100).round();
    context.pushReplacementNamed(
      'exam-results',
      pathParameters: {
        'levelId': widget.levelId,
        'setId': widget.setId,
      },
      queryParameters: {
        'accuracy': accuracy.toStringAsFixed(4),
        'readiness': '$readiness',
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _ExamSessionView extends ConsumerWidget {
  const _ExamSessionView({
    required this.unit,
    required this.onComplete,
  });

  final GrammarUnit unit;
  final OnSessionComplete onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.onSurface),
        title: Text(
          unit.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          _ExamTimerBadge(exerciseCount: unit.exercises.length),
          const SizedBox(width: Spacing.sm),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: unit.exercises.isEmpty
              ? const Center(child: Text('No questions found in this exam.'))
              : ExerciseRunnerWidget(
                  key: ValueKey(unit.id),
                  exercises: unit.exercises,
                  onComplete: onComplete,
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small badge showing estimated time (2 min per 5 questions, rough heuristic)

class _ExamTimerBadge extends StatelessWidget {
  const _ExamTimerBadge({required this.exerciseCount});
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    final minutes = (exerciseCount / 5).ceil().clamp(1, 60);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined,
              size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            '~$minutes min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
