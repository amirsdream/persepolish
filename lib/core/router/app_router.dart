import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/levels/presentation/levels_screen.dart';
import '../../features/levels/presentation/level_curriculum_screen.dart';
import '../../features/lessons/presentation/lesson_screen.dart';
import '../../features/lessons/presentation/completion_screen.dart';
import '../../features/vocabulary/presentation/flashcard_screen.dart';
import '../../features/vocabulary/presentation/vocab_quiz_screen.dart';
import '../../features/vocabulary/presentation/word_bank_screen.dart';
import '../../features/exam_prep/presentation/exam_prep_screen.dart';
import '../../features/exam_prep/presentation/exam_session_screen.dart';
import '../../features/exam_prep/presentation/exam_results_screen.dart';
import '../../features/gamification/presentation/milestone_celebration_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: false,
      routes: [
        ShellRoute(
          builder: (context, state, child) => ScaffoldWithNavBar(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LevelsScreen(),
              ),
            ),
            GoRoute(
              path: '/word-bank',
              name: 'word-bank',
              pageBuilder: (context, state) => NoTransitionPage(
                child: WordBankScreen(
                  filterLevel: state.uri.queryParameters['level'],
                  filterCategory: state.uri.queryParameters['category'],
                ),
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),

        // Level curriculum (pushed over shell)
        GoRoute(
          path: '/levels/:levelId',
          name: 'level-curriculum',
          pageBuilder: (context, state) => _slideUpPage(
            LevelCurriculumScreen(levelId: state.pathParameters['levelId']!),
          ),
        ),

        // Grammar lesson flow
        GoRoute(
          path: '/levels/:levelId/grammar/:unitId',
          name: 'grammar-unit',
          pageBuilder: (context, state) => _slideUpPage(
            LessonScreen(
              levelId: state.pathParameters['levelId']!,
              unitId: state.pathParameters['unitId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/levels/:levelId/grammar/:unitId/complete',
          name: 'lesson-complete',
          pageBuilder: (context, state) => _slideUpPage(
            CompletionScreen(
              levelId: state.pathParameters['levelId']!,
              unitId: state.pathParameters['unitId']!,
              stars: int.tryParse(
                      state.uri.queryParameters['stars'] ?? '0') ??
                  0,
              xpEarned: int.tryParse(
                      state.uri.queryParameters['xp'] ?? '0') ??
                  0,
              accuracy: double.tryParse(
                      state.uri.queryParameters['accuracy'] ?? '0') ??
                  0.0,
            ),
          ),
        ),

        // Vocabulary flow
        GoRoute(
          path: '/levels/:levelId/vocab/:setId',
          name: 'vocabulary-set',
          pageBuilder: (context, state) => _slideUpPage(
            FlashcardScreen(
              levelId: state.pathParameters['levelId']!,
              setId: state.pathParameters['setId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/levels/:levelId/vocab/:setId/quiz',
          name: 'vocab-quiz',
          pageBuilder: (context, state) => _slideUpPage(
            VocabQuizScreen(
              levelId: state.pathParameters['levelId']!,
              setId: state.pathParameters['setId']!,
            ),
          ),
        ),

        // Exam prep flow
        GoRoute(
          path: '/levels/:levelId/exam',
          name: 'exam-prep',
          pageBuilder: (context, state) => _slideUpPage(
            ExamPrepScreen(levelId: state.pathParameters['levelId']!),
          ),
        ),
        GoRoute(
          path: '/levels/:levelId/exam/:setId',
          name: 'exam-session',
          pageBuilder: (context, state) => _slideUpPage(
            ExamSessionScreen(
              levelId: state.pathParameters['levelId']!,
              setId: state.pathParameters['setId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/levels/:levelId/exam/:setId/results',
          name: 'exam-results',
          pageBuilder: (context, state) => _slideUpPage(
            ExamResultsScreen(
              levelId: state.pathParameters['levelId']!,
              setId: state.pathParameters['setId']!,
              accuracy: double.tryParse(
                      state.uri.queryParameters['accuracy'] ?? '0') ??
                  0.0,
              readiness: int.tryParse(
                      state.uri.queryParameters['readiness'] ?? '0') ??
                  0,
            ),
          ),
        ),

        // Milestone celebration
        GoRoute(
          path: '/milestone',
          name: 'milestone',
          pageBuilder: (context, state) => _scaleFadePage(
            MilestoneCelebrationScreen(
              type: state.uri.queryParameters['type'] ?? 'weekly_xp',
              value: int.tryParse(
                      state.uri.queryParameters['value'] ?? '0') ??
                  0,
            ),
          ),
        ),
      ],
    );

CustomTransitionPage<void> _slideUpPage(Widget child) =>
    CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: FadeTransition(opacity: animation, child: child),
      ),
    );

CustomTransitionPage<void> _scaleFadePage(Widget child) =>
    CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: FadeTransition(opacity: animation, child: child),
      ),
    );
