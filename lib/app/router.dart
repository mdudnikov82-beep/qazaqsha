import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dictionary/dictionary_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/review/review_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
        _branch('/review', const ReviewScreen()),
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
      path: '/practice/review',
      builder: (context, state) => const QuizScreen.review(),
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
            label: 'Уроки',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Словарь',
          ),
          NavigationDestination(
            icon: Icon(Icons.replay_outlined),
            selectedIcon: Icon(Icons.replay_rounded),
            label: 'Повторение',
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
