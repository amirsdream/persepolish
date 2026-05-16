import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/exercise.dart';
import '../domain/use_cases/submit_answer_use_case.dart';
import 'lessons_provider.dart';

typedef OnSessionComplete = void Function(double accuracy);

class ExerciseRunnerWidget extends ConsumerStatefulWidget {
  const ExerciseRunnerWidget({
    super.key,
    required this.exercises,
    required this.onComplete,
  });

  final List<Exercise> exercises;
  final OnSessionComplete onComplete;

  @override
  ConsumerState<ExerciseRunnerWidget> createState() =>
      _ExerciseRunnerWidgetState();
}

class _ExerciseRunnerWidgetState extends ConsumerState<ExerciseRunnerWidget> {
  final _submitUseCase = const SubmitAnswerUseCase();
  AnswerResult? _lastResult;
  bool _answered = false;

  // For fill-in-blank
  final _textController = TextEditingController();

  // For multiple choice
  int? _selectedOption;

  // For sentence order — indices of chosen word order
  List<int> _wordOrder = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(exerciseSessionProvider);
    final teachingLang = ref.watch(teachingLanguageProvider);
    final isFa = teachingLang == 'fa';

    if (session.isComplete) {
      // Notify parent on first render after completion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete(session.accuracy);
      });
      return const SizedBox.shrink();
    }

    final exercise = widget.exercises[session.currentIndex];
    final prompt = exercise.localizedPrompt(teachingLang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress
        _ProgressIndicator(
          current: session.currentIndex + 1,
          total: widget.exercises.length,
        ),
        const SizedBox(height: Spacing.lg),

        // Prompt
        Semantics(
          label: 'Question: $prompt',
          child: Text(
            prompt,
            style: Theme.of(context).textTheme.titleLarge,
            textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // Exercise input
        AnimatedSwitcher(
          duration: AppDurations.fast,
          child: switch (exercise) {
            MultipleChoiceExercise mc => _MultipleChoiceInput(
                key: ValueKey(exercise.id),
                exercise: mc,
                teachingLang: teachingLang,
                selectedIndex: _selectedOption,
                answered: _answered,
                onSelect:
                    _answered ? null : (i) => setState(() => _selectedOption = i),
              ),
            FillInBlankExercise fill => _FillInBlankInput(
                key: ValueKey(exercise.id),
                exercise: fill,
                controller: _textController,
                enabled: !_answered,
              ),
            SentenceOrderExercise order => _SentenceOrderInput(
                key: ValueKey(exercise.id),
                exercise: order,
                currentOrder: _wordOrder,
                enabled: !_answered,
                onOrderChanged: (o) => setState(() => _wordOrder = o),
              ),
          },
        ),
        const SizedBox(height: Spacing.lg),

        // Feedback
        if (_answered && _lastResult != null)
          _FeedbackBanner(
            result: _lastResult!,
            exercise: exercise,
            teachingLang: teachingLang,
          ).animate().slideY(
                begin: 0.3,
                duration: AppDurations.fast,
                curve: Curves.easeOut,
              ),

        const Spacer(),

        // Action button
        _ActionButton(
          answered: _answered,
          onSubmit: _canSubmit(exercise) ? _onSubmit : null,
          onContinue: _onContinue,
        ),
        const SizedBox(height: Spacing.md),
      ],
    );
  }

  bool _canSubmit(Exercise exercise) => switch (exercise) {
        MultipleChoiceExercise _ => _selectedOption != null,
        FillInBlankExercise _ => _textController.text.trim().isNotEmpty,
        SentenceOrderExercise ex => _wordOrder.length == ex.words.length,
      };

  void _onSubmit() {
    final session = ref.read(exerciseSessionProvider);
    final exercise = widget.exercises[session.currentIndex];
    final dynamic answer = switch (exercise) {
      MultipleChoiceExercise _ => _selectedOption!,
      FillInBlankExercise _ => _textController.text.trim(),
      SentenceOrderExercise _ => _wordOrder,
    };

    final result = _submitUseCase.execute(exercise: exercise, answer: answer);
    setState(() {
      _lastResult = result;
      _answered = true;
    });
  }

  void _onContinue() {
    final session = ref.read(exerciseSessionProvider);
    final totalExercises = widget.exercises.length;
    ref.read(exerciseSessionProvider.notifier).recordAnswer(
          correct: _lastResult!.isCorrect,
          totalExercises: totalExercises,
        );
    setState(() {
      _answered = false;
      _lastResult = null;
      _selectedOption = null;
      _textController.clear();
      _wordOrder = [];
    });
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.current,
    required this.total,
  });
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.exerciseQuestion(current, total);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: label,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 6,
            ),
          ),
        ],
      );
  }
}

class _MultipleChoiceInput extends StatelessWidget {
  const _MultipleChoiceInput({
    super.key,
    required this.exercise,
    required this.teachingLang,
    required this.selectedIndex,
    required this.answered,
    required this.onSelect,
  });

  final MultipleChoiceExercise exercise;
  final String teachingLang;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final options = exercise.localizedOptions(teachingLang);
    return Column(
        children: List.generate(options.length, (i) {
          final isSelected = selectedIndex == i;
          final isCorrect = answered && i == exercise.correctIndex;
          final isWrong = answered && isSelected && !isCorrect;

          Color borderColor = AppColors.surfaceVariant;
          if (isCorrect) borderColor = AppColors.correctGreen;
          if (isWrong) borderColor = AppColors.incorrectRed;

          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Semantics(
              label: 'Option ${i + 1}: ${options[i]}${isSelected ? ", selected" : ""}',
              button: true,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.correctGreenLight.withOpacity(0.1)
                      : isWrong
                          ? AppColors.incorrectRedLight.withOpacity(0.1)
                          : isSelected
                              ? AppColors.surfaceVariant
                              : AppColors.surface,
                  borderRadius: Radii.cardMd,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: ListTile(
                  onTap: onSelect != null ? () => onSelect!(i) : null,
                  title: Text(
                    options[i],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: answered
                      ? Icon(
                          isCorrect ? Icons.check_circle : (isWrong ? Icons.cancel : null),
                          color: isCorrect ? AppColors.correctGreen : AppColors.incorrectRed,
                        )
                      : null,
                ),
              ),
            ).animate(
              target: isCorrect || isWrong ? 1 : 0,
            ).shake(duration: isWrong ? AppDurations.fast : Duration.zero),
          );
        }),
      );
  }
}

class _FillInBlankInput extends StatelessWidget {
  const _FillInBlankInput({
    super.key,
    required this.exercise,
    required this.controller,
    required this.enabled,
  });

  final FillInBlankExercise exercise;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.sentenceTemplate.replaceFirst('___', '________'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: controller,
            enabled: enabled,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.exerciseTypeAnswerHint,
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: Radii.cardMd,
                borderSide: BorderSide.none,
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      );
}

class _SentenceOrderInput extends StatefulWidget {
  const _SentenceOrderInput({
    super.key,
    required this.exercise,
    required this.currentOrder,
    required this.enabled,
    required this.onOrderChanged,
  });

  final SentenceOrderExercise exercise;
  final List<int> currentOrder;
  final bool enabled;
  final ValueChanged<List<int>> onOrderChanged;

  @override
  State<_SentenceOrderInput> createState() => _SentenceOrderInputState();
}

class _SentenceOrderInputState extends State<_SentenceOrderInput> {
  late List<int> _available;
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _available = List.generate(widget.exercise.words.length, (i) => i);
    _selected = [];
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected area
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: Radii.cardMd,
            ),
            child: Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: _selected.map((wordIndex) {
                return _WordChip(
                  word: widget.exercise.words[wordIndex],
                  onTap: widget.enabled
                      ? () {
                          setState(() {
                            _selected.remove(wordIndex);
                            _available.add(wordIndex);
                          });
                          widget.onOrderChanged(List.from(_selected));
                        }
                      : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // Available words
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: _available.map((wordIndex) {
              return _WordChip(
                word: widget.exercise.words[wordIndex],
                onTap: widget.enabled
                    ? () {
                        setState(() {
                          _available.remove(wordIndex);
                          _selected.add(wordIndex);
                        });
                        widget.onOrderChanged(List.from(_selected));
                      }
                    : null,
              );
            }).toList(),
          ),
        ],
      );
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.onTap});
  final String word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Semantics(
          label: word,
          button: true,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: Radii.cardMd,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Text(
              word,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      );
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.result,
    required this.exercise,
    required this.teachingLang,
  });
  final AnswerResult result;
  final Exercise exercise;
  final String teachingLang;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final explanation = exercise.localizedExplanation(teachingLang);
    final correctLabel = l10n.exerciseCorrect;
    final wrongLabel = l10n.exerciseIncorrect;
    final isFa = teachingLang == 'fa';

    final bg = result.isCorrect
        ? AppColors.correctGreen.withOpacity(0.12)
        : AppColors.incorrectRed.withOpacity(0.12);
    final border =
        result.isCorrect ? AppColors.correctGreen : AppColors.incorrectRed;
    final icon = result.isCorrect ? Icons.check_circle : Icons.info;

    return Semantics(
      liveRegion: true,
      label: result.isCorrect
          ? '$correctLabel $explanation'
          : '$wrongLabel ${result.correctDisplay}. $explanation',
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: Radii.cardMd,
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: border, size: 20),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    result.isCorrect ? correctLabel : wrongLabel,
                    style: TextStyle(
                        color: border, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ],
            ),
            if (!result.isCorrect) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                result.correctDisplay,
                style: TextStyle(
                    color: border, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
            const SizedBox(height: Spacing.xs),
            Text(
              explanation,
              style: Theme.of(context).textTheme.bodyMedium,
              textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.answered,
    required this.onSubmit,
    required this.onContinue,
  });

  final bool answered;
  final VoidCallback? onSubmit;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!answered) {
      return Semantics(
        label: 'Check answer',
        child: ElevatedButton(
          onPressed: onSubmit,
          child: Text(l10n.exerciseCheckAnswer),
        ),
      );
    }
    return Semantics(
      label: 'Continue to next question',
      child: ElevatedButton(
        onPressed: onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
        ),
        child: Text(l10n.exerciseContinue),
      ),
    );
  }
}
