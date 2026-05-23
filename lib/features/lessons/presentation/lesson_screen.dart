import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/grammar_unit.dart';
import '../domain/use_cases/submit_answer_use_case.dart';
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
    final teachingLang = ref.watch(teachingLanguageProvider);

    return unitAsync.when(
      data: (unit) => _LessonView(
        unit: unit,
        teachingLang: teachingLang,
        // Revision quizzes jump straight to exercises — no explanation card
        showingExercises: _showingExercises || unit.isRevision,
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
    required this.teachingLang,
    required this.showingExercises,
    required this.onStartExercises,
    required this.onComplete,
  });

  final GrammarUnit unit;
  final String teachingLang;
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
        title: Text(unit.localizedTitle(teachingLang),
            style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: Padding(
          // Horizontal padding on both views; vertical only on explanation card.
          // ExerciseRunner manages its own bottom spacing so the pinned button
          // clears the system navigation bar safely.
          padding: showingExercises
              ? const EdgeInsets.symmetric(horizontal: Spacing.md)
              : const EdgeInsets.all(Spacing.md),
          child: AnimatedSwitcher(
            duration: AppDurations.medium,
            child: showingExercises
                ? ExerciseRunnerWidget(
                    key: const ValueKey('runner'),
                    exercises: unit.exercises,
                    onComplete: onComplete,
                  )
                : _ExplanationCard(
                    unit: unit,
                    teachingLang: teachingLang,
                    onStart: onStartExercises,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.unit,
    required this.teachingLang,
    required this.onStart,
  });

  final GrammarUnit unit;
  final String teachingLang;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isFa = teachingLang == 'fa';
    final explanation = unit.localizedExplanation(teachingLang);

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
                        Text(l10n.lessonExplanation,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: AppColors.primary)),
                        const SizedBox(height: Spacing.sm),
                        Semantics(
                          label: explanation,
                          child: Directionality(
                            textDirection:
                                isFa ? TextDirection.rtl : TextDirection.ltr,
                            child: MarkdownBody(
                              data: explanation,
                              styleSheet: _darkMarkdownStyle(theme),
                              softLineBreak: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),

                // Examples
                if (unit.examples.isNotEmpty) ...[
                  Text(l10n.lessonExamples,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: Spacing.sm),
                  ...unit.examples.map((ex) => _ExampleTile(
                        example: ex,
                        teachingLang: teachingLang,
                      )),
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
            label: Text('${l10n.lessonStartExercises} (${unit.exercises.length})'),
          ),
        ),
      ],
    );
  }
}

// ── Dark-mode markdown stylesheet ─────────────────────────────────────────────
//
// Strategy: start from fromTheme() so all base styles inherit from the app's
// dark ThemeData, then copyWith() only the things that look wrong on dark navy.
//
// Root cause of the colour issue:
//   flutter_markdown's tableCellsDecoration defaults to
//   CupertinoColors.systemGrey6.darkColor (#1C1C1E) which shows as near-black
//   zebra stripes on our navy surface (#16213E). We override it with a subtle
//   navy tint instead.

MarkdownStyleSheet _darkMarkdownStyle(ThemeData theme) {
  // Zebra-stripe colour: slightly lighter than surface, on-brand navy
  const zebraStripe = Color(0xFF1A2F55);
  // Code background: dark but distinct from card surface
  const codeBg = Color(0xFF0D1F38);
  // Visible-but-subtle border for tables on dark bg
  final tableBorderColor = AppColors.onSurfaceVariant.withValues(alpha: 0.20);

  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    // Body paragraphs use the full body text colour (not muted variant)
    p: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),

    // Headings: use primary brand colour so ## and ### pop out
    h1: theme.textTheme.titleLarge?.copyWith(
        color: AppColors.primary, height: 1.5),
    h2: theme.textTheme.titleMedium?.copyWith(
        color: AppColors.primary, height: 1.5),
    h3: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.primary, fontWeight: FontWeight.w700, height: 1.4),

    // Strong / em
    strong: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurface, fontWeight: FontWeight.w700),
    em: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurface, fontStyle: FontStyle.italic),

    // Lists
    listBullet: theme.textTheme.bodyLarge?.copyWith(color: AppColors.primary),

    // Tables ─────────────────────────────────────────────────────────────────
    tableHead: theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface,
      fontWeight: FontWeight.w700,
    ),
    tableBody: theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface,
    ),
    tableHeadAlign: TextAlign.center,
    tableBorder: TableBorder.all(color: tableBorderColor, width: 1),
    tableColumnWidth: const FlexColumnWidth(),
    tableCellsPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    // KEY FIX: replace the near-black CupertinoSystemGrey6 zebra stripe with
    // a subtle navy tint that blends with our dark card surface.
    tableCellsDecoration: const BoxDecoration(color: zebraStripe),

    // Block quotes ────────────────────────────────────────────────────────────
    blockquote: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
    blockquoteDecoration: BoxDecoration(
      color: const Color(0xFF0F2347),
      borderRadius: BorderRadius.circular(6),
      border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3)),
    ),
    blockquotePadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

    // Code ────────────────────────────────────────────────────────────────────
    code: theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      color: const Color(0xFFB8D4FF),
      backgroundColor: codeBg,
    ),
    codeblockDecoration: BoxDecoration(
      color: codeBg,
      borderRadius: BorderRadius.circular(8),
    ),
    codeblockPadding: const EdgeInsets.all(12),

    // Horizontal rule
    horizontalRuleDecoration: const BoxDecoration(
      border: Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 1)),
    ),
  );
}

// ── Example tile ──────────────────────────────────────────────────────────────

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example, required this.teachingLang});
  final GrammarExample example;
  final String teachingLang;

  @override
  Widget build(BuildContext context) {
    final isFa = teachingLang == 'fa';
    final translation = isFa
        ? (example.persian ?? example.english)
        : example.english;
    final note = isFa ? (example.noteFa ?? example.note) : example.note;

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Polish (always shown)
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
            // Translation in teaching language
            Semantics(
              label: 'Translation: $translation',
              child: Text(
                translation,
                style: Theme.of(context).textTheme.bodyMedium,
                textDirection:
                    isFa ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
