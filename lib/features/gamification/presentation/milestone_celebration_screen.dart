import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';

class MilestoneCelebrationScreen extends StatefulWidget {
  const MilestoneCelebrationScreen({
    super.key,
    required this.type,
    required this.value,
  });

  final String type; // weekly_xp | streak | level_complete
  final int value;

  @override
  State<MilestoneCelebrationScreen> createState() =>
      _MilestoneCelebrationScreenState();
}

class _MilestoneCelebrationScreenState
    extends State<MilestoneCelebrationScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 4 seconds
    Future.delayed(AppDurations.milestone, () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background.withOpacity(0.92),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    duration: AppDurations.slow,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: Spacing.lg),
              Text(
                _title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.starGold,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: AppDurations.fast, duration: AppDurations.medium),
              const SizedBox(height: Spacing.md),
              Text(
                _subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: AppDurations.medium, duration: AppDurations.medium),
              const SizedBox(height: Spacing.xxl),
              const Text(
                'Tap anywhere to continue',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ).animate(
                onPlay: (c) => c.repeat(reverse: true),
              ).fadeIn(duration: AppDurations.slow),
            ],
          ),
        ),
      ),
    );
  }

  String get _title => switch (widget.type) {
        'weekly_xp' => 'Week Champion! 🏆',
        'streak' => '${widget.value}-Day Streak! 🔥',
        _ => 'Level Complete! ⭐',
      };

  String get _subtitle => switch (widget.type) {
        'weekly_xp' => 'You reached ${widget.value} XP this week!',
        'streak' => 'You\'ve been practicing every day!',
        _ => 'Amazing progress!',
      };
}
