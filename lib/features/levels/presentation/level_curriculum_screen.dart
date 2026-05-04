import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/models/level.dart';
import 'levels_provider.dart';

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
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CurriculumView extends StatelessWidget {
  const _CurriculumView({required this.level});
  final Level level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.onSurface),
        title: Text(level.name, style: theme.textTheme.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: level.progressPercent / 100,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(level.color),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          if (level.grammarUnits.isNotEmpty) ...[
            _SectionHeader(title: 'Grammar', icon: Icons.auto_stories),
            const SizedBox(height: Spacing.sm),
            ...level.grammarUnits.map((unit) => _UnitTile(
                  unit: unit,
                  onTap: () => context.pushNamed(
                    'grammar-unit',
                    pathParameters: {
                      'levelId': level.id,
                      'unitId': unit.id,
                    },
                  ),
                )),
            const SizedBox(height: Spacing.lg),
          ],
          if (level.vocabularySets.isNotEmpty) ...[
            _SectionHeader(title: 'Vocabulary', icon: Icons.translate),
            const SizedBox(height: Spacing.sm),
            ...level.vocabularySets.map((unit) => _UnitTile(
                  unit: unit,
                  onTap: () => context.pushNamed(
                    'vocabulary-set',
                    pathParameters: {
                      'levelId': level.id,
                      'unitId': unit.id,
                    },
                  ),
                )),
            const SizedBox(height: Spacing.lg),
          ],
          if (level.examSets.isNotEmpty) ...[
            _SectionHeader(title: 'Exam Prep', icon: Icons.quiz),
            const SizedBox(height: Spacing.sm),
            ...level.examSets.map((unit) => _UnitTile(
                  unit: unit,
                  onTap: () => context.pushNamed(
                    'exam-prep',
                    pathParameters: {'levelId': level.id},
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: Spacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ],
      );
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit, required this.onTap});
  final UnitSummary unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${unit.title}. ${unit.stars} stars. ${unit.status}',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          leading: _StatusIcon(status: unit.status),
          title: Text(unit.title, style: theme.textTheme.titleMedium),
          trailing: _StarsMini(stars: unit.stars),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _bgColor.withOpacity(0.15),
        borderRadius: Radii.cardMd,
      ),
      child: Icon(_icon, color: _bgColor, size: 22),
    );
  }

  Color get _bgColor => switch (status) {
        'complete' => AppColors.success,
        'in_progress' => AppColors.secondary,
        _ => AppColors.onSurfaceVariant,
      };

  IconData get _icon => switch (status) {
        'complete' => Icons.check_circle,
        'in_progress' => Icons.play_circle,
        _ => Icons.circle_outlined,
      };
}

class _StarsMini extends StatelessWidget {
  const _StarsMini({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Icon(
            i < stars ? Icons.star : Icons.star_border,
            color: i < stars ? AppColors.starGold : AppColors.starEmpty,
            size: 14,
          ),
        ),
      );
}
