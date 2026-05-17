import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/level.dart';

// Helper: get current UI language code from context
String _uiLang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

// ── LevelCardWidget ───────────────────────────────────────────────────────────
// 3-D tilt card with gradient background, CEFR badge glow, and press-scale.

class LevelCardWidget extends StatefulWidget {
  const LevelCardWidget({
    super.key,
    required this.level,
    required this.onTap,
  });

  final Level level;
  final VoidCallback? onTap;

  @override
  State<LevelCardWidget> createState() => _LevelCardWidgetState();
}

class _LevelCardWidgetState extends State<LevelCardWidget>
    with SingleTickerProviderStateMixin {
  double _tiltX = 0;
  double _tiltY = 0;
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (widget.onTap == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final s = box.size;
    setState(() {
      _tiltX = (d.localPosition.dy / s.height - 0.5) * 0.24;
      _tiltY = -(d.localPosition.dx / s.width - 0.5) * 0.24;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
    _pressCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final lang = _uiLang(context);
    final color = level.color;
    final isActive = level.isUnlocked && !level.isComingSoon;

    return Semantics(
      label:
          '${level.localizedName(lang)}. ${level.isComingSoon ? "Coming soon" : level.isUnlocked ? "${level.progressPercent.toInt()}% complete" : "Locked."}',
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) {
          if (widget.onTap != null) _pressCtrl.forward();
        },
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        onPanUpdate: _onPanUpdate,
        onPanEnd: (_) => _resetTilt(),
        onPanCancel: _resetTilt,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (ctx, child) => Transform.scale(
            scale: _scale.value,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_tiltX)
                ..rotateY(_tiltY),
              alignment: Alignment.center,
              child: child,
            ),
          ),
          child: ClipRRect(
            borderRadius: Radii.cardLg,
            child: _CardBody(level: level, lang: lang, color: color, isActive: isActive),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: AppDurations.medium)
          .slideY(begin: 0.08, duration: AppDurations.medium, curve: Curves.easeOut),
    );
  }
}

// ── Card body ─────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.level,
    required this.lang,
    required this.color,
    required this.isActive,
  });

  final Level level;
  final String lang;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: Radii.cardLg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  color.withOpacity(0.28),
                  AppColors.surface,
                  AppColors.surfaceVariant.withOpacity(0.85),
                ]
              : [AppColors.surface, AppColors.surfaceVariant],
          stops: isActive ? const [0.0, 0.55, 1.0] : const [0.0, 1.0],
        ),
        border: Border.all(
          color: isActive ? color.withOpacity(0.50) : AppColors.surfaceVariant,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Radial glow bubble — top-right corner
          if (isActive)
            Positioned(
              top: -28,
              right: -28,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.16),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: CEFR badge + percent chip
                Row(
                  children: [
                    _CefrBadge(levelId: level.id, color: color),
                    const Spacer(),
                    if (isActive)
                      _PercentChip(
                        percent: level.progressPercent.toInt(),
                        color: color,
                      ),
                  ],
                ),

                const SizedBox(height: Spacing.sm),

                Text(
                  level.localizedName(lang),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: Spacing.xs),

                Text(
                  level.localizedDescription(lang),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                if (isActive) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: level.progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Icon(
                        i < level.totalStars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: i < level.totalStars
                            ? AppColors.starGold
                            : AppColors.starEmpty,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lock overlay
          if (!level.isComingSoon && !level.isUnlocked) const _LockOverlay(),

          // Coming-soon overlay
          if (level.isComingSoon) const _ComingSoonOverlay(),
        ],
      ),
    );
  }
}

// ── CEFR Badge ────────────────────────────────────────────────────────────────

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.levelId, required this.color});
  final String levelId;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.50), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          levelId.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      );
}

// ── Percent Chip ──────────────────────────────────────────────────────────────

class _PercentChip extends StatelessWidget {
  const _PercentChip({required this.percent, required this.color});
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.40)),
        ),
        child: Text(
          '$percent%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}

// ── Lock Overlay ──────────────────────────────────────────────────────────────

class _LockOverlay extends StatelessWidget {
  const _LockOverlay();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ClipRRect(
          borderRadius: Radii.cardLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              color: Colors.black.withOpacity(0.55),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    AppLocalizations.of(context)!.levelLockMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ── Coming-Soon Overlay ───────────────────────────────────────────────────────

class _ComingSoonOverlay extends StatelessWidget {
  const _ComingSoonOverlay();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ClipRRect(
          borderRadius: Radii.cardLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
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
