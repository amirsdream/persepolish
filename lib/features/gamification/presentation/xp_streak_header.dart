import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import 'gamification_provider.dart';

class XpStreakHeader extends ConsumerWidget {
  const XpStreakHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learnerProgressProvider);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: progressAsync.when(
        data: (progress) => Row(
          children: [
            _XpChip(xp: progress.totalXp),
            const SizedBox(width: Spacing.sm),
            _StreakChip(days: progress.currentStreakDays),
            const Spacer(),
            _WeeklyBar(
              current: progress.weeklyXpSoFar,
              target: LearnerProgress.weeklyXpTarget,
            ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$xp XP total',
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: AppColors.xpColor.withOpacity(0.15),
            borderRadius: Radii.cardLg,
            border: Border.all(color: AppColors.xpColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, color: AppColors.xpColor, size: 16),
              const SizedBox(width: 3),
              Text(
                '$xp XP',
                style: const TextStyle(
                  color: AppColors.xpColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ).animate(key: ValueKey(xp)).shimmer(duration: Durations.medium),
      );
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$days day streak',
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: AppColors.streakFlame.withOpacity(0.15),
            borderRadius: Radii.cardLg,
            border:
                Border.all(color: AppColors.streakFlame.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 3),
              Text(
                '$days',
                style: const TextStyle(
                  color: AppColors.streakFlame,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({required this.current, required this.target});
  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / target).clamp(0.0, 1.0);
    return Semantics(
      label: 'Weekly XP: $current of $target',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$current / $target XP',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.xpColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
