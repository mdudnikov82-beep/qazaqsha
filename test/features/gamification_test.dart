import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/lesson_repository.dart';
import 'package:qazaqsha/data/repositories/quest_repository.dart';
import 'package:qazaqsha/data/repositories/stats_repository.dart';
import 'package:qazaqsha/features/gamification/collection.dart';
import 'package:qazaqsha/features/gamification/quests.dart';

import '../helpers.dart';

TopicState _topic({required bool done}) => TopicState(
  category: const Category(
    id: 't',
    titleRu: 't',
    titleKk: 't',
    icon: 'pin',
    sortOrder: 0,
  ),
  lessonCount: 2,
  lessonsDone: done ? 2 : 1,
  unlocked: true,
);

void main() {
  group('weekly quests', () {
    test('a week starts on Monday', () {
      // 15 Nov 2026 is a Sunday, 16 Nov a Monday.
      expect(weekOf(DateTime(2026, 11, 15, 23)), DateTime.utc(2026, 11, 9));
      expect(weekOf(DateTime(2026, 11, 16, 1)), DateTime.utc(2026, 11, 16));
    });

    test('three different quests, the same all week, new next week', () {
      final sets = <String>{};
      for (var d = 0; d < 7 * 30; d++) {
        final day = DateTime(2026, 1, 5).add(Duration(days: d));
        final quests = questsForWeek(day);
        expect(quests, hasLength(questsPerWeek));
        expect(quests.map((q) => q.key).toSet(), hasLength(questsPerWeek));
        expect(
          quests
              .where(
                (q) => q.key == QuestKey.dictations || q.key == QuestKey.fixes,
              )
              .length,
          lessThanOrEqualTo(1),
        );
        expect(questsForWeek(weekOf(day)), quests);
        sets.add(quests.map((q) => q.title).join('|'));
      }
      // Thirty weeks bring variety.
      expect(sets.length, greaterThan(10));
    });

    test('counters add up per week and count study days', () async {
      final db = testDatabase();
      addTearDown(db.close);
      final quests = QuestRepository(db);
      final stats = StatsRepository(db);
      final monday = DateTime(2026, 11, 16, 10);
      await quests.add(QuestKey.lessons, monday);
      await quests.add(
        QuestKey.lessons,
        monday.add(const Duration(days: 2)),
        2,
      );
      await quests.add(QuestKey.lessons, monday.add(const Duration(days: 7)));
      for (final d in [0, 1, 3]) {
        await stats.recordSession(
          xp: 10,
          correct: 1,
          total: 1,
          now: monday.add(Duration(days: d)),
        );
      }
      final week = await quests.watchWeek(monday).first;
      expect(week[QuestKey.lessons], 3);
      expect(week[QuestKey.days], 3);

      // Completing this week's quests counts toward the total.
      for (final q in questsForWeek(monday)) {
        if (q.key != QuestKey.days) await quests.add(q.key, monday, q.target);
      }
      final done = await quests.completedTotal();
      final daysQuest = questsForWeek(monday)
          .where((q) => q.key == QuestKey.days && q.target > 3)
          .length;
      expect(done, questsPerWeek - daysQuest);
    });
  });

  group('album, stars and the pasture', () {
    test('first card after one topic, then one per six', () {
      expect(cardsOpen(0), 0);
      expect(cardsOpen(1), 1);
      expect(cardsOpen(5), 1);
      expect(cardsOpen(6), 2);
      expect(cardsOpen(12), 3);
      expect(cardsOpen(10000), albumCards.length);
      // Every card can be reached within the course's topics.
      expect(topicsForCard(albumCards.length - 1), lessThanOrEqualTo(198));
    });

    test('stars come from finishing and then knowing the words', () {
      expect(topicStars(_topic(done: false), null, 10), 0);
      expect(topicStars(_topic(done: true), null, 10), 1);
      expect(topicStars(_topic(done: true), (learned: 4, strong: 0), 10), 1);
      expect(topicStars(_topic(done: true), (learned: 5, strong: 2), 10), 2);
      expect(topicStars(_topic(done: true), (learned: 10, strong: 10), 10), 3);
    });

    test('the pasture grows in order', () {
      expect(zhailauStage(0), 0);
      expect(zhailauStage(5), 1);
      expect(zhailauStage(zhailauStages.last.words), zhailauStages.length);
      final words = [for (final s in zhailauStages) s.words];
      expect(words, [...words]..sort());
    });
  });
}
