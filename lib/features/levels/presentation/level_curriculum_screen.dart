import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/level.dart';
import 'levels_provider.dart';

// ── Chapter grouping helpers ──────────────────────────────────────────────────

/// Extracts the chapter number from a unit ID (e.g. "a1-ch03-l02" → 3).
/// Returns 0 when no chapter marker is found (e.g. level-exam IDs).
int _chapterOf(String id) {
  final m = RegExp(r'ch(\d+)').firstMatch(id);
  return m != null ? int.parse(m.group(1)!) : 0;
}

class _ChapterGroup {
  _ChapterGroup(this.number);

  final int number;
  // grammar items first (in order), then vocab last — built by caller
  final List<UnitSummary> items = [];

  /// Use the vocabulary-set title as the chapter theme; fall back to localised "Chapter N".
  String chapterTitle(String lang, String fallback) {
    final vocab = items
        .where((u) => u.unitType == UnitType.vocabulary)
        .firstOrNull;
    return vocab?.localizedTitle(lang) ?? fallback;
  }

  int get completedCount => items.where((u) => u.isComplete).length;
  int get totalCount => items.length;
  bool get isComplete => totalCount > 0 && completedCount == totalCount;
  bool get isInProgress => completedCount > 0 && !isComplete;
  double get progressFraction => totalCount > 0 ? completedCount / totalCount : 0;
}

List<_ChapterGroup> _buildGroups(Level level) {
  final map = <int, _ChapterGroup>{};

  // Grammar items are already ordered by the provider
  for (final u in level.grammarUnits) {
    final ch = _chapterOf(u.id);
    (map[ch] ??= _ChapterGroup(ch)).items.add(u);
  }
  // Vocab goes at the end of each chapter's pill row
  for (final u in level.vocabularySets) {
    final ch = _chapterOf(u.id);
    (map[ch] ??= _ChapterGroup(ch)).items.add(u);
  }

  return map.values.toList()..sort((a, b) => a.number.compareTo(b.number));
}

// ── Entry point ───────────────────────────────────────────────────────────────

class LevelCurriculumScreen extends ConsumerWidget {
  const LevelCurriculumScreen({super.key, required this.levelId});

  final String levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelsProvider);

    return levelsAsync.when(
      data: (levels) {
        final level = levels.firstWhere(
          (l) => l.id == levelId,
          orElse: () => throw StateError('Level $levelId not found'),
        );
        return _CurriculumView(level: level);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────

class _CurriculumView extends StatelessWidget {
  const _CurriculumView({required this.level});

  final Level level;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final chapters = _buildGroups(level);
    final hasExam = level.examSets.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Pinned header ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.onSurface, size: 20),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _LevelHeader(level: level, lang: lang),
            ),
          ),

          // ── Chapter count label ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.lg, Spacing.md, Spacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.map_rounded,
                    size: 16,
                    color: level.color,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    AppLocalizations.of(context)!.curricChaptersCount(chapters.length),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: level.color,
                          letterSpacing: 0.6,
                        ),
                  ),
                  const Spacer(),
                  if (hasExam)
                    _ExamBadge(color: AppColors.secondary),
                ],
              ),
            ).animate().fadeIn(duration: AppDurations.medium),
          ),

          // ── Chapter sections ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ChapterSection(
                  group: chapters[index],
                  levelId: level.id,
                  levelColor: level.color,
                  sectionIndex: index,
                  lang: lang,
                ),
                childCount: chapters.length,
              ),
            ),
          ),

          // ── Level exam section (if any) ──────────────────────────────────
          if (hasExam)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.sm, Spacing.md, 0),
              sliver: SliverToBoxAdapter(
                child: _ExamSection(
                  units: level.examSets,
                  levelId: level.id,
                  sectionIndex: chapters.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxl)),
        ],
      ),
    );
  }
}

// ── Level header ──────────────────────────────────────────────────────────────

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.level, required this.lang});

  final Level level;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.20), AppColors.background],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(Spacing.md, 64, Spacing.md, Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // CEFR badge + level name inline
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.40)),
                ),
                child: Text(
                  level.id.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  level.localizedName(lang),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          // Master progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: level.progressPercent / 100,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                '${level.progressPercent.toInt()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Chapter section ───────────────────────────────────────────────────────────

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.group,
    required this.levelId,
    required this.levelColor,
    required this.sectionIndex,
    required this.lang,
  });

  final _ChapterGroup group;
  final String levelId;
  final Color levelColor;
  final int sectionIndex;
  final String lang;

  Color _stateColor(Color levelColor) {
    if (group.isComplete) return AppColors.success;
    if (group.isInProgress) return levelColor;
    return AppColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(levelColor);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: Radii.cardMd,
        color: AppColors.surface,
        border: Border.all(
          color: group.isInProgress
              ? levelColor.withOpacity(0.35)
              : AppColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chapter header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.sm, Spacing.sm, Spacing.sm, 0),
            child: Row(
              children: [
                // Number badge (checkmark when complete)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: group.isComplete
                      ? Icon(Icons.check_rounded, color: stateColor, size: 18)
                      : Text(
                          '${group.number}',
                          style: TextStyle(
                            color: stateColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),

                const SizedBox(width: Spacing.sm),

                // Chapter title + fraction
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.chapterTitle(lang, l10n.curricChapterFallback(group.number)),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.curricProgressFraction(group.completedCount, group.totalCount),
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Continue pill for in-progress chapters
                if (group.isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: levelColor, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          l10n.exerciseContinue,
                          style: TextStyle(
                            color: levelColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Thin progress bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.sm, Spacing.xs, Spacing.sm, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: group.progressFraction,
                minHeight: 3,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(stateColor),
              ),
            ),
          ),

          // ── Horizontal lesson pills ────────────────────────────────────
          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(Spacing.sm),
              itemCount: group.items.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                    right: i < group.items.length - 1 ? Spacing.xs : 0),
                child: _LessonPill(
                  unit: group.items[i],
                  levelId: levelId,
                  levelColor: levelColor,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(
          delay: Duration(milliseconds: (sectionIndex * 55).clamp(0, 500)))
        .fadeIn(duration: AppDurations.medium)
        .slideY(
          begin: 0.06,
          duration: AppDurations.medium,
          curve: Curves.easeOut,
        );
  }
}

// ── Lesson pill ───────────────────────────────────────────────────────────────

class _LessonPill extends StatelessWidget {
  const _LessonPill({
    required this.unit,
    required this.levelId,
    required this.levelColor,
  });

  final UnitSummary unit;
  final String levelId;
  final Color levelColor;

  Color _statusColor(Color levelColor) => switch (unit.status) {
        'complete' => AppColors.success,
        'in_progress' => levelColor,
        _ => AppColors.onSurfaceVariant,
      };

  IconData get _typeIcon => switch (unit.unitType) {
        UnitType.grammar => Icons.auto_stories_rounded,
        UnitType.vocabulary => Icons.translate_rounded,
        UnitType.exam => Icons.quiz_rounded,
      };

  void _navigate(BuildContext context) {
    switch (unit.unitType) {
      case UnitType.grammar:
        context.pushNamed(
          'grammar-unit',
          pathParameters: {'levelId': levelId, 'unitId': unit.id},
        );
      case UnitType.vocabulary:
        context.pushNamed(
          'vocabulary-set',
          pathParameters: {'levelId': levelId, 'setId': unit.id},
        );
      case UnitType.exam:
        context.pushNamed(
          'exam-prep',
          pathParameters: {'levelId': levelId},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final sc = _statusColor(levelColor);
    final isComplete = unit.status == 'complete';
    final isInProgress = unit.status == 'in_progress';

    return Semantics(
      label: '${unit.localizedTitle(lang)}. ${unit.status}',
      button: true,
      child: GestureDetector(
        onTap: () => _navigate(context),
        child: Container(
          width: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isComplete
                ? sc.withOpacity(0.10)
                : AppColors.surfaceVariant.withOpacity(0.40),
            border: Border.all(
              color: isComplete || isInProgress
                  ? sc.withOpacity(0.45)
                  : AppColors.surfaceVariant,
              width: isInProgress ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status dot + type icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(_typeIcon, color: sc, size: 18),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sc,
                    ),
                  ),
                ],
              ),

              // Stars (compact) for completed
              if (isComplete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < unit.stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: i < unit.stars
                          ? AppColors.starGold
                          : AppColors.starEmpty,
                      size: 10,
                    ),
                  ),
                )
              else
                // Play icon for not started / in-progress
                Icon(
                  isInProgress
                      ? Icons.play_circle_rounded
                      : Icons.circle_outlined,
                  color: sc,
                  size: 14,
                ),

              // Short title
              Text(
                unit.localizedTitle(lang),
                style: TextStyle(
                  color: AppColors.onSurface.withOpacity(0.85),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Level exam section ────────────────────────────────────────────────────────

class _ExamSection extends StatelessWidget {
  const _ExamSection({
    required this.units,
    required this.levelId,
    required this.sectionIndex,
  });

  final List<UnitSummary> units;
  final String levelId;
  final int sectionIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: AppColors.secondary, size: 16),
            const SizedBox(width: Spacing.xs),
            Text(
              l10n.curriculumExamPrep,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.secondary,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ).animate(
          delay: Duration(milliseconds: (sectionIndex * 55).clamp(0, 600))),

        const SizedBox(height: Spacing.sm),

        ...units.asMap().entries.map((e) {
          final i = e.key;
          final unit = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _ExamCard(
              unit: unit,
              levelId: levelId,
              animIndex: sectionIndex + i,
              lang: lang,
            ),
          );
        }),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.unit,
    required this.levelId,
    required this.animIndex,
    required this.lang,
  });

  final UnitSummary unit;
  final String levelId;
  final int animIndex;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final isComplete = unit.isComplete;
    final stateColor = isComplete ? AppColors.success : AppColors.secondary;

    return GestureDetector(
      onTap: () => context.pushNamed(
        'exam-prep',
        pathParameters: {'levelId': levelId},
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          borderRadius: Radii.cardMd,
          gradient: LinearGradient(
            colors: [
              stateColor.withOpacity(0.18),
              AppColors.surface,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: stateColor.withOpacity(0.40),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stateColor.withOpacity(0.14),
                border: Border.all(
                    color: stateColor.withOpacity(0.45), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: stateColor.withOpacity(0.22), blurRadius: 10)
                ],
              ),
              child: Icon(
                isComplete
                    ? Icons.emoji_events_rounded
                    : Icons.quiz_rounded,
                color: stateColor,
                size: 24,
              ),
            ),

            const SizedBox(width: Spacing.md),

            // Title + stars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.localizedTitle(lang),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Icon(
                        i < unit.stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: i < unit.stars
                            ? AppColors.starGold
                            : AppColors.starEmpty,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      )
          .animate(
              delay: Duration(
                  milliseconds: (animIndex * 55).clamp(0, 700)))
          .fadeIn(duration: AppDurations.medium)
          .slideY(
              begin: 0.06,
              duration: AppDurations.medium,
              curve: Curves.easeOut),
    );
  }
}

// ── Exam badge (shown in top label row) ──────────────────────────────────────

class _ExamBadge extends StatelessWidget {
  const _ExamBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.curricExamBadge,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
