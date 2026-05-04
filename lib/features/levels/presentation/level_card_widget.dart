import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/models/level.dart';

class LevelCardWidget extends StatelessWidget {
  const LevelCardWidget({
    super.key,
    required this.level,
    required this.onTap,
  });

  final Level level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${level.name}. ${level.isComingSoon ? "Coming soon" : level.isUnlocked ? "${level.progressPercent.toInt()}% complete" : "Locked. Complete previous level to unlock."}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Durations.fast,
          decoration: BoxDecoration(
            borderRadius: Radii.cardLg,
            color: AppColors.surface,
            border: Border.all(
              color: level.isUnlocked && !level.isComingSoon
                  ? level.color.withOpacity(0.5)
                  : AppColors.surfaceVariant,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LevelBadge(color: level.color),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      level.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      level.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (!level.isComingSoon && level.isUnlocked)
                      _ProgressBar(progress: level.progressPercent / 100),
                    if (!level.isComingSoon && level.isUnlocked)
                      const SizedBox(height: Spacing.xs),
                    if (!level.isComingSoon && level.isUnlocked)
                      _StarsRow(stars: level.totalStars),
                  ],
                ),
              ),

              // Lock overlay
              if (!level.isComingSoon && !level.isUnlocked)
                _LockOverlay(),

              // Coming soon overlay
              if (level.isComingSoon)
                _ComingSoonOverlay(),
            ],
          ),
        ).animate().fadeIn(duration: Durations.medium),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: Radii.cardMd,
        ),
        child: Icon(Icons.translate, color: color, size: 22),
      );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          3,
          (i) => Icon(
            i < stars ? Icons.star : Icons.star_border,
            color: i < stars ? AppColors.starGold : AppColors.starEmpty,
            size: 16,
          ),
        ),
      );
}

class _LockOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: Radii.cardLg,
            color: Colors.black.withOpacity(0.55),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: AppColors.onSurfaceVariant, size: 32),
              SizedBox(height: Spacing.xs),
              Text(
                'Complete previous\nlevel to unlock',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ComingSoonOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: Radii.cardLg,
            color: Colors.black.withOpacity(0.45),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.9),
                borderRadius: Radii.cardLg,
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
}
