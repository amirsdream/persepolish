import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/models/vocabulary_set.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _vocabSetProvider =
    FutureProvider.family<VocabularySet, String>((ref, assetPath) async {
  return VocabularySet.loadFromAsset(assetPath);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({
    super.key,
    required this.levelId,
    required this.setId,
  });

  final String levelId;
  final String setId;

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  int _known = 0;
  bool _showingBack = false;
  bool _complete = false;

  // ── Card-entrance animation ──────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  // ── Swipe-to-decide ─────────────────────────────────────────────────────────
  double _dragX = 0;
  static const double _swipeThreshold = 90.0;

  String get _assetPath =>
      'assets/content/${widget.levelId}/vocabulary/${widget.setId}.json';

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.30, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0, 0.65)));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    setState(() => _showingBack = !_showingBack);
  }

  void _advance(VocabularySet set, {required bool known}) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (known) _known++;
      _showingBack = false;
      _dragX = 0;
      if (_current + 1 >= set.cards.length) {
        _complete = true;
      } else {
        _current++;
        _entranceCtrl.forward(from: 0);
      }
    });
  }

  // Overlay that turns green/red as the user drags while showing back face.
  Widget _swipeOverlay() {
    if (!_showingBack || _dragX.abs() < 8) return const SizedBox.shrink();
    final frac = (_dragX.abs() / _swipeThreshold).clamp(0.0, 1.0);
    final isRight = _dragX > 0;
    final color =
        isRight ? AppColors.correctGreen : AppColors.incorrectRed;
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: frac * 0.9,
        duration: Duration.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: Radii.cardLg,
            color: color.withValues(alpha: 0.28),
          ),
          child: Center(
            child: Transform.scale(
              scale: 0.6 + frac * 0.4,
              child: Container(
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(color: color.withValues(alpha: 0.7), width: 3),
                ),
                child: Icon(
                  isRight ? Icons.check_rounded : Icons.close_rounded,
                  size: 52,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teachingLang = ref.watch(teachingLanguageProvider);
    final isFa = teachingLang == 'fa';

    final asyncSet = ref.watch(_vocabSetProvider(_assetPath));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: asyncSet.when(
          data: (set) => Text(
            set.localizedTitle(teachingLang),
            textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
          ),
          loading: () => Text(l10n.curriculumVocabulary),
          error: (_, __) => Text(l10n.curriculumVocabulary),
        ),
      ),
      body: asyncSet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load vocabulary: $e')),
        data: (set) {
          if (_complete) {
            return _CompleteView(
              known: _known,
              total: set.cards.length,
              onRestart: () => setState(() {
                _current = 0;
                _known = 0;
                _showingBack = false;
                _complete = false;
                _dragX = 0;
                _entranceCtrl.forward(from: 0);
              }),
            );
          }

          final card = set.cards[_current];
          final progress = (_current + 1) / set.cards.length;

          return Column(
            children: [
              // ── Progress bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg, vertical: Spacing.sm),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.starGold),
                            const SizedBox(width: 4),
                            Text(
                              '$_known known',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.starGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          '${_current + 1} / ${set.cards.length}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (ctx, val, _) => ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        child: LinearProgressIndicator(
                          value: val,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(
                            Color.lerp(
                                AppColors.primary, AppColors.starGold, val)!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Flashcard ────────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg, vertical: Spacing.sm),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: GestureDetector(
                        onTap: !_showingBack ? _flip : null,
                        onHorizontalDragUpdate: _showingBack
                            ? (d) => setState(() => _dragX += d.delta.dx)
                            : null,
                        onHorizontalDragEnd: _showingBack
                            ? (d) {
                                final vel =
                                    d.primaryVelocity ?? 0;
                                if (_dragX.abs() >= _swipeThreshold ||
                                    vel.abs() > 600) {
                                  _advance(set,
                                      known: _dragX > 0 || vel > 0);
                                } else {
                                  setState(() => _dragX = 0);
                                }
                              }
                            : null,
                        child: Transform.translate(
                          offset: Offset(
                              _showingBack ? _dragX * 0.12 : 0, 0),
                          child: Stack(
                            children: [
                              _FlipCard(
                                card: card,
                                showingBack: _showingBack,
                                teachingLang: teachingLang,
                                isFa: isFa,
                              ),
                              _swipeOverlay(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom row: hint or action buttons ───────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _showingBack
                    ? _ActionRow(
                        key: const ValueKey('actions'),
                        onStillLearning: () =>
                            _advance(set, known: false),
                        onKnowIt: () => _advance(set, known: true),
                      )
                    : _SwipeHintRow(key: const ValueKey('swipe-hint')),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Flip card ─────────────────────────────────────────────────────────────────

class _FlipCard extends StatefulWidget {
  const _FlipCard({
    required this.card,
    required this.showingBack,
    required this.teachingLang,
    required this.isFa,
  });
  final VocabularyCard card;
  final bool showingBack;
  final String teachingLang;
  final bool isFa;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _flipAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    // Flip rotates 0→π
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic));
    // Scale squishes to 0.90 at the midpoint then back to 1.0
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.90)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 0.90, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.showingBack != old.showingBack) {
      widget.showingBack ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final angle = _flipAnim.value * math.pi; // 0 → π

        // Front half:  angle sweeps  0  → π/2  (flat → edge-on)
        // Back  half:  angle sweeps -π/2 → 0   (edge-on → flat, no mirror)
        //
        // Using  (angle - π)  for the back gives exactly -π/2 at the
        // midpoint and 0 at completion — the back face is never mirrored
        // because it arrives at rotateY(0) = identity when fully visible.
        // No inner counter-rotation needed at all.
        final isShowingFront = angle <= math.pi / 2;
        final displayAngle = isShowingFront ? angle : angle - math.pi;

        return Transform.scale(
          scale: _scaleAnim.value,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..rotateY(displayAngle),
            alignment: Alignment.center,
            child: isShowingFront
                ? _CardFront(card: widget.card)
                : _CardBack(
                    card: widget.card,
                    teachingLang: widget.teachingLang,
                    isFa: widget.isFa,
                  ),
          ),
        );
      },
    );
  }
}

// ── Card front ────────────────────────────────────────────────────────────────

class _CardFront extends StatefulWidget {
  const _CardFront({required this.card});
  final VocabularyCard card;

  @override
  State<_CardFront> createState() => _CardFrontState();
}

class _CardFrontState extends State<_CardFront>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant,
            AppColors.primary.withValues(alpha: 0.10),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: Radii.cardLg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Part-of-speech chip ──────────────────────────────────────────────
          if (card.partOfSpeech != null) ...[
            _PosChip(pos: card.partOfSpeech!),
            const SizedBox(height: Spacing.lg),
          ] else
            const SizedBox(height: Spacing.xl),

          // ── 🇵🇱 + Polish word ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🇵🇱', style: TextStyle(fontSize: 24)),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    card.polish,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // ── Pronunciation ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
            ),
            child: Text(
              '[${card.pronunciation}]',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.4,
                  ),
              textDirection: TextDirection.ltr,
            ),
          ),

          // ── Gender badge ─────────────────────────────────────────────────────
          if (card.gender != null) ...[
            const SizedBox(height: Spacing.sm),
            _GenderBadge(gender: card.gender!),
          ],

          const SizedBox(height: Spacing.xl),

          // ── Pulsing "tap to reveal" ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Opacity(
              opacity: _pulseAnim.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 15,
                      color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Text(
                    'Tap to reveal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }
}

// ── Card back ─────────────────────────────────────────────────────────────────

class _CardBack extends StatelessWidget {
  const _CardBack({
    required this.card,
    required this.teachingLang,
    required this.isFa,
  });
  final VocabularyCard card;
  final String teachingLang;
  final bool isFa;

  @override
  Widget build(BuildContext context) {
    final meaning = card.localizedMeaning(teachingLang);
    final example = card.localizedExample(teachingLang);
    final langFlag = isFa ? '🇮🇷' : '🇬🇧';
    final langLabel = isFa ? 'فارسی' : 'English';
    // textDirection is passed to individual Text widgets only — it controls
    // glyph rendering (RTL ligatures etc.) without touching layout alignment.
    // Layout is always centered so the card looks symmetrical in both languages.
    final textDir = isFa ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg, vertical: Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceVariant,
            AppColors.surface,
            AppColors.secondary.withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: Radii.cardLg,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.18),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // No Directionality wrapper — layout is always centered.
      // Each Text gets its own textDirection for correct glyph rendering.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Polish word reference (always LTR, always centered) ───────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇵🇱', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  card.polish,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // ── Language flag + label (always centered, flag always left) ─────
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(langFlag, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                langLabel,
                textDirection: textDir,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),

          // ── Meaning (big, centered) ───────────────────────────────────────
          Text(
            meaning,
            textAlign: TextAlign.center,
            textDirection: textDir,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.3,
                ),
          ),

          const SizedBox(height: Spacing.md),

          // ── Divider ──────────────────────────────────────────────────────
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                AppColors.onSurfaceVariant.withValues(alpha: 0.35),
                Colors.transparent,
              ]),
            ),
          ),

          const SizedBox(height: Spacing.md),

          // ── Example label (always centered, always LTR) ───────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'EXAMPLE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Polish example sentence (always LTR, always centered)
          if (card.examplePolish.isNotEmpty)
            Text(
              card.examplePolish,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
            ),

            // Translation of example (centered, correct glyph direction)
            if (example.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                example,
                textAlign: TextAlign.center,
                textDirection: textDir,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],

            const SizedBox(height: Spacing.md),

            // ── Swipe hint at bottom (always LTR — directional indicator) ────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SwipeLabel(
                    icon: Icons.close_rounded,
                    label: 'Again',
                    color: AppColors.incorrectRed),
                _SwipeLabel(
                    icon: Icons.check_rounded,
                    label: 'Got it',
                    color: AppColors.correctGreen,
                    reverse: true),
              ],
            ),
          ],
        ),
    );
  }
}

// ── Small supporting widgets ──────────────────────────────────────────────────

class _PosChip extends StatelessWidget {
  const _PosChip({required this.pos});
  final String pos;

  Color _color() => switch (pos.toLowerCase()) {
        'verb' => AppColors.accent,
        'noun' => AppColors.secondary,
        'adjective' => AppColors.levelB2,
        'adverb' => AppColors.streakFlame,
        _ => AppColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.45)),
      ),
      child: Text(
        pos.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: c,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _GenderBadge extends StatelessWidget {
  const _GenderBadge({required this.gender});
  final String gender;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
      ),
      child: Text(
        gender,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _SwipeLabel extends StatelessWidget {
  const _SwipeLabel({
    required this.icon,
    required this.label,
    required this.color,
    this.reverse = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final children = [
      Icon(icon, size: 13, color: color.withValues(alpha: 0.6)),
      const SizedBox(width: 3),
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: reverse ? children.reversed.toList() : children,
    );
  }
}

// ── Action row (shown after flip) ─────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
    required this.onStillLearning,
    required this.onKnowIt,
  });
  final VoidCallback onStillLearning;
  final VoidCallback onKnowIt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _DecisionButton(
              label: 'Still Learning',
              icon: Icons.replay_rounded,
              color: AppColors.incorrectRed,
              outlined: true,
              onTap: onStillLearning,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: _DecisionButton(
              label: 'Got It!',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.correctGreen,
              outlined: false,
              onTap: onKnowIt,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.outlined,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
              vertical: Spacing.md, horizontal: Spacing.sm),
          decoration: BoxDecoration(
            color: outlined
                ? Colors.transparent
                : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Flip/swipe hint row (shown before flip) ───────────────────────────────────

class _SwipeHintRow extends StatelessWidget {
  const _SwipeHintRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Text(
        'Tap the card to reveal the answer',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Completion view ───────────────────────────────────────────────────────────

class _CompleteView extends StatefulWidget {
  const _CompleteView({
    required this.known,
    required this.total,
    required this.onRestart,
  });
  final int known;
  final int total;
  final VoidCallback onRestart;

  @override
  State<_CompleteView> createState() => _CompleteViewState();
}

class _CompleteViewState extends State<_CompleteView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pct = widget.total > 0
        ? (widget.known / widget.total * 100).round()
        : 0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated star burst
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.starGold.withValues(alpha: 0.25),
                      AppColors.starGold.withValues(alpha: 0.05),
                    ]),
                    border: Border.all(
                        color: AppColors.starGold.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.star_rounded,
                      size: 62, color: AppColors.starGold),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                l10n.flashcardSetComplete,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
              // Score pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg, vertical: Spacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.correctGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Radii.xl),
                  border: Border.all(
                      color:
                          AppColors.correctGreen.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${widget.known} / ${widget.total} known · $pct%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.correctGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: Spacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onRestart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Review Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: Spacing.md),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: Spacing.md),
                  ),
                  child: Text(l10n.completionBackToCurriculum),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
