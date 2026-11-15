import '../../data/database/app_database.dart';
import '../../data/repositories/lesson_repository.dart';

/// A card of the album: something from Kazakh culture or nature.
class AlbumCard {
  const AlbumCard(this.emoji, this.kk, this.ru, this.fact);

  final String emoji;
  final String kk;
  final String ru;
  final String fact;
}

/// Cards open with finished topics: the first after one topic, then one
/// for every [topicsPerCard] more. Nothing is bought or spent.
const albumCards = [
  AlbumCard(
    '🛖',
    'Киіз үй',
    'Юрта',
    'Юрту можно собрать за час-два. Круг на её вершине называется шаңырақ.',
  ),
  AlbumCard(
    '🪕',
    'Домбыра',
    'Домбра',
    'У домбры всего две струны, но на ней играют сложные мелодии — күй.',
  ),
  AlbumCard(
    '🦅',
    'Бүркіт',
    'Беркут',
    'С беркутом охотятся в степи. Охотника с беркутом зовут бүркітші.',
  ),
  AlbumCard(
    '🐎',
    'Жылқы',
    'Конь',
    'Пословица говорит: «Ат — ер қанаты» — конь — крылья джигита.',
  ),
  AlbumCard(
    '🍩',
    'Бауырсақ',
    'Баурсаки',
    'Пышные шарики из теста, жаренные в масле. Без них не бывает дастархана.',
  ),
  AlbumCard(
    '🥛',
    'Қымыз',
    'Кумыс',
    'Напиток из кобыльего молока. Его пьют летом на жайлау.',
  ),
  AlbumCard(
    '🌷',
    'Наурыз',
    'Наурыз',
    'Праздник весны 21–23 марта. Готовят наурыз-көже из семи продуктов.',
  ),
  AlbumCard(
    '🐆',
    'Барыс',
    'Снежный барс',
    'Барс живёт высоко в горах. Он есть на гербе Алматы — и в нашем приложении!',
  ),
  AlbumCard(
    '🎲',
    'Тоғызқұмалақ',
    'Тогыз кумалак',
    'Игра на доске с лунками и 162 камешками-құмалақ. Нужно уметь считать наперёд.',
  ),
  AlbumCard(
    '🦴',
    'Асық',
    'Асыки',
    'Игра бараньими косточками: их ставят в ряд и выбивают битком — сақа.',
  ),
  AlbumCard(
    '🏇',
    'Көкпар',
    'Кокпар',
    'Конная игра двух команд, где нужно занести тушу козла в «ворота».',
  ),
  AlbumCard(
    '🏁',
    'Бәйге',
    'Байга',
    'Скачки на длинные дистанции. Часто на конях скачут юные наездники.',
  ),
  AlbumCard(
    '☀️',
    'Шаңырақ',
    'Шанырак',
    'Шаңырақ — символ дома и семьи. Его можно увидеть на гербе Казахстана.',
  ),
  AlbumCard(
    '🌳',
    'Бәйтерек',
    'Байтерек',
    'Монумент в Астане высотой 97 метров — в память о 1997 годе, когда Астана стала столицей.',
  ),
  AlbumCard(
    '🏜️',
    'Шарын',
    'Чарынский каньон',
    'Каньон под Алматы называют младшим братом Гранд-Каньона.',
  ),
  AlbumCard(
    '🌷',
    'Қызғалдақ',
    'Тюльпан',
    'Дикие тюльпаны растут в степях и горах Казахстана. Многие считают их родиной именно эти места.',
  ),
  AlbumCard(
    '🍎',
    'Алма',
    'Яблоко',
    'Дикая яблоня Сиверса из гор Алатау — предок яблок, которые едят во всём мире.',
  ),
  AlbumCard(
    '🚀',
    'Байқоңыр',
    'Байконур',
    'Отсюда в 1961 году в космос полетел первый человек — Юрий Гагарин.',
  ),
  AlbumCard(
    '🌊',
    'Каспий',
    'Каспийское море',
    'Самое большое озеро на Земле. Казахстан — на его северо-восточном берегу.',
  ),
  AlbumCard(
    '💧',
    'Балқаш',
    'Балхаш',
    'Удивительное озеро: в одной части вода пресная, в другой — солоноватая.',
  ),
  AlbumCard(
    '📜',
    'Абай',
    'Абай Кунанбаев',
    'Великий поэт и мыслитель. Его «Қара сөздер» — «Слова назидания» — читают и сегодня.',
  ),
  AlbumCard(
    '🧥',
    'Шапан',
    'Чапан',
    'Нарядный халат. Его дарят уважаемым гостям в знак почёта.',
  ),
  AlbumCard(
    '🍽️',
    'Дастарқан',
    'Дастархан',
    'Накрытый для гостей стол. Гостя у казахов принято угощать лучшим.',
  ),
  AlbumCard(
    '🍖',
    'Ет',
    'Бешбармак',
    'Главное праздничное блюдо из мяса и теста. «Бешбармак» значит «пять пальцев».',
  ),
  AlbumCard(
    '👴',
    'Жеті ата',
    'Семь предков',
    'Казахи стараются знать своих предков до седьмого колена.',
  ),
  AlbumCard(
    '👣',
    'Тұсаукесер',
    'Тусаукесер',
    'Обряд для малыша, который делает первые шаги: «разрезают путы» на его ножках.',
  ),
  AlbumCard(
    '🛏️',
    'Бесік',
    'Колыбель',
    'Деревянная колыбель. Над ней поют колыбельную — бесік жыры.',
  ),
  AlbumCard(
    '🎤',
    'Айтыс',
    'Айтыс',
    'Состязание акынов: они сочиняют стихи прямо на сцене и отвечают друг другу.',
  ),
  AlbumCard(
    '👑',
    'Алтын адам',
    'Золотой человек',
    'Древний воин в золотых доспехах, найденный в кургане Иссык. Один из символов страны.',
  ),
  AlbumCard(
    '🎶',
    'Күй',
    'Кюй',
    'Мелодия для домбры, которая рассказывает историю без слов. Известный күй — «Адай» Курмангазы.',
  ),
  AlbumCard(
    '🌿',
    'Жусан',
    'Полынь',
    'Горький запах степной полыни для казахов — запах родины.',
  ),
  AlbumCard(
    '🔷',
    'Ою-өрнек',
    'Орнамент',
    'Казахский узор. Самый известный — «қошқар мүйіз», бараньи рога.',
  ),
  AlbumCard(
    '🔤',
    'Латын әліпбиі',
    'Латиница',
    'В 2021 году утвердили новый казахский алфавит на латинице. Он есть в приложении!',
  ),
];

/// Topics finished per new card after the first.
const topicsPerCard = 6;

/// Topics to finish for card [index].
int topicsForCard(int index) => index == 0 ? 1 : index * topicsPerCard;

/// Cards open with [finishedTopics] topics done.
int cardsOpen(int finishedTopics) {
  var n = 0;
  while (n < albumCards.length && finishedTopics >= topicsForCard(n)) {
    n++;
  }
  return n;
}

/// Words of a topic by how well they are known.
typedef TopicMastery = ({int learned, int strong});

/// From this box a word is known «strongly» (a week between reviews).
const strongBox = 4;

/// 0–3 stars: one for finishing the topic, two when half its words are
/// learned, three when every word is known strongly. Learning takes
/// reviews spread over days, so stars come from coming back, not cramming.
int topicStars(TopicState t, TopicMastery? m, int wordCount) {
  if (!t.completed) return 0;
  if (m == null || wordCount == 0) return 1;
  if (m.strong >= wordCount) return 3;
  if (m.learned * 2 >= wordCount) return 2;
  return 1;
}

/// Learned and strongly known words per topic.
Map<String, TopicMastery> masteryOf(
  Iterable<Word> words,
  Map<int, WordProgressData> progress,
) {
  final learned = <String, int>{};
  final strong = <String, int>{};
  for (final w in words) {
    final box = progress[w.id]?.box ?? 0;
    if (box >= 3) learned.update(w.categoryId, (n) => n + 1, ifAbsent: () => 1);
    if (box >= strongBox) {
      strong.update(w.categoryId, (n) => n + 1, ifAbsent: () => 1);
    }
  }
  return {
    for (final id in {...learned.keys, ...strong.keys})
      id: (learned: learned[id] ?? 0, strong: strong[id] ?? 0),
  };
}

/// Topics with all three stars.
int threeStarTopics(
  CourseState course,
  Map<String, TopicMastery> mastery,
  Map<String, int> sizes,
) => course.topics
    .where(
      (t) =>
          topicStars(t, mastery[t.category.id], sizes[t.category.id] ?? 0) == 3,
    )
    .length;

/// One thing on the summer pasture picture, appearing at [words] learned.
class ZhailauStage {
  const ZhailauStage(this.words, this.title);

  final int words;
  final String title;
}

const zhailauStages = [
  ZhailauStage(5, 'трава'),
  ZhailauStage(20, 'цветы'),
  ZhailauStage(40, 'юрта'),
  ZhailauStage(75, 'конь'),
  ZhailauStage(120, 'деревья'),
  ZhailauStage(180, 'овцы'),
  ZhailauStage(250, 'вторая юрта'),
  ZhailauStage(350, 'река'),
  ZhailauStage(500, 'горы'),
  ZhailauStage(700, 'беркут'),
  ZhailauStage(1000, 'верблюд'),
  ZhailauStage(1500, 'радуга'),
];

/// Stages reached with [learnedWords].
int zhailauStage(int learnedWords) =>
    zhailauStages.where((s) => learnedWords >= s.words).length;
