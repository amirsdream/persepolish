import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../utils/audio_service.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Unlock audio on any user interaction anywhere in the shell
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => AudioService.instance.onUserInteraction(),
      child: Scaffold(
        body: child,
        bottomNavigationBar: _NavBar(currentLocation: GoRouterState.of(context).uri.path),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final int currentIndex = switch (currentLocation) {
      String s when s.startsWith('/word-bank') => 1,
      String s when s.startsWith('/profile') => 2,
      _ => 0,
    };

    return Semantics(
      label: 'Main navigation',
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/word-bank');
            case 2:
              context.go('/profile');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: AppLocalizations.of(context)!.tabLearn,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: AppLocalizations.of(context)!.tabWords,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.tabProfile,
          ),
        ],
      ),
    );
  }
}
