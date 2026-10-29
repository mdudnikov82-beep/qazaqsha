import 'package:flutter/material.dart';

/// What achievements are checked against after each session.
class AchievementFacts {
  const AchievementFacts({
    required this.quizzesCompleted,
    required this.streakDays,
    required this.learnedWords,
    required this.totalXp,
    required this.lastSessionPerfect,
    this.examsPassed = 0,
  });

  final int quizzesCompleted;
  final int streakDays;
  final int learnedWords;
  final int totalXp;
  final bool lastSessionPerfect;
  final int examsPassed;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isEarned,
    this.goal,
    this.current,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(AchievementFacts f) isEarned;

  /// For countable achievements: the target and how far the user is.
  final int? goal;
  final int Function(AchievementFacts f)? current;
}

final achievements = <Achievement>[
  Achievement(
    id: 'first_lesson',
    title: 'Первые шаги',
    description: 'Пройти первый урок',
    icon: Icons.flag_rounded,
    isEarned: (f) => f.quizzesCompleted >= 1,
    goal: 1,
    current: (f) => f.quizzesCompleted,
  ),
  Achievement(
    id: 'perfect',
    title: 'Без ошибок',
    description: 'Пройти урок без единой ошибки',
    icon: Icons.star_rounded,
    isEarned: (f) => f.lastSessionPerfect,
  ),
  Achievement(
    id: 'streak_3',
    title: '3 дня подряд',
    description: 'Заниматься 3 дня подряд',
    icon: Icons.local_fire_department_rounded,
    isEarned: (f) => f.streakDays >= 3,
    goal: 3,
    current: (f) => f.streakDays,
  ),
  Achievement(
    id: 'streak_7',
    title: '7 дней подряд',
    description: 'Заниматься неделю без пропусков',
    icon: Icons.whatshot_rounded,
    isEarned: (f) => f.streakDays >= 7,
    goal: 7,
    current: (f) => f.streakDays,
  ),
  Achievement(
    id: 'words_50',
    title: '50 слов',
    description: 'Выучить 50 слов',
    icon: Icons.menu_book_rounded,
    isEarned: (f) => f.learnedWords >= 50,
    goal: 50,
    current: (f) => f.learnedWords,
  ),
  Achievement(
    id: 'words_100',
    title: '100 слов',
    description: 'Выучить 100 слов',
    icon: Icons.auto_stories_rounded,
    isEarned: (f) => f.learnedWords >= 100,
    goal: 100,
    current: (f) => f.learnedWords,
  ),
  Achievement(
    id: 'exam_1',
    title: 'Первый экзамен',
    description: 'Сдать экзамен за раздел',
    icon: Icons.workspace_premium_rounded,
    isEarned: (f) => f.examsPassed >= 1,
    goal: 1,
    current: (f) => f.examsPassed,
  ),
  Achievement(
    id: 'all_exams',
    title: 'Выпускник',
    description: 'Сдать экзамены всех разделов',
    icon: Icons.school_rounded,
    isEarned: (f) => f.examsPassed >= 4,
    goal: 4,
    current: (f) => f.examsPassed,
  ),
  Achievement(
    id: 'xp_1000',
    title: '1000 XP',
    description: 'Набрать 1000 очков опыта',
    icon: Icons.bolt_rounded,
    isEarned: (f) => f.totalXp >= 1000,
    goal: 1000,
    current: (f) => f.totalXp,
  ),
];

Achievement? achievementById(String id) {
  for (final a in achievements) {
    if (a.id == id) return a;
  }
  return null;
}
