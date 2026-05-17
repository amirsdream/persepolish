import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/level.dart';

String _uiLang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

// ── LevelCardWidget ───────────────────────────────────────────────────────────
// Full-width horizontal card with left colour stripe, CEFR badge, stats row,
// and a circular progress ring. StatelessWidget — parent controls animation.

class LevelCardWidget extends StatelessWidget {
  const LevelCardWidget({
    super.key,
    required this.level,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final Level level;
  final VoidCallback? onTap;
  final Duration animationDelay;

  bool get _isActive =>
      level.isUnlocked &&
      !level.isComingSoon &&
      level.progressPercent > 0 &&
      level.progressPercent < 100;

  @override
  Widget build(BuildContext context) {
    final lang = _uiLang(context);
    final color = level.color;
    final canTap = level.isUnlocked && !level.isComingSoon;

    return Semantics(
      label: _semanticLabel(context, lang),
      button: true,
      child: ClipRRect(
        borderRadius: Radii.cardLg,
        child: Stack(
          children: [
            // ── Card body ─────────────────────────────────────────────────
            Material(
              color: AppColors.surface,
              child: InkWell(
                onTap: onTap,
                splashColor: color.withOpacity(0.12),
                highlightColor: color.withOpacity(0.06),
                child: Container(
                  decoration: BoxDecoration(
                    // Subtle active glow tint
                    gradient: _isActive
                        ? LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              color.withOpacity(0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5],
                          )
                        : null,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left colour stripe
                        Container(
                          width: 4,
                          color: canTap ? color : AppColors.surfaceVariant,
                        ),

                        // Main content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.md,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // CEFR badge
                                _CefrBadge(level: level, color: color, canTap: canTap),
                                const SizedBox(width: Spacing.md),

                                // Name / description / stats
                                Expanded(
                                  child: _ContentColumn(
                                    level: level,
                                    lang: lang,
                                    color: color,
                                    isActive: _isActive,
                                    canTap: canTap,
                                  ),
                                ),
                                const SizedBox(width: Spacing.md),

                                // Progress ring (right side)
                                if (canTap)
                                  _ProgressRing(level: level, color: color)
                                else
                                  const _LockIcon(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Lock overlay ──────────────────────────────────────────────
            if (!level.isComingSoon && !level.isUnlocked) const _LockOverlay(),

            // ── Coming-soon overlay ───────────────────────────────────────
            if (level.isComingSoon) const _ComingSoonOverlay(),
          ],
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: AppDurations.medium)
        .slideY(begin: 0.06, duration: AppDurations.medium, curve: Curves.easeOut);
  }

  String _semanticLabel(BuildContext context, String lang) {
    final name = level.localizedName(lang);
    if (level.isComingSoon) return '$name. Coming soon.';
    if (!level.isUnlocked) return '$name. Locked.';
    return '$name. ${level.progressPercent.toInt()}% complete.';
  }
}

// ── CEFR badge ────────────────────────────────────────────────────────────────

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level, required this.color, required this.canTap});
  final Level level;
  final Color color;
  final bool canTap;

  @override
  Widget build(BuildContext context) {
    final badgeColor = canTap ? color : AppColors.onSurfaceVariant;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor.withOpacity(0.10),
        border: Border.all(color: badgeColor.withOpacity(0.45), width: 2),
        boxShadow: canTap
            ? [
                BoxShadow(
                  color: badgeColor.withOpacity(0.22),
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        level.id.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Content column ────────────────────────────────────────────────────────────

class _ContentColumn extends StatelessWidget {
  const _ContentColumn({
    required this.level,
    required this.lang,
    required this.color,
    required this.isActive,
    required this.canTap,
  });
  final Level level;
  final String lang;
  final Color color;
  final bool isActive;
  final bool canTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level name
        Text(
          level.localizedName(lang),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: canTap ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 3),

        // Description
        Text(
          level.localizedDescription(lang),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: Spacing.sm),

        // Stats row: lessons · vocab · stars
        Row(
          children: [
            _StatChip(
              icon: Icons.auto_stories_rounded,
              label: '${level.grammarUnits.length}',
              color: AppColors.accent,
            ),
            _dot(),
            _StatChip(
              icon: Icons.translate_rounded,
              label: '${level.vocabularySets.length}',
              color: AppColors.primary,
            ),
            _dot(),
            _StatChip(
              icon: Icons.star_rounded,
              label: '${level.totalStars}',
              color: AppColors.starGold,
            ),
          ],
        ),

        // "ACTIVE" badge for in-progress level
        if (isActive) ...[
          const SizedBox(height: Spacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: color, size: 12),
                const SizedBox(width: 3),
                Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          '·',
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      );
}

// ── Stat chip (icon + label) ──────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

// ── Circular progress ring ────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.level, required this.color});
  final Level level;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: level.progressPercent / 100,
              backgroundColor: AppColors.surfaceVariant,
              color: color,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
            ),
            Text(
              '${level.progressPercent.toInt()}%',
              style: TextStyle(
                color: level.progressPercent >= 100
                    ? AppColors.success
                    : color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

// ── Lock icon (placeholder when card is locked) ───────────────────────────────

class _LockIcon extends StatelessWidget {
  const _LockIcon();

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceVariant.withOpacity(0.5),
        ),
        child: const Icon(
          Icons.lock_rounded,
          color: AppColors.onSurfaceVariant,
          size: 24,
        ),
      );
}

// ── Lock overlay ──────────────────────────────────────────────────────────────

class _LockOverlay extends StatelessWidget {
  const _LockOverlay();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ClipRRect(
          borderRadius: Radii.cardLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.black.withOpacity(0.52),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.md + 6),
                    child: Text(
                      AppLocalizations.of(context)!.levelLockMessage,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ── Coming-soon overlay ───────────────────────────────────────────────────────

class _ComingSoonOverlay extends StatelessWidget {
  const _ComingSoonOverlay();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ClipRRect(
          borderRadius: Radii.cardLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.9),
                    borderRadius: Radii.cardLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.40),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.levelComingSoon,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
