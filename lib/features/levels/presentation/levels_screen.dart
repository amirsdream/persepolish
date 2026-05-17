import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../features/gamification/presentation/xp_streak_header.dart';
import '../domain/models/level.dart';
import 'level_card_widget.dart';
import 'levels_provider.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Branding header ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 110,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.md, Spacing.md, Spacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appName,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.learnSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: XpStreakHeader(),
              ),
            ),

            // ── Section label ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.md, Spacing.lg, Spacing.md, Spacing.sm),
                child: Text(
                  'Your Learning Path',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ).animate().fadeIn(duration: AppDurations.medium),
            ),

            // ── Level cards list ─────────────────────────────────────────────
            levelsAsync.when(
              data: (levels) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final level = levels[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: LevelCardWidget(
                          level: level,
                          onTap: _onLevelTap(context, level),
                          animationDelay: Duration(milliseconds: index * 80),
                        ),
                      );
                    },
                    childCount: levels.length,
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load levels.\n$e',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
          ],
        ),
      ),
    );
  }

  VoidCallback? _onLevelTap(BuildContext context, Level level) {
    if (level.isComingSoon || !level.isUnlocked) return null;
    return () => context.pushNamed(
          'level-curriculum',
          pathParameters: {'levelId': level.id},
        );
  }
}
