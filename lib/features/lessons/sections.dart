import 'dart:ui' show Color;

/// The course is split into sections; each ends with an exam that must be
/// passed before the next section opens.
class CourseSection {
  const CourseSection({
    required this.id,
    required this.title,
    required this.titleKk,
    required this.color,
    required this.categoryIds,
  });

  final String id;
  final String title;
  final String titleKk;

  /// The section's colour on the ladder. Dark enough for white icons and
  /// text on it in both themes.
  final Color color;

  /// Topics of the section, in course order.
  final List<String> categoryIds;
}

const courseSections = [
  CourseSection(
    id: 'basics',
    title: 'Основы',
    titleKk: 'Негіздер',
    color: Color(0xFF00789A),
    categoryIds: ['greetings', 'family', 'numbers', 'colors', 'time', 'months'],
  ),
  CourseSection(
    id: 'life',
    title: 'Быт',
    titleKk: 'Тұрмыс',
    color: Color(0xFFB85F00),
    categoryIds: [
      'food',
      'kitchen',
      'animals',
      'nature',
      'body',
      'health',
      'home',
      'clothes',
    ],
  ),
  CourseSection(
    id: 'city',
    title: 'Город и люди',
    titleKk: 'Қала',
    color: Color(0xFF5B4BC4),
    categoryIds: ['city', 'transport', 'jobs', 'school'],
  ),
  CourseSection(
    id: 'speech',
    title: 'Речь',
    titleKk: 'Сөйлеу',
    color: Color(0xFFB3366A),
    categoryIds: ['verbs', 'adjectives', 'pronouns', 'adverbs', 'culture'],
  ),
];

/// Share of right answers needed to pass a section exam, in percent.
const examPassScore = 80;

/// Bonus XP for passing an exam (first time or again).
const examPassBonusXp = 50;

CourseSection? sectionById(String id) {
  for (final s in courseSections) {
    if (s.id == id) return s;
  }
  return null;
}

/// The section a topic belongs to.
CourseSection? sectionOfCategory(String categoryId) {
  for (final s in courseSections) {
    if (s.categoryIds.contains(categoryId)) return s;
  }
  return null;
}
