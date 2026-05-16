import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../../gamification/domain/models/learner_progress.dart';
import '../../gamification/presentation/gamification_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learnerProgressProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isFa = locale.languageCode == 'fa';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n?.tabProfile ?? 'Profile'),
      ),
      body: progressAsync.when(
        data: (progress) => ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Learner',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: Spacing.xl),

            // ── Stats ────────────────────────────────────────────────────
            _StatCard(
              label: l10n?.xpTotal(progress.totalXp) ?? '${progress.totalXp} XP',
              value: '${progress.totalXp} XP',
              icon: Icons.bolt,
              color: AppColors.xpColor,
            ),
            const SizedBox(height: Spacing.md),
            _StatCard(
              label: isFa ? 'روزهای متوالی' : 'Current Streak',
              value: '${progress.currentStreakDays} ${isFa ? 'روز 🔥' : 'days 🔥'}',
              icon: Icons.local_fire_department,
              color: AppColors.streakFlame,
            ),
            const SizedBox(height: Spacing.md),
            _StatCard(
              label: isFa ? 'XP هفتگی' : 'Weekly XP',
              value: '${progress.weeklyXpSoFar} / ${LearnerProgress.weeklyXpTarget} XP',
              icon: Icons.calendar_today,
              color: AppColors.secondary,
            ),
            const SizedBox(height: Spacing.xl),

            // ── UI Language switcher ─────────────────────────────────────
            _SectionHeader(label: l10n?.settingsLanguage ?? 'Interface Language'),
            const SizedBox(height: Spacing.sm),
            _LanguageSwitcher(currentLocale: locale),
            const SizedBox(height: Spacing.lg),

            // ── Teaching language switcher ───────────────────────────────
            _SectionHeader(
              label: isFa
                  ? 'زبان آموزش لهستانی'
                  : 'Learn Polish explained in',
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              isFa
                  ? 'توضیحات گرامر و تمرین‌ها به چه زبانی باشد؟'
                  : 'Grammar explanations and exercises will use this language.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: Spacing.sm),
            _TeachingLanguageSwitcher(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ── Language Switcher ─────────────────────────────────────────────────────────

class _LanguageSwitcher extends ConsumerWidget {
  const _LanguageSwitcher({required this.currentLocale});
  final Locale currentLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(localeProvider.notifier);
    final isFa = currentLocale.languageCode == 'fa';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            _LangChip(
              label: 'English',
              flag: '🇬🇧',
              selected: !isFa,
              onTap: () => notifier.setLocale(const Locale('en')),
            ),
            const SizedBox(width: Spacing.sm),
            _LangChip(
              label: 'فارسی',
              flag: '🇮🇷',
              selected: isFa,
              onTap: () => notifier.setLocale(const Locale('fa')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.surface;
    final textColor = selected ? Colors.white : AppColors.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Teaching Language Switcher ────────────────────────────────────────────────

class _TeachingLanguageSwitcher extends ConsumerWidget {
  const _TeachingLanguageSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachingLang = ref.watch(teachingLanguageProvider);
    final notifier = ref.read(teachingLanguageProvider.notifier);
    final isEn = teachingLang == 'en';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            _TeachingChip(
              flag: '🇬🇧',
              label: 'English',
              sublabel: 'Learn in English',
              selected: isEn,
              onTap: () => notifier.setLanguage('en'),
            ),
            const SizedBox(width: Spacing.sm),
            _TeachingChip(
              flag: '🇮🇷',
              label: 'فارسی',
              sublabel: 'یادگیری به فارسی',
              selected: !isEn,
              onTap: () => notifier.setLanguage('fa'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeachingChip extends StatelessWidget {
  const _TeachingChip({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.surface;
    final textColor = selected ? Colors.white : AppColors.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm,
            horizontal: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: AppColors.accent, width: 2)
                : Border.all(color: AppColors.surfaceVariant, width: 1),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          trailing: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      );
}
