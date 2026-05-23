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

  // Multiple choice & dictation
  int? _selectedOption;

  // Fill blank
  final _textController = TextEditingController();

  // Sentence builder
  List<String> _chosenWords = [];

  @override
  void initState() {
    super.initState();
    // Rebuild when the fill-blank text changes so _canSubmit() is re-evaluated
    _textController.addListener(() => setState(() {}));
  }

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
      if (!_completeFired) {
        _completeFired = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onComplete(session.accuracy);
        });
      }
      return const SizedBox.shrink();
    }

    final exercise = widget.exercises[session.currentIndex];
    final prompt = exercise.localizedPrompt(teachingLang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Scrollable content area ─────────────────────────────────────────
        // Wrapping in Expanded + SingleChildScrollView prevents bottom overflow
        // on small screens (e.g. mobile Chrome) when the feedback banner
        // appears alongside tall input widgets (4-option MC, sentence builder).
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProgressIndicator(
                  current: session.currentIndex + 1,
                  total: widget.exercises.length,
                ),
                const SizedBox(height: Spacing.lg),

                // Prompt — fill_blank renders its own sentence; skip title
                if (exercise is DictationMcExercise)
                  _AudioPrompt(exercise: exercise, answered: _answered)
                else if (exercise is! FillBlankExercise)
                  Semantics(
                    label: 'Question: $prompt',
                    child: Text(
                      prompt,
                      style: Theme.of(context).textTheme.titleLarge,
                      textDirection:
                          isFa ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: isFa ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                const SizedBox(height: Spacing.md),
                const Divider(height: 1, thickness: 1, color: Color(0x1A000000)),
                const SizedBox(height: Spacing.lg),

                // Input widget per exercise type
                AnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: switch (exercise) {
                    MultipleChoiceExercise mc => _MultipleChoiceInput(
                        key: ValueKey(exercise.id),
                        exercise: mc,
                        teachingLang: teachingLang,
                        selectedIndex: _selectedOption,
                        answered: _answered,
                        onSelect: _answered
                            ? null
                            : (i) => setState(() => _selectedOption = i),
                      ),
                    FillBlankExercise fill => _FillBlankInput(
                        key: ValueKey(exercise.id),
                        exercise: fill,
                        teachingLang: teachingLang,
                        controller: _textController,
                        enabled: !_answered,
                      ),
                    DictationMcExercise dictation => _MultipleChoiceInput(
                        key: ValueKey(exercise.id),
                        exercise: MultipleChoiceExercise(
                          id: dictation.id,
                          prompt: dictation.prompt,
                          explanation: dictation.explanation,
                          options: dictation.options,
                          correctIndex: dictation.correctIndex,
                          promptFa: dictation.promptFa,
                          explanationFa: dictation.explanationFa,
                        ),
                        teachingLang: teachingLang,
                        selectedIndex: _selectedOption,
                        answered: _answered,
                        onSelect: _answered
                            ? null
                            : (i) => setState(() => _selectedOption = i),
                      ),
                    SentenceBuilderExercise builder => _SentenceBuilderInput(
                        key: ValueKey(exercise.id),
                        exercise: builder,
                        teachingLang: teachingLang,
                        chosenWords: _chosenWords,
                        enabled: !_answered,
                        onChanged: (words) =>
                            setState(() => _chosenWords = words),
                      ),
                  },
                ),
                const SizedBox(height: Spacing.md),

                // Feedback banner — slides up when answer is submitted.
                // Lives inside the scroll area so it never pushes the button
                // off-screen on short viewports.
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
              ],
            ),
          ),
        ),

        // ── Pinned action button ────────────────────────────────────────────
        // Always visible at the bottom regardless of scroll position.
        const SizedBox(height: Spacing.sm),
        _ActionButton(
          answered: _answered,
          onSubmit: _canSubmit(exercise) ? _onSubmit : null,
          onContinue: _onContinue,
        ),
        const SizedBox(height: Spacing.md),
      ],
    );
  }

  // Guard: prevent onComplete firing more than once per session
  bool _completeFired = false;

  bool _canSubmit(Exercise exercise) => switch (exercise) {
        MultipleChoiceExercise _ => _selectedOption != null,
        FillBlankExercise _ => _textController.text.trim().isNotEmpty,
        DictationMcExercise _ => _selectedOption != null,
        SentenceBuilderExercise _ => _chosenWords.isNotEmpty,
      };

  void _onSubmit() {
    final session = ref.read(exerciseSessionProvider);
    final exercise = widget.exercises[session.currentIndex];
    final dynamic answer = switch (exercise) {
      MultipleChoiceExercise _ => _selectedOption!,
      FillBlankExercise _ => _textController.text.trim(),
      DictationMcExercise _ => _selectedOption!,
      SentenceBuilderExercise _ => List<String>.from(_chosenWords),
    };

    final result = _submitUseCase.execute(exercise: exercise, answer: answer);
    setState(() {
      _lastResult = result;
      _answered = true;
    });
  }

  void _onContinue() {
    ref.read(exerciseSessionProvider.notifier).recordAnswer(
          correct: _lastResult!.isCorrect,
          totalExercises: widget.exercises.length,
        );
    setState(() {
      _answered = false;
      _lastResult = null;
      _selectedOption = null;
      _textController.clear();
      _chosenWords = [];
    });
  }
}

// ── Progress ──────────────────────────────────────────────────────────────────

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final label =
        AppLocalizations.of(context)!.exerciseQuestion(current, total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          child:
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
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

// ── Audio prompt for dictation ────────────────────────────────────────────────

class _AudioPrompt extends StatelessWidget {
  const _AudioPrompt({required this.exercise, required this.answered});
  final DictationMcExercise exercise;
  final bool answered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasAudio = exercise.audioAsset != null;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: Radii.cardMd,
      ),
      child: Row(
        children: [
          Icon(
            hasAudio ? Icons.headphones : Icons.headphones_outlined,
            color: hasAudio ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 32,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              hasAudio
                  ? l10n.exerciseDictationListen
                  : l10n.exerciseDictationNoAudio,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (hasAudio)
            IconButton(
              icon: const Icon(Icons.play_circle_filled),
              color: AppColors.primary,
              iconSize: 40,
              onPressed: () {
                // TODO: play audio via audio_player package
              },
              tooltip: l10n.exerciseDictationListen,
            ),
        ],
      ),
    );
  }
}

// ── Multiple Choice ───────────────────────────────────────────────────────────

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
            label:
                'Option ${i + 1}: ${options[i]}${isSelected ? ", selected" : ""}',
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
              // Options are always Polish (Latin script) — force LTR
              // regardless of the teaching language direction.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: ListTile(
                  onTap: onSelect != null ? () => onSelect!(i) : null,
                  title: Text(options[i],
                      style: Theme.of(context).textTheme.bodyLarge),
                  trailing: answered
                      ? Icon(
                          isCorrect
                              ? Icons.check_circle
                              : (isWrong ? Icons.cancel : null),
                          color: isCorrect
                              ? AppColors.correctGreen
                              : AppColors.incorrectRed,
                        )
                      : null,
                ),
              ),
            ).animate(target: isCorrect || isWrong ? 1 : 0).shake(
                duration: isWrong ? AppDurations.fast : Duration.zero),
          ),
        );
      }),
    );
  }
}

// ── Fill in the Blank ─────────────────────────────────────────────────────────

class _FillBlankInput extends StatelessWidget {
  const _FillBlankInput({
    super.key,
    required this.exercise,
    required this.teachingLang,
    required this.controller,
    required this.enabled,
  });

  final FillBlankExercise exercise;
  final String teachingLang;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFa = teachingLang == 'fa';
    final typed = controller.text;
    final answerLen = exercise.answer.length;

    final baseStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontStyle: FontStyle.italic);

    // ── Resolve display layers from structured fields (new schema) ───────
    // Falls back to legacy prompt string parsing when new fields are absent.
    final String instruction;
    final String polishSentence;  // the full sentence containing '___'
    final String translationNotes;

    if (exercise.sentence != null) {
      // ── New schema: fields are pre-split in the JSON ──────────────────
      final rawContext = isFa
          ? (exercise.contextFa ?? exercise.context)
          : exercise.context;
      instruction = rawContext?.trim().isNotEmpty == true
          ? rawContext!.trim()
          : (isFa ? 'جمله را کامل کنید:' : 'Complete the sentence:');

      polishSentence = exercise.sentence!;

      final rawTranslation = isFa
          ? (exercise.translationFa ?? exercise.translation)
          : exercise.translation;
      translationNotes = rawTranslation?.trim() ?? '';
    } else {
      // ── Legacy schema: parse the combined prompt string ───────────────
      final localizedPrompt = exercise.localizedPrompt(teachingLang);
      final parts = localizedPrompt.split('___');

      // Extract instruction: everything before the last ':'
      String inst = '';
      String polishHead = parts.isNotEmpty ? parts[0] : '';
      if (parts.isNotEmpty) {
        final lastColon = parts[0].lastIndexOf(':');
        if (lastColon != -1) {
          inst = parts[0].substring(0, lastColon + 1).trim();
          polishHead = parts[0].substring(lastColon + 1).trimLeft();
        }
      }
      instruction = inst.isNotEmpty
          ? inst
          : (isFa ? 'جمله را کامل کنید:' : 'Complete the sentence:');

      // Extract translation: everything after the first '(' or '[' in parts[1]
      String polishTail = parts.length > 1 ? parts[1] : '';
      String notes = '';
      if (parts.length > 1) {
        final pIdx = parts[1].indexOf('(');
        final bIdx = parts[1].indexOf('[');
        int splitAt = -1;
        if (pIdx >= 0 && bIdx >= 0) {
          splitAt = pIdx < bIdx ? pIdx : bIdx;
        } else if (pIdx >= 0) {
          splitAt = pIdx;
        } else if (bIdx >= 0) {
          splitAt = bIdx;
        }
        if (splitAt >= 0) {
          polishTail = parts[1].substring(0, splitAt).trimRight();
          notes = parts[1].substring(splitAt).trim();
        }
      }
      polishSentence = '${polishHead}___${polishTail}';
      translationNotes = notes;
    }

    // ── Build the character-slot row ─────────────────────────────────────
    final sentenceParts = polishSentence.split('___');
    final polishStart = sentenceParts.isNotEmpty ? sentenceParts[0] : '';
    final polishEnd = sentenceParts.length > 1 ? sentenceParts[1] : '';

    final slotRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(answerLen, (i) {
        final hasChar = i < typed.length;
        final isActive = i == typed.length && enabled;
        final displayChar = hasChar ? typed[i] : '_';
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.only(bottom: 2),
          constraints: const BoxConstraints(minWidth: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? AppColors.primary
                    : hasChar
                        ? AppColors.primary.withOpacity(0.8)
                        : AppColors.onSurfaceVariant.withOpacity(0.35),
                width: isActive ? 2.5 : 1.5,
              ),
            ),
          ),
          child: Text(
            displayChar,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: hasChar
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant.withOpacity(0.35),
                  fontWeight: hasChar ? FontWeight.bold : FontWeight.w400,
                ),
          ),
        );
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1 ── Instruction / context line (top)
        Text(
          instruction,
          textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isFa ? TextAlign.right : TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Spacing.sm),

        // 2 ── Polish sentence with inline blank slots (always LTR)
        RichText(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            style: baseStyle,
            children: [
              TextSpan(text: polishStart),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: slotRow,
                ),
              ),
              TextSpan(text: polishEnd),
            ],
          ),
        ),

        // 3 ── Translation / grammar notes (smaller, muted, below sentence)
        if (translationNotes.isNotEmpty) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            translationNotes,
            textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isFa ? TextAlign.right : TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],

        // 4 ── Hint (smaller, italic, below translation)
        if (exercise.hint != null) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.exerciseHintLabel(exercise.hint!),
            textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isFa ? TextAlign.right : TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
        const SizedBox(height: Spacing.md),
        TextField(
          controller: controller,
          enabled: enabled,
          autofocus: true,
          maxLength: answerLen,
          decoration: InputDecoration(
            hintText: l10n.exerciseTypeAnswerHint,
            counterText: '', // hide the built-in character counter
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
        if (enabled) ...[
          const SizedBox(height: Spacing.sm),
          _PolishCharPicker(controller: controller),
        ],
      ],
    );
  }
}

// ── Polish character picker ────────────────────────────────────────────────────

class _PolishCharPicker extends StatelessWidget {
  const _PolishCharPicker({required this.controller});
  final TextEditingController controller;

  static const _chars = [
    'ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż',
    'Ą', 'Ć', 'Ę', 'Ł', 'Ń', 'Ó', 'Ś', 'Ź', 'Ż',
  ];

  void _insert(String char) {
    final text = controller.text;
    final sel = controller.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    final newText = text.replaceRange(start, end, char);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + char.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: _chars.map((c) {
        return InkWell(
          onTap: () => _insert(c),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              c,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sentence Builder ──────────────────────────────────────────────────────────

class _SentenceBuilderInput extends StatefulWidget {
  const _SentenceBuilderInput({
    super.key,
    required this.exercise,
    required this.teachingLang,
    required this.chosenWords,
    required this.enabled,
    required this.onChanged,
  });

  final SentenceBuilderExercise exercise;
  final String teachingLang;
  final List<String> chosenWords;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_SentenceBuilderInput> createState() => _SentenceBuilderInputState();
}

class _SentenceBuilderInputState extends State<_SentenceBuilderInput> {
  late List<String> _available;
  late List<String> _chosen;
  bool _shaking = false;

  @override
  void initState() {
    super.initState();
    _resetWords();
  }

  void _resetWords() {
    _available = List.from(widget.exercise.wordBank);
    _chosen = [];
  }

  /// Returns true if [words] is a valid prefix of any correct sequence.
  bool _isValidPrefix(List<String> words) {
    if (words.isEmpty) return true;
    return widget.exercise.correctSequences.any((seq) {
      if (words.length > seq.length) return false;
      for (var i = 0; i < words.length; i++) {
        if (seq[i] != words[i]) return false;
      }
      return true;
    });
  }

  /// True when the chosen words already form a complete correct answer.
  bool get _isChosenComplete => widget.exercise.isCorrect(_chosen);

  void _tapFromBank(String word) {
    if (!widget.enabled || _isChosenComplete) return;
    final next = [..._chosen, word];
    if (_isValidPrefix(next)) {
      setState(() {
        _available.remove(word);
        _chosen.add(word);
      });
      widget.onChanged(List.from(_chosen));
    } else {
      // Wrong word — shake and reset
      setState(() => _shaking = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            _shaking = false;
            _resetWords();
          });
          widget.onChanged([]);
        }
      });
    }
  }

  void _tapFromChosen(String word) {
    if (!widget.enabled) return;
    // Remove from chosen and put back in original bank order
    setState(() {
      final idx = _chosen.lastIndexOf(word);
      _chosen.removeAt(idx);
      _available = List.from(widget.exercise.wordBank)
        ..removeWhere((w) => _chosen.contains(w));
    });
    widget.onChanged(List.from(_chosen));
  }

  @override
  Widget build(BuildContext context) {
    final chosenArea = AnimatedContainer(
      duration: AppDurations.fast,
      constraints: const BoxConstraints(minHeight: 64),
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: _shaking
            ? AppColors.incorrectRed.withOpacity(0.08)
            : AppColors.surfaceVariant,
        borderRadius: Radii.cardMd,
        border: Border.all(
          color: _shaking
              ? AppColors.incorrectRed
              : AppColors.primary.withOpacity(0.4),
          width: _shaking ? 2 : 1,
        ),
      ),
      child: _chosen.isEmpty
          ? Text(
              AppLocalizations.of(context)!.exerciseSentenceBuilderHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            )
          : Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: _chosen
                    .map((w) => _WordChip(
                          word: w,
                          color: AppColors.primary,
                          onTap: () => _tapFromChosen(w),
                        ))
                    .toList(),
              ),
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chosen sentence area — shakes on wrong word
        _shaking
            ? chosenArea
                .animate()
                .shake(hz: 6, duration: const Duration(milliseconds: 400))
            : chosenArea,
        const SizedBox(height: Spacing.sm),
        // Label above the word bank
        Row(children: [
          Icon(Icons.touch_app,
              size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            _isChosenComplete ? '✓ Tap Check Answer' : 'Tap words in order',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _isChosenComplete
                      ? AppColors.correctGreen
                      : AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ]),
        const SizedBox(height: Spacing.xs),
        // Word bank — tap to add; dims when sentence is already complete
        Opacity(
          opacity: _isChosenComplete ? 0.35 : 1.0,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: _available
                  .map((w) => _WordChip(
                        word: w,
                        color: AppColors.secondary,
                        onTap: () => _tapFromBank(w),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.color,
    required this.onTap,
  });
  final String word;
  final Color color;
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
              border: Border.all(color: color, width: 1.5),
            ),
            child: Text(
              word,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      );
}

// ── Feedback banner ───────────────────────────────────────────────────────────

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
            Row(children: [
              Icon(icon, color: border, size: 20),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  result.isCorrect ? correctLabel : wrongLabel,
                  style: TextStyle(
                      color: border,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ]),
            if (!result.isCorrect) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                result.correctDisplay,
                style: TextStyle(
                    color: border,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
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

// ── Action button ─────────────────────────────────────────────────────────────

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
        style:
            ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
        child: Text(l10n.exerciseContinue),
      ),
    );
  }
}
