import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/custom_words/import_screen.dart';
import '../features/dialogues/dialogues_screen.dart';
import '../features/dictionary/dictionary_screen.dart';
import '../features/dictionary/flashcards_screen.dart';
import '../features/grammar/grammar_practice_screen.dart';
import '../features/grammar/latin_screen.dart';
import '../features/grammar/rules_screen.dart';
import '../features/home/comeback_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/review/mistakes_screen.dart';
import '../features/review/review_mode.dart';
import '../features/review/review_screen.dart';

/// A fresh router per app instance, so navigation state never leaks between
/// app restarts (or tests).
///
/// [onboardingDone] is null while the database loads; [refresh] fires when
/// it changes, so the welcome redirect is re-evaluated.
GoRouter createRouter({
  required bool? Function() onboardingDone,
  required Listenable refresh,
}) => GoRouter(
  initialLocation: '/home',
  refreshListenable: refresh,
  redirect: (context, state) {
    final done = onboardingDone();
    final here = state.matchedLocation;
    if (done == null) return null;
    // Import links from the bot work even before the welcome is done.
    if (!done && here != '/welcome' && here != '/import') return '/welcome';
    if (done && here == '/welcome') return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _MainShell(shell: shell),
      branches: [
        _branch('/home', const HomeScreen()),
        _branch('/lessons', const LessonsScreen()),
        _branch(
          '/dictionary',
          const DictionaryScreen(),
          routes: [
            GoRoute(
              path: ':categoryId',
              builder: (context, state) => CategoryWordsScreen(
                categoryId: state.pathParameters['categoryId']!,
              ),
            ),
          ],
        ),
        _branch('/rules', const RulesScreen()),
        _branch('/profile', const ProfileScreen()),
      ],
    ),
    // Full-screen flows, above the bottom navigation.
    GoRoute(
      path: '/lesson/:categoryId/:index',
      builder: (context, state) => QuizScreen.lesson(
        categoryId: state.pathParameters['categoryId']!,
        lessonIndex: int.parse(state.pathParameters['index']!),
      ),
    ),
    GoRoute(
      path: '/exam/:sectionId',
      builder: (context, state) =>
          QuizScreen.exam(sectionId: state.pathParameters['sectionId']!),
    ),
    GoRoute(
      path: '/practice/review',
      builder: (context, state) => QuizScreen.review(
        reviewMode: ReviewMode.parse(state.uri.queryParameters['mode']),
      ),
    ),
    GoRoute(path: '/review', builder: (context, state) => const ReviewScreen()),
    GoRoute(
      path: '/comeback',
      builder: (context, state) => const ComebackScreen(),
    ),
    GoRoute(
      path: '/dialogues',
      builder: (context, state) => const DialoguesScreen(),
      routes: [
        GoRoute(
          path: ':dialogueId',
          builder: (context, state) =>
              DialogueScreen(dialogueId: state.pathParameters['dialogueId']!),
          routes: [
            GoRoute(
              path: 'practice',
              builder: (context, state) => GrammarPracticeScreen.dialogue(
                dialogueId: state.pathParameters['dialogueId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/latin', builder: (context, state) => const LatinScreen()),
    GoRoute(
      path: '/mistakes',
      builder: (context, state) => const MistakesScreen(),
    ),
    // Before /rules/:ruleId, which would take «mistakes» for an id.
    GoRoute(
      path: '/rules/mistakes',
      builder: (context, state) => const GrammarPracticeScreen.mistakes(),
    ),
    GoRoute(
      path: '/rules/test/:groupId',
      builder: (context, state) => GrammarPracticeScreen.group(
        groupId: state.pathParameters['groupId']!,
      ),
    ),
    GoRoute(
      path: '/rules/:ruleId',
      builder: (context, state) =>
          RuleScreen(ruleId: state.pathParameters['ruleId']!),
      routes: [
        GoRoute(
          path: 'practice',
          builder: (context, state) => GrammarPracticeScreen.rule(
            ruleId: state.pathParameters['ruleId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/flashcards/:source',
      builder: (context, state) =>
          FlashcardsScreen(source: state.pathParameters['source']!),
    ),
    GoRoute(
      path: '/practice/custom',
      builder: (context, state) =>
          QuizScreen.custom(setId: state.uri.queryParameters['set']),
    ),
    // Also the target of import links: …/#/import?w=CODE (web) and
    // qazaqsha://app/import?w=CODE (Android).
    GoRoute(
      path: '/import',
      builder: (context, state) => ImportWordsScreen(
        code: state.uri.queryParameters['w'],
        setId: state.uri.queryParameters['set'],
      ),
    ),
  ],
);

StatefulShellBranch _branch(
  String path,
  Widget screen, {
  List<RouteBase> routes = const [],
}) => StatefulShellBranch(
  routes: [
    GoRoute(path: path, builder: (context, state) => screen, routes: routes),
  ],
);

class _MainShell extends StatelessWidget {
  const _MainShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Карта',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Словарь',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_outlined),
            selectedIcon: Icon(Icons.rule_rounded),
            label: 'Правила',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
