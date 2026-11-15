import 'package:flutter/material.dart';

import '../lessons/sections.dart';
import 'collection.dart';

/// What achievements are checked against after each session.
class AchievementFacts {
  const AchievementFacts({
    required this.quizzesCompleted,
    required this.streakDays,
    required this.learnedWords,
    required this.totalXp,
    this.fixedMistakes = 0,
    this.examsPassed = 0,
    this.albumCards = 0,
    this.questsDone = 0,
    this.threeStarTopics = 0,
  });

  final int quizzesCompleted;
  final int streakDays;
  final int learnedWords;
  final int totalXp;

  /// Mistakes from the notebook later answered right.
  final int fixedMistakes;
  final int examsPassed;

  /// Cards of the album open, weekly quests done, topics with 3 stars.
  final int albumCards;
  final int questsDone;
  final int threeStarTopics;
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
  for (final (n, title, icon) in [
    (10, 'Работа над ошибками', Icons.build_rounded),
    (50, 'Учусь на ошибках', Icons.handyman_rounded),
    (100, 'Ошибки — мои учителя', Icons.psychology_rounded),
    (250, 'Мастер исправлений', Icons.auto_fix_high_rounded),
  ])
    Achievement(
      id: 'fixed_$n',
      title: title,
      description: 'Исправить $n ошибок: ответить верно там, где раньше ошибся',
      icon: icon,
      isEarned: (f) => f.fixedMistakes >= n,
      goal: n,
      current: (f) => f.fixedMistakes,
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
  for (final (n, title, icon) in [
    (250, 'Словарный запас', Icons.local_library_rounded),
    (500, 'Полкилометра слов', Icons.library_books_rounded),
    (1000, 'Тысяча слов', Icons.collections_bookmark_rounded),
  ])
    Achievement(
      id: 'words_$n',
      title: title,
      description: 'Выучить $n слов',
      icon: icon,
      isEarned: (f) => f.learnedWords >= n,
      goal: n,
      current: (f) => f.learnedWords,
    ),
  Achievement(
    id: 'streak_14',
    title: 'Две недели',
    description: 'Заниматься 14 дней подряд (заморозки помогают)',
    icon: Icons.local_fire_department_rounded,
    isEarned: (f) => f.streakDays >= 14,
    goal: 14,
    current: (f) => f.streakDays,
  ),
  Achievement(
    id: 'streak_30',
    title: 'Месяц вместе',
    description: 'Заниматься 30 дней подряд (заморозки помогают)',
    icon: Icons.calendar_month_rounded,
    isEarned: (f) => f.streakDays >= 30,
    goal: 30,
    current: (f) => f.streakDays,
  ),
  for (final (n, title, icon) in [
    (50, 'Полсотни занятий', Icons.event_available_rounded),
    (200, 'Двести занятий', Icons.event_repeat_rounded),
  ])
    Achievement(
      id: 'sessions_$n',
      title: title,
      description: 'Пройти $n уроков, повторений или упражнений',
      icon: icon,
      isEarned: (f) => f.quizzesCompleted >= n,
      goal: n,
      current: (f) => f.quizzesCompleted,
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
    id: 'exam_5',
    title: 'Пять разделов',
    description: 'Сдать экзамены пяти разделов',
    icon: Icons.workspace_premium_rounded,
    isEarned: (f) => f.examsPassed >= 5,
    goal: 5,
    current: (f) => f.examsPassed,
  ),
  Achievement(
    id: 'all_exams',
    title: 'Выпускник',
    description: 'Сдать экзамены всех разделов',
    icon: Icons.school_rounded,
    isEarned: (f) => f.examsPassed >= courseSections.length,
    goal: courseSections.length,
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
  Achievement(
    id: 'xp_5000',
    title: '5000 XP',
    description: 'Набрать 5000 очков опыта',
    icon: Icons.electric_bolt_rounded,
    isEarned: (f) => f.totalXp >= 5000,
    goal: 5000,
    current: (f) => f.totalXp,
  ),
  for (final (n, id, title, icon) in [
    (1, 'album_1', 'Первая карточка', Icons.style_rounded),
    (10, 'album_10', 'Коллекционер', Icons.collections_rounded),
    (albumCards.length, 'album_all', 'Весь альбом', Icons.photo_album_rounded),
  ])
    Achievement(
      id: id,
      title: title,
      description: n == 1
          ? 'Открыть первую карточку альбома'
          : 'Собрать $n карточек альбома',
      icon: icon,
      isEarned: (f) => f.albumCards >= n,
      goal: n,
      current: (f) => f.albumCards,
    ),
  for (final (n, id, title, icon) in [
    (1, 'quest_1', 'Задание недели', Icons.task_alt_rounded),
    (12, 'quests_12', 'Двенадцать испытаний', Icons.emoji_events_rounded),
  ])
    Achievement(
      id: id,
      title: title,
      description: n == 1
          ? 'Выполнить задание недели'
          : 'Выполнить $n заданий недели',
      icon: icon,
      isEarned: (f) => f.questsDone >= n,
      goal: n,
      current: (f) => f.questsDone,
    ),
  for (final (n, id, title, icon) in [
    (1, 'stars3_1', 'Три звезды', Icons.star_rounded),
    (10, 'stars3_10', 'Созвездие', Icons.auto_awesome_rounded),
  ])
    Achievement(
      id: id,
      title: title,
      description: n == 1
          ? 'Получить три звезды за тему: выучить все её слова крепко'
          : 'Получить три звезды за $n тем',
      icon: icon,
      isEarned: (f) => f.threeStarTopics >= n,
      goal: n,
      current: (f) => f.threeStarTopics,
    ),
  Achievement(
    id: 'zhailau_full',
    title: 'Цветущий жайлау',
    description:
        'Вырастить весь жайлау: выучить ${zhailauStages.last.words} слов',
    icon: Icons.landscape_rounded,
    isEarned: (f) => f.learnedWords >= zhailauStages.last.words,
    goal: zhailauStages.last.words,
    current: (f) => f.learnedWords,
  ),
];

Achievement? achievementById(String id) {
  for (final a in achievements) {
    if (a.id == id) return a;
  }
  return null;
}
