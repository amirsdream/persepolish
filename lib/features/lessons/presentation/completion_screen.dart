import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../gamification/data/gamification_repository.dart';
import '../../gamification/domain/use_cases/award_xp_use_case.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../../gamification/presentation/star_burst_animation.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({
    super.key,
    required this.levelId,
    required this.unitId,
    required this.stars,
    required this.xpEarned,
    required this.accuracy,
  });

  final String levelId;
  final String unitId;
  final int stars;
  final int xpEarned;
  final double accuracy;

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  bool _xpSaved = false;

  @override
  void initState() {
    super.initState();
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    if (_xpSaved) return;
    _xpSaved = true;

    final repo = ref.read(gamificationRepositoryProvider);
    final awardUseCase = AwardXpUseCase(repo);

    await repo.updateUnitProgress(
      unitId: widget.unitId,
      unitType: 'grammar',
      status: 'complete',
      stars: widget.stars,
      accuracy: widget.accuracy / 100,
      xpEarned: widget.xpEarned,
    );

    final result = await awardUseCase.execute(xpToAdd: widget.xpEarned);

    // Refresh gamification header
    ref.invalidate(learnerProgressProvider);

    if (mounted && result.milestoneReached != null) {
      await Future.delayed(Durations.starBurst);
      if (mounted) {
        context.pushNamed(
          'milestone',
          queryParameters: {
            'type': result.milestoneReached!,
            'value': '${result.totalXp}',
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Title
              Text(
                'Lesson Complete!',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ).animate().fadeIn(duration: Durations.medium),

              const SizedBox(height: Spacing.xl),

              // Stars
              StarBurstAnimation(starCount: widget.stars),

              const SizedBox(height: Spacing.xl),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(
                    icon: Icons.percent,
                    label: '${widget.accuracy.toInt()}%',
                    sublabel: 'Accuracy',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: Spacing.md),
                  _StatChip(
                    icon: Icons.bolt,
                    label: '+${widget.xpEarned}',
                    sublabel: 'XP',
                    color: AppColors.xpColor,
                  ),
                ],
              ).animate().fadeIn(delay: Durations.starBurst, duration: Durations.medium),

              const Spacer(),

              // Retry button
              Semantics(
                label: 'Try again',
                child: OutlinedButton(
                  onPressed: () => context.pushReplacementNamed(
                    'grammar-unit',
                    pathParameters: {
                      'levelId': widget.levelId,
                      'unitId': widget.unitId,
                    },
                  ),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(height: Spacing.sm),

              // Back
              Semantics(
                label: 'Back to curriculum',
                child: ElevatedButton(
                  onPressed: () => context.goNamed(
                    'level-curriculum',
                    pathParameters: {'levelId': widget.levelId},
                  ),
                  child: const Text('Back to Curriculum'),
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: Radii.cardLg,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: Spacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      );
}
