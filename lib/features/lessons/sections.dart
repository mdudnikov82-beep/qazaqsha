/// The course is split into sections; each ends with an exam that must be
/// passed before the next section opens.
class CourseSection {
  const CourseSection({
    required this.id,
    required this.title,
    required this.categoryIds,
  });

  final String id;
  final String title;

  /// Topics of the section, in course order.
  final List<String> categoryIds;
}

const courseSections = [
  CourseSection(
    id: 'basics',
    title: 'Основы',
    categoryIds: ['greetings', 'family', 'numbers', 'colors', 'time', 'months'],
  ),
  CourseSection(
    id: 'life',
    title: 'Быт',
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
    categoryIds: ['city', 'transport', 'jobs', 'school'],
  ),
  CourseSection(
    id: 'speech',
    title: 'Речь',
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
