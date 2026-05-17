import 'dart:math' as math;

import 'package:flutter/material.dart';
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

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int _current = 0;
  int _known = 0;
  bool _showingBack = false;
  bool _complete = false;

  String get _assetPath =>
      'assets/content/${widget.levelId}/vocabulary/${widget.setId}.json';

  void _flip() => setState(() => _showingBack = !_showingBack);

  void _markKnown(VocabularySet set) {
    setState(() {
      _known++;
      _advance(set);
    });
  }

  void _markStillLearning(VocabularySet set) {
    setState(() {
      _advance(set);
    });
  }

  void _advance(VocabularySet set) {
    _showingBack = false;
    if (_current + 1 >= set.cards.length) {
      _complete = true;
    } else {
      _current++;
    }
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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        title: asyncSet.when(
          data: (set) => Text(set.localizedTitle(teachingLang)),
          loading: () => Text(l10n.curriculumVocabulary),
          error: (_, __) => Text(l10n.curriculumVocabulary),
        ),
      ),
      body: asyncSet.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load vocabulary: $e'),
        ),
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
              }),
            );
          }

          final card = set.cards[_current];

          return Column(
            children: [
              // Progress bar + counter
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg, vertical: Spacing.sm),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.flashcardProgress(_known, set.cards.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${_current + 1} / ${set.cards.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4)),
                      child: LinearProgressIndicator(
                        value: (_current + 1) / set.cards.length,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              // Flashcard
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: GestureDetector(
                    onTap: _flip,
                    child: _FlipCard(
                      card: card,
                      showingBack: _showingBack,
                      teachingLang: teachingLang,
                      isFa: isFa,
                    ),
                  ),
                ),
              ),

              // Flip hint
              if (!_showingBack)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: Text(
                    l10n.flashcardFlipHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ),

              // Action buttons (only after flip)
              if (_showingBack)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.lg, 0, Spacing.lg, Spacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _markStillLearning(set),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.incorrectRed,
                            side: BorderSide(
                                color: AppColors.incorrectRed, width: 1.5),
                          ),
                          child: Text(l10n.flashcardStillLearning),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _markKnown(set),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.correctGreen,
                          ),
                          child: Text(l10n.flashcardKnowIt),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: Spacing.xl + Spacing.lg),
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
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.showingBack != old.showingBack) {
      if (widget.showingBack) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final angle = _anim.value * math.pi;
        final isShowingFront = angle <= math.pi / 2;
        final displayAngle =
            isShowingFront ? angle : math.pi - angle;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(displayAngle),
          alignment: Alignment.center,
          child: isShowingFront
              ? _CardFront(card: widget.card)
              : Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _CardBack(
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

// ── Card front (Polish word) ──────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  const _CardFront({required this.card});
  final VocabularyCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: Radii.cardLg,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.polish,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '[${card.pronunciation}]',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
          if (card.gender != null) ...[
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                card.gender!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          Text(
            l10n.flashcardFlipHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Card back (meaning + example) ────────────────────────────────────────────

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
    final l10n = AppLocalizations.of(context)!;
    final meaning = card.localizedMeaning(teachingLang);
    final example = card.localizedExample(teachingLang);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: Radii.cardLg,
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isFa ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Polish word reminder
          Text(
            card.polish,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: Spacing.md),
          // Meaning
          Text(
            l10n.vocabCardMeaning,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.1,
                ),
            textDirection:
                isFa ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            meaning,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textDirection:
                isFa ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: Spacing.lg),
          // Example
          Text(
            l10n.vocabCardExample,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            card.examplePolish,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: Spacing.xs),
          if (example.isNotEmpty)
            Text(
              example,
              textDirection:
                  isFa ? TextDirection.rtl : TextDirection.ltr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}

// ── Completion view ───────────────────────────────────────────────────────────

class _CompleteView extends StatelessWidget {
  const _CompleteView({
    required this.known,
    required this.total,
    required this.onRestart,
  });
  final int known;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 72, color: AppColors.starGold),
            const SizedBox(height: Spacing.lg),
            Text(
              l10n.flashcardSetComplete,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.flashcardProgress(known, total),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Spacing.xl),
            ElevatedButton(
              onPressed: onRestart,
              child: const Text('Review again'),
            ),
            const SizedBox(height: Spacing.md),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.completionBackToCurriculum),
            ),
          ],
        ),
      ),
    );
  }
}
