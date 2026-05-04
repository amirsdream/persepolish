import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../../gamification/presentation/gamification_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learnerProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: progressAsync.when(
        data: (progress) => ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: Spacing.md),
            Text('Learner', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
            const SizedBox(height: Spacing.xl),
            _StatCard(label: 'Total XP', value: '${progress.totalXp} XP', icon: Icons.bolt, color: AppColors.xpColor),
            const SizedBox(height: Spacing.md),
            _StatCard(label: 'Current Streak', value: '${progress.currentStreakDays} days 🔥', icon: Icons.local_fire_department, color: AppColors.streakFlame),
            const SizedBox(height: Spacing.md),
            _StatCard(label: 'Weekly XP', value: '${progress.weeklyXpSoFar} / ${LearnerProgress.weeklyXpTarget} XP', icon: Icons.calendar_today, color: AppColors.secondary),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          trailing: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      );
}
