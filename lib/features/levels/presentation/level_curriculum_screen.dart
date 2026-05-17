import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/level.dart';
import 'levels_provider.dart';

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

// ── Tab definition ────────────────────────────────────────────────────────────

class _TabDef {
  const _TabDef({
    required this.label,
    required this.icon,
    required this.units,
    required this.unitType,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final List<UnitSummary> units;
  final UnitType unitType;
  final Color accentColor;
}

// ── Main view ─────────────────────────────────────────────────────────────────

class _CurriculumView extends StatelessWidget {
  const _CurriculumView({required this.level});

  final Level level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final levelColor = level.color;

    final tabs = <_TabDef>[
      if (level.grammarUnits.isNotEmpty)
        _TabDef(
          label: l10n.curriculumGrammar,
          icon: Icons.auto_stories_rounded,
          units: level.grammarUnits,
          unitType: UnitType.grammar,
          accentColor: AppColors.accent,
        ),
      if (level.vocabularySets.isNotEmpty)
        _TabDef(
          label: l10n.curriculumVocabulary,
          icon: Icons.translate_rounded,
          units: level.vocabularySets,
          unitType: UnitType.vocabulary,
          accentColor: AppColors.primary,
        ),
      if (level.examSets.isNotEmpty)
        _TabDef(
          label: l10n.curriculumExamPrep,
          icon: Icons.quiz_rounded,
          units: level.examSets,
          unitType: UnitType.exam,
          accentColor: AppColors.secondary,
        ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 168,
                pinned: true,
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.black54,
                forceElevated: innerBoxIsScrolled,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onSurface,
                  ),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _LevelHeader(
                    level: level,
                    lang: lang,
                    color: levelColor,
                  ),
                ),
                bottom: _StyledTabBar(tabs: tabs, levelColor: levelColor),
              ),
            ),
          ],
          body: TabBarView(
            children: tabs
                .map((tab) => _TabContent(tab: tab, level: level))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Level Header (expandable area) ────────────────────────────────────────────

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.level,
    required this.lang,
    required this.color,
  });

  final Level level;
  final String lang;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.22), AppColors.background],
        ),
      ),
      // 56 top inset for status bar + back button row
      padding: const EdgeInsets.fromLTRB(Spacing.md, 68, Spacing.md, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.localizedName(lang),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            level.localizedDescription(lang),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: level.progressPercent / 100,
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                '${level.progressPercent.toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
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

// ── Styled TabBar ─────────────────────────────────────────────────────────────

class _StyledTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _StyledTabBar({required this.tabs, required this.levelColor});

  final List<_TabDef> tabs;
  final Color levelColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: AppColors.surface.withOpacity(0.72),
          child: TabBar(
            tabs: tabs
                .map(
                  (t) => Tab(
                    height: kToolbarHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(t.label),
                      ],
                    ),
                  ),
                )
                .toList(),
            labelColor: levelColor,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: levelColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

// ── Tab Content ───────────────────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  const _TabContent({required this.tab, required this.level});

  final _TabDef tab;
  final Level level;

  VoidCallback _onTap(BuildContext context, UnitSummary unit) => () {
        switch (unit.unitType) {
          case UnitType.grammar:
            context.pushNamed(
              'grammar-unit',
              pathParameters: {'levelId': level.id, 'unitId': unit.id},
            );
          case UnitType.vocabulary:
            context.pushNamed(
              'vocabulary-set',
              pathParameters: {'levelId': level.id, 'setId': unit.id},
            );
          case UnitType.exam:
            context.pushNamed(
              'exam-prep',
              pathParameters: {'levelId': level.id},
            );
        }
      };

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => CustomScrollView(
        slivers: [
          // Inject the overlap so the grid starts below the pinned TabBar
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md, Spacing.md, Spacing.md, 0),
            sliver: tab.unitType == UnitType.exam
                ? _buildExamSliver(ctx)
                : _buildGrid(ctx),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext ctx) => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Spacing.sm,
          mainAxisSpacing: Spacing.sm,
          childAspectRatio: 0.92,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _UnitCard(
            unit: tab.units[i],
            index: i,
            accentColor: tab.accentColor,
            onTap: _onTap(context, tab.units[i]),
          ),
          childCount: tab.units.length,
        ),
      );

  Widget _buildExamSliver(BuildContext ctx) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _ExamCard(
              unit: tab.units[i],
              accentColor: tab.accentColor,
              index: i,
              onTap: _onTap(context, tab.units[i]),
            ),
          ),
          childCount: tab.units.length,
        ),
      );
}

// ── Unit Card (grid tile) ─────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.index,
    required this.accentColor,
    required this.onTap,
  });

  final UnitSummary unit;
  final int index;
  final Color accentColor;
  final VoidCallback onTap;

  Color get _statusColor => switch (unit.status) {
        'complete' => AppColors.success,
        'in_progress' => AppColors.secondary,
        _ => AppColors.onSurfaceVariant,
      };

  IconData get _statusIcon => switch (unit.status) {
        'complete' => Icons.check_circle_rounded,
        'in_progress' => Icons.play_circle_rounded,
        _ => Icons.circle_outlined,
      };

  IconData get _typeIcon => switch (unit.unitType) {
        UnitType.grammar => Icons.auto_stories_rounded,
        UnitType.vocabulary => Icons.translate_rounded,
        UnitType.exam => Icons.quiz_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = unit.localizedTitle(lang);
    final isComplete = unit.status == 'complete';

    return Semantics(
      label: '$title. ${unit.stars} stars. ${unit.status}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: Radii.cardMd,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isComplete
                  ? [
                      accentColor.withOpacity(0.20),
                      AppColors.surface,
                    ]
                  : [AppColors.surface, AppColors.surfaceVariant.withOpacity(0.80)],
            ),
            border: Border.all(
              color: isComplete
                  ? accentColor.withOpacity(0.40)
                  : AppColors.surfaceVariant,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: index badge + status icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(_statusIcon, color: _statusColor, size: 18),
                  ],
                ),

                const SizedBox(height: Spacing.sm),

                // Content-type icon
                Icon(_typeIcon, color: accentColor, size: 26),

                const SizedBox(height: Spacing.xs),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AppColors.onSurface,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: Spacing.xs),

                // Stars
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
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: (index * 35).clamp(0, 500)))
            .fadeIn(duration: AppDurations.medium)
            .slideY(begin: 0.10, duration: AppDurations.medium, curve: Curves.easeOut),
      ),
    );
  }
}

// ── Exam Card (full-width) ────────────────────────────────────────────────────

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.unit,
    required this.accentColor,
    required this.index,
    required this.onTap,
  });

  final UnitSummary unit;
  final Color accentColor;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          borderRadius: Radii.cardLg,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accentColor.withOpacity(0.28), AppColors.surface],
          ),
          border: Border.all(
            color: accentColor.withOpacity(0.50),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.15),
                border: Border.all(color: accentColor.withOpacity(0.50), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.25),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(Icons.quiz_rounded, color: accentColor, size: 30),
            ),

            const SizedBox(width: Spacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.localizedTitle(lang),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: Spacing.xs),
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
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 80))
          .fadeIn(duration: AppDurations.medium)
          .slideX(begin: 0.08, duration: AppDurations.medium, curve: Curves.easeOut),
    );
  }
}
