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
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Branding header (pinned, handles RTL) ──────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _BrandingHeaderDelegate(l10n: l10n, isRtl: isRtl),
          ),

          // ── XP / streak bar ────────────────────────────────────────────────
          const SliverToBoxAdapter(child: XpStreakHeader()),

          // ── Section label ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.lg, Spacing.md, Spacing.sm),
              child: Text(
                l10n.learnPath,
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
              ),
            ).animate().fadeIn(duration: AppDurations.medium),
          ),

          // ── Level cards ────────────────────────────────────────────────────
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

// ── Persistent header delegate ──────────────────────────────────────────────

class _BrandingHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _BrandingHeaderDelegate({required this.l10n, required this.isRtl});

  final AppLocalizations l10n;
  final bool isRtl;

  static const double _expandedHeight = 100;
  static const double _collapsedHeight = 64;

  @override
  double get minExtent => _collapsedHeight;
  @override
  double get maxExtent => _expandedHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (_expandedHeight - _collapsedHeight)).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: Spacing.sm),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App icon badge
              AnimatedContainer(
                duration: AppDurations.fast,
                width: lerpDouble(48, 36, t)!,
                height: lerpDouble(48, 36, t)!,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icon/icon_flat.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _FallbackIconBadge(size: lerpDouble(48, 36, t)!),
                  ),
                ),
              ),

              const SizedBox(width: Spacing.md),

              // Text block
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isRtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: lerpDouble(26, 20, t),
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    if (t < 0.7) ...[
                      const SizedBox(height: 2),
                      Opacity(
                        opacity: (1 - t / 0.7).clamp(0.0, 1.0),
                        child: Text(
                          l10n.learnSubtitle,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_BrandingHeaderDelegate old) =>
      old.isRtl != isRtl || old.l10n != l10n;
}

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

// ── Fallback widget if icon asset not found ──────────────────────────────────

class _FallbackIconBadge extends StatelessWidget {
  const _FallbackIconBadge({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFDC143C)],
          ),
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: Text(
            'P',
            style: TextStyle(
              color: const Color(0xFF1A1A2E),
              fontSize: size * 0.52,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      );
}
