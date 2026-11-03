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
  CourseSection(
    id: 'everyday',
    title: 'Повседневность',
    titleKk: 'Күнделікті өмір',
    color: Color(0xFF1B7F4E),
    categoryIds: [
      'phrases',
      'people',
      'feelings',
      'shopping',
      'groceries',
      'household',
      'hobby',
      'sport',
    ],
  ),
  CourseSection(
    id: 'travel',
    title: 'Путешествия',
    titleKk: 'Саяхат',
    color: Color(0xFF2A62B0),
    categoryIds: [
      'travel',
      'directions',
      'services',
      'measures',
      'geography',
      'wildlife',
    ],
  ),
  CourseSection(
    id: 'society',
    title: 'Общество',
    titleKk: 'Қоғам',
    color: Color(0xFF8A4FA8),
    categoryIds: [
      'office',
      'tech',
      'media',
      'state',
      'science',
      'verbs2',
      'adjectives2',
      'traditions',
      'ideas',
    ],
  ),
  CourseSection(
    id: 'world',
    title: 'Мир вокруг',
    titleKk: 'Айнала әлем',
    color: Color(0xFF9C4221),
    categoryIds: [
      'weather2',
      'water',
      'materials',
      'tools',
      'body2',
      'cooking',
      'clothes2',
      'furniture',
      'relatives',
      'city2',
    ],
  ),
  CourseSection(
    id: 'career',
    title: 'Учёба и карьера',
    titleKk: 'Білім және мансап',
    color: Color(0xFF4A5A9C),
    categoryIds: [
      'university',
      'economy',
      'arts',
      'music',
      'verbs3',
      'adjectives3',
      'adverbs2',
      'phrases2',
    ],
  ),
  CourseSection(
    id: 'daily2',
    title: 'Жизненные ситуации',
    titleKk: 'Өмірлік жағдайлар',
    color: Color(0xFF00796B),
    categoryIds: [
      'kazakh_food',
      'bank_post',
      'doctor',
      'anatomy',
      'car',
      'emergency',
      'jobs2',
      'time2',
      'phrases3',
      'opinion',
      'sounds',
    ],
  ),
  CourseSection(
    id: 'heritage',
    title: 'Наследие степи',
    titleKk: 'Дала мұрасы',
    color: Color(0xFF8A5A00),
    categoryIds: [
      'village',
      'yurt',
      'horse',
      'national_clothes',
      'instruments',
      'wedding',
      'history',
      'kazakhstan',
      'landscape',
      'childhood',
      'colors2',
    ],
  ),
  CourseSection(
    id: 'discovery',
    title: 'Знания и природа',
    titleKk: 'Білім мен табиғат',
    color: Color(0xFF56661C),
    categoryIds: [
      'school_subjects',
      'math',
      'language',
      'games_it',
      'space',
      'ecology',
      'birds',
      'insects',
      'plants2',
      'berries_nuts',
      'motion',
    ],
  ),
  CourseSection(
    id: 'home2',
    title: 'Дом и быт',
    titleKk: 'Үй тұрмысы',
    color: Color(0xFF7B4B2A),
    categoryIds: [
      'bathroom',
      'kitchen_tech',
      'appliances',
      'bedroom',
      'sewing',
      'baby',
      'pets',
      'building',
      'vegetables',
      'spices',
      'fish',
    ],
  ),
  CourseSection(
    id: 'society2',
    title: 'Общество и право',
    titleKk: 'Қоғам және құқық',
    color: Color(0xFF455A64),
    categoryIds: [
      'politics',
      'law',
      'army',
      'jobs3',
      'job_search',
      'money2',
      'social_media',
      'smartphone',
      'psychology',
      'friendship',
      'medicine2',
    ],
  ),
  CourseSection(
    id: 'planet',
    title: 'Планета и путешествия',
    titleKk: 'Ғаламшар және саяхат',
    color: Color(0xFF2E7D32),
    categoryIds: [
      'countries',
      'nationalities',
      'airport',
      'railway',
      'camping',
      'mammals',
      'geology',
      'chemistry',
      'biology',
      'sports2',
    ],
  ),
  CourseSection(
    id: 'leisure',
    title: 'Культура и досуг',
    titleKk: 'Мәдениет және демалыс',
    color: Color(0xFFAD1457),
    categoryIds: [
      'books',
      'board_games',
      'beauty',
      'photo',
      'music2',
      'world_food',
      'drinks',
      'sweets',
      'party',
    ],
  ),
  CourseSection(
    id: 'talk1',
    title: 'Фразы на каждый день',
    titleKk: 'Күнделікті сөйлемдер',
    color: Color(0xFF6A1B9A),
    categoryIds: [
      'ph_shop',
      'ph_doctor',
      'ph_taxi',
      'ph_phone',
      'ph_school',
      'ph_guest',
      'ph_weather',
      'ph_feel',
      'ph_ask',
      'ph_meet',
      'ph_cafe',
    ],
  ),
  CourseSection(
    id: 'talk2',
    title: 'Дом, отдых и город',
    titleKk: 'Үй, демалыс және қала',
    color: Color(0xFF00838F),
    categoryIds: [
      'ph_home',
      'ph_holiday',
      'ph_travel',
      'ph_sport',
      'ph_kids',
      'garden',
      'beach',
      'winter_fun',
      'stationery',
      'city_signs',
      'shapes3d',
      'big_numbers',
      'computer_actions',
    ],
  ),
  CourseSection(
    id: 'talk3',
    title: 'Работа и общение',
    titleKk: 'Жұмыс және қарым-қатынас',
    color: Color(0xFF283593),
    categoryIds: [
      'ph_work',
      'ph_bank',
      'ph_internet',
      'ph_praise',
      'ph_polite',
      'ph_plans',
      'ph_agree',
      'ph_kitchen',
      'ph_city',
      'ph_nature',
    ],
  ),
  CourseSection(
    id: 'talk4',
    title: 'Учёба, семья и здоровье',
    titleKk: 'Оқу, отбасы және денсаулық',
    color: Color(0xFF8E4B00),
    categoryIds: [
      'ph_learn',
      'ph_schedule',
      'ph_animals',
      'ph_online_shop',
      'ph_health',
      'ph_family',
      'ph_bazaar',
      'ph_subjects',
    ],
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
