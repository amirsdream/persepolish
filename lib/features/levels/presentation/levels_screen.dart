import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md, Spacing.md, Spacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LinguaLeap',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Learn Polish — A1 to B2',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: const XpStreakHeader(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: Spacing.md),
            ),

            levelsAsync.when(
              data: (levels) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: Spacing.md,
                    mainAxisSpacing: Spacing.md,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final level = levels[index];
                      return LevelCardWidget(
                        level: level,
                        onTap: _onLevelTap(context, level),
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
