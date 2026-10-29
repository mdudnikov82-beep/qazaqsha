import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/custom_words/word_import.dart';
import '../database/app_database.dart';
import 'custom_words_repository.dart';

/// A backup code doesn't start like this, or can't be read.
class BadBackupCode implements Exception {
  const BadBackupCode();
}

/// Progress as one text code the user can keep anywhere (a chat, notes)
/// and paste back on another phone or in the web version.
///
/// Words are matched by their Kazakh and Russian text, not by id, so a
/// backup survives dictionary updates. Settings (theme, reminders…) stay
/// with the device and aren't included.
class BackupRepository {
  BackupRepository(this._db, this._customWords);

  final AppDatabase _db;
  final CustomWordsRepository _customWords;

  static const _prefix = 'QZB1-';

  Future<String> exportCode() async {
    final s = await (_db.select(
      _db.userStats,
    )..where((r) => r.id.equals(1))).getSingle();
    final words = {for (final w in await _db.select(_db.words).get()) w.id: w};
    int? ms(DateTime? t) => t?.millisecondsSinceEpoch;

    final data = {
      'stats': {
        'xp': s.xp,
        'streak': s.streakDays,
        'best': s.bestStreak,
        'last': ms(s.lastActiveDate),
        'goal': s.dailyGoalXp,
        'dxp': s.dailyXp,
        'dday': ms(s.dailyXpDate),
        'quizzes': s.quizzesCompleted,
        'ok': s.answersCorrect,
        'total': s.answersTotal,
        'sec': s.studySeconds,
        'name': s.userName,
      },
      'custom': [
        for (final w in words.values)
          if (w.categoryId == customCategoryId) [w.kk, w.ru],
      ],
      'words': [
        for (final p in await _db.select(_db.wordProgress).get())
          if (words[p.wordId] case final w?)
            [
              w.kk,
              w.ru,
              p.status.index,
              p.correctCount,
              p.wrongCount,
              ms(p.lastSeenAt),
              ms(p.nextReviewAt),
              p.isFavorite ? 1 : 0,
              p.box,
            ],
      ],
      'lessons': [
        for (final l in await _db.select(_db.lessonProgress).get())
          [l.categoryId, l.lessonIndex, l.bestScore, ms(l.completedAt)],
      ],
      'exams': [
        for (final e in await _db.select(_db.examProgress).get())
          [e.sectionId, e.bestScore, ms(e.passedAt)],
      ],
      'ach': [
        for (final a in await _db.select(_db.unlockedAchievements).get())
          [a.id, ms(a.unlockedAt)],
      ],
      'days': [
        for (final d in await _db.select(_db.dailyActivity).get())
          [ms(d.day), d.xp, d.seconds, d.sessions],
      ],
    };
    final json = utf8.encode(jsonEncode({'v': 1, ...data}));
    return _prefix + base64Url.encode(json).replaceAll('=', '');
  }

  /// Replaces all progress with the backup's. Throws [BadBackupCode].
  Future<void> importCode(String code) async {
    final Map<String, dynamic> data;
    try {
      final body = code.trim();
      if (!body.startsWith(_prefix)) throw const BadBackupCode();
      final b64 = body.substring(_prefix.length);
      final padded = b64.padRight((b64.length + 3) ~/ 4 * 4, '=');
      data = jsonDecode(
        utf8.decode(base64Url.decode(padded)),
      ) as Map<String, dynamic>;
      if (data['v'] != 1) throw const BadBackupCode();
    } on BadBackupCode {
      rethrow;
    } catch (_) {
      throw const BadBackupCode();
    }

    DateTime? at(Object? ms) =>
        ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms as int);
    List<List<dynamic>> rows(String key) => [
      for (final r in (data[key] as List? ?? const [])) r as List<dynamic>,
    ];

    try {
      await _db.transaction(() async {
        await _clearProgress();
        final custom = rows('custom');
        if (custom.isNotEmpty) {
          await _customWords.addWords([
            for (final w in custom)
              ImportedWord(w[0] as String, w[1] as String),
          ]);
        }
        final ids = {
          for (final w in await _db.select(_db.words).get()) (w.kk, w.ru): w.id,
        };
        await _db.batch((b) {
          for (final r in rows('words')) {
            final id = ids[(r[0] as String, r[1] as String)];
            // A word that is no longer in the dictionary.
            if (id == null) continue;
            b.insert(
              _db.wordProgress,
              WordProgressCompanion.insert(
                wordId: Value(id),
                status: Value(LearningStatus.values[r[2] as int]),
                correctCount: Value(r[3] as int),
                wrongCount: Value(r[4] as int),
                lastSeenAt: Value(at(r[5])),
                nextReviewAt: Value(at(r[6])),
                isFavorite: Value(r[7] == 1),
                box: Value(r[8] as int),
              ),
            );
          }
          for (final r in rows('lessons')) {
            b.insert(
              _db.lessonProgress,
              LessonProgressCompanion.insert(
                categoryId: r[0] as String,
                lessonIndex: r[1] as int,
                bestScore: r[2] as int,
                completedAt: at(r[3])!,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
          for (final r in rows('exams')) {
            b.insert(
              _db.examProgress,
              ExamProgressCompanion.insert(
                sectionId: r[0] as String,
                bestScore: r[1] as int,
                passedAt: Value(at(r[2])),
              ),
            );
          }
          for (final r in rows('ach')) {
            b.insert(
              _db.unlockedAchievements,
              UnlockedAchievementsCompanion.insert(
                id: r[0] as String,
                unlockedAt: at(r[1])!,
              ),
            );
          }
          for (final r in rows('days')) {
            b.insert(
              _db.dailyActivity,
              DailyActivityCompanion.insert(
                day: at(r[0])!,
                xp: Value(r[1] as int),
                seconds: Value(r[2] as int),
                sessions: Value(r[3] as int),
              ),
            );
          }
        });
        final s = data['stats'] as Map<String, dynamic>;
        await (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
          UserStatsCompanion(
            xp: Value(s['xp'] as int),
            streakDays: Value(s['streak'] as int),
            bestStreak: Value(s['best'] as int),
            lastActiveDate: Value(at(s['last'])),
            dailyGoalXp: Value(s['goal'] as int),
            dailyXp: Value(s['dxp'] as int),
            dailyXpDate: Value(at(s['dday'])),
            quizzesCompleted: Value(s['quizzes'] as int),
            answersCorrect: Value(s['ok'] as int),
            answersTotal: Value(s['total'] as int),
            studySeconds: Value(s['sec'] as int),
            userName: Value(s['name'] as String?),
            onboardingDone: const Value(true),
          ),
        );
      });
    } on TypeError {
      // Well-formed base64 and JSON, but not a backup's shape.
      throw const BadBackupCode();
    }
  }

  /// Starts learning over. Own words and settings are kept.
  Future<void> resetProgress() => _db.transaction(() async {
    await _clearProgress();
    await (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
      const UserStatsCompanion(
        xp: Value(0),
        streakDays: Value(0),
        bestStreak: Value(0),
        lastActiveDate: Value(null),
        dailyXp: Value(0),
        dailyXpDate: Value(null),
        quizzesCompleted: Value(0),
        answersCorrect: Value(0),
        answersTotal: Value(0),
        studySeconds: Value(0),
      ),
    );
  });

  Future<void> _clearProgress() async {
    await _db.delete(_db.wordProgress).go();
    await _db.delete(_db.lessonProgress).go();
    await _db.delete(_db.examProgress).go();
    await _db.delete(_db.unlockedAchievements).go();
    await _db.delete(_db.dailyActivity).go();
  }
}
