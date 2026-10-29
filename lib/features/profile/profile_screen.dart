import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/reminders.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/ornament.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/backup_repository.dart';
import '../gamification/achievements.dart';
import '../gamification/progress_rules.dart';
import 'activity_calendar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    if (stats.value == null) return LoadingScaffold(error: stats.error);
    final s = stats.value!;
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const {};
    final activity =
        ref.watch(activityProvider(activityWeeks)).value ?? const [];
    final examsPassed = ref.watch(courseProvider).value?.examsPassed ?? 0;
    final now = DateTime.now();
    final learned = progress.values
        .where((p) => p.status == LearningStatus.learned)
        .length;
    final streak = visibleStreak(
      current: s.streakDays,
      lastActive: s.lastActiveDate,
      now: now,
      freezes: s.streakFreezes,
    );
    final facts = AchievementFacts(
      quizzesCompleted: s.quizzesCompleted,
      streakDays: streak,
      learnedWords: learned,
      totalXp: s.xp,
      lastSessionPerfect: false,
      examsPassed: examsPassed,
    );
    final accuracy = s.answersTotal == 0
        ? '—'
        : '${(100 * s.answersCorrect / s.answersTotal).round()}%';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(stats: s),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatsGrid(
                      tiles: [
                        (
                          Icons.local_fire_department_rounded,
                          '$streak',
                          'дней подряд',
                        ),
                        (
                          Icons.emoji_events_rounded,
                          '${s.bestStreak}',
                          'лучшая серия',
                        ),
                        (Icons.menu_book_rounded, '$learned', 'слов выучено'),
                        (
                          Icons.track_changes_rounded,
                          accuracy,
                          'правильных ответов',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ActivityCard(
                      days: activity,
                      dailyGoalXp: s.dailyGoalXp,
                      now: now,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      'Достижения',
                      trailing: '${unlocked.length} из ${achievements.length}',
                    ),
                    // Wrap, not a grid: rows take only the height they need.
                    LayoutBuilder(
                      builder: (context, box) {
                        final width = (box.maxWidth - 3 * 10) / 4;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 14,
                          children: [
                            for (final a in achievements)
                              SizedBox(
                                width: width,
                                child: _Badge(
                                  achievement: a,
                                  unlockedAt: unlocked[a.id],
                                  facts: facts,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Настройки'),
                    _Settings(stats: s),
                    const SizedBox(height: 24),
                    const _SectionTitle('Данные'),
                    const _DataCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.stats});

  final UserStat stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;
    final level = LevelProgress.fromXp(stats.xp);
    final rank = rankForLevel(level.level);
    final name = stats.userName;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: OrnamentBand(
              color: AppColors.gold.withValues(alpha: 0.3),
              height: 44,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 20, 20, 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name == null
                            ? 'Ә'
                            : name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.onGold,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            button: true,
                            label: name == null
                                ? 'Указать имя'
                                : 'Имя: $name. Изменить',
                            excludeSemantics: true,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _editName(context, ref, name),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      name ?? 'Как вас зовут?',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: name == null
                                            ? const Color(0xFFCDEFF6)
                                            : Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.edit_rounded,
                                    color: Color(0xFFCDEFF6),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${rank.kk} · ${rank.ru}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Уровень ${level.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${level.xpIntoLevel} / ${level.xpForLevel} XP',
                      style: const TextStyle(
                        color: Color(0xFFCDEFF6),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  value: level.fraction,
                  color: AppColors.gold,
                  trackColor: Colors.white.withValues(alpha: 0.2),
                  semanticsLabel: 'До уровня ${level.level + 1}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _TextDialog(
        title: 'Как вас зовут?',
        initial: current,
        hint: 'Имя',
        action: 'Сохранить',
        maxLength: 20,
      ),
    );
    if (result != null) {
      await ref.read(statsRepositoryProvider).setUserName(result);
    }
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.tiles});

  final List<(IconData, String, String)> tiles;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final colors = [
      (c.flame, c.goldSoft),
      (c.goldText, c.goldSoft),
      (c.accent, c.accentSoft),
      (c.okText, c.okSoft),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        for (final (i, (icon, value, label)) in tiles.indexed)
          Semantics(
            label: '$label: $value',
            excludeSemantics: true,
            child: SurfaceCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors[i].$2,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: colors[i].$1, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.days,
    required this.dailyGoalXp,
    required this.now,
  });

  final List<DailyActivityData> days;
  final int dailyGoalXp;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final monthAgo = dayOf(now).subtract(const Duration(days: 29));
    final activeDays = days
        .where((d) => d.sessions > 0 || d.xp > 0)
        .where((d) => !dayOf(d.day.toUtc()).isBefore(monthAgo))
        .length;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Активность',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '$activeDays ${plural(activeDays, 'день', 'дня', 'дней')} за 30 дней',
                style: TextStyle(
                  color: c.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ActivityCalendar(days: days, dailyGoalXp: dailyGoalXp, now: now),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: ActivityLegend(),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: context.colors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.achievement,
    required this.unlockedAt,
    required this.facts,
  });

  final Achievement achievement;
  final DateTime? unlockedAt;
  final AchievementFacts facts;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unlocked = unlockedAt != null;
    final goal = achievement.goal;
    final current = achievement.current?.call(facts);
    return Semantics(
      button: true,
      label:
          '${achievement.title}: ${unlocked ? 'получено' : 'ещё не получено'}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => _AchievementSheet(
            achievement: achievement,
            unlockedAt: unlockedAt,
            current: current,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: unlocked ? c.goldSoft : c.track,
                borderRadius: BorderRadius.circular(20),
                border: unlocked
                    ? Border.all(color: AppColors.gold, width: 2)
                    : null,
              ),
              child: Icon(
                unlocked ? achievement.icon : Icons.lock_rounded,
                color: unlocked ? c.goldText : c.lockIcon,
                size: unlocked ? 30 : 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: unlocked ? c.ink : c.muted,
              ),
            ),
            if (!unlocked && goal != null && current != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProgressBar(value: current / goal, height: 4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AchievementSheet extends StatelessWidget {
  const _AchievementSheet({
    required this.achievement,
    required this.unlockedAt,
    required this.current,
  });

  final Achievement achievement;
  final DateTime? unlockedAt;
  final int? current;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unlocked = unlockedAt != null;
    final goal = achievement.goal;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: unlocked ? c.goldSoft : c.track,
                borderRadius: BorderRadius.circular(30),
                border: unlocked
                    ? Border.all(color: AppColors.gold, width: 3)
                    : null,
              ),
              child: Icon(
                achievement.icon,
                color: unlocked ? c.goldText : c.lockIcon,
                size: 48,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              achievement.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 15),
            ),
            const SizedBox(height: 18),
            if (unlocked)
              Pill(
                icon: Icons.check_circle_rounded,
                text: 'Получено ${dateLong(unlockedAt!)}',
                background: c.okSoft,
                foreground: c.okText,
              )
            else if (goal != null && current != null) ...[
              ProgressBar(
                value: current! / goal,
                color: AppColors.gold,
                semanticsLabel: achievement.title,
              ),
              const SizedBox(height: 8),
              Text(
                '${current!.clamp(0, goal)} из $goal',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ] else
              Text(
                'Ещё не получено',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
              ),
          ],
        ),
      ),
    );
  }
}

class _Settings extends ConsumerWidget {
  const _Settings({required this.stats});

  final UserStat stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final repo = ref.read(statsRepositoryProvider);
    const label = TextStyle(fontSize: 15, fontWeight: FontWeight.w900);
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Цель дня', style: label),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 20, label: Text('20 XP')),
                    ButtonSegment(value: 50, label: Text('50 XP')),
                    ButtonSegment(value: 100, label: Text('100 XP')),
                  ],
                  selected: {stats.dailyGoalXp},
                  onSelectionChanged: (v) => repo.setDailyGoal(v.first),
                ),
                const SizedBox(height: 16),
                const Text('Цель недели', style: label),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 3, label: Text('3 дня')),
                    ButtonSegment(value: 5, label: Text('5 дней')),
                    ButtonSegment(value: 7, label: Text('7 дней')),
                  ],
                  selected: {stats.weeklyGoalDays},
                  onSelectionChanged: (v) => repo.setWeeklyGoal(v.first),
                ),
                const SizedBox(height: 16),
                const Text('Тема оформления', style: label),
                const SizedBox(height: 8),
                SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      label: Text('Авто'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text('Светлая'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      label: Text('Тёмная'),
                    ),
                  ],
                  // From the theme notifier, not the database: highlights at once.
                  selected: {ref.watch(themeModeProvider)},
                  onSelectionChanged: (v) =>
                      ref.read(themeModeProvider.notifier).set(v.first),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Divider(color: c.line, height: 16),
          ListTile(
            leading: Icon(Icons.abc_rounded, color: c.accent),
            title: const Text('Латиница', style: label),
            subtitle: Text(
              stats.showLatin
                  ? 'Показывается рядом с кириллицей'
                  : 'Новый алфавит и конвертер',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/latin'),
          ),
          SwitchListTile(
            secondary: Icon(Icons.vibration_rounded, color: c.accent),
            title: const Text('Вибрация', style: label),
            subtitle: const Text('При ответах в упражнениях'),
            value: stats.hapticsEnabled,
            onChanged: repo.setHaptics,
          ),
          if (Reminders.supported) ...[
            SwitchListTile(
              secondary: Icon(
                Icons.notifications_active_rounded,
                color: c.accent,
              ),
              title: const Text('Напоминание', style: label),
              subtitle: Text(
                stats.reminderEnabled
                    ? 'Каждый день в ${clock(stats.reminderMinutes)}'
                    : 'Раз в день, чтобы не терять серию',
              ),
              value: stats.reminderEnabled,
              onChanged: (on) => _toggleReminder(context, ref, on),
            ),
            if (stats.reminderEnabled)
              ListTile(
                leading: Icon(Icons.schedule_rounded, color: c.accent),
                title: const Text('Время напоминания', style: label),
                trailing: Text(
                  clock(stats.reminderMinutes),
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onTap: () => _pickTime(context, ref),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleReminder(
    BuildContext context,
    WidgetRef ref,
    bool on,
  ) async {
    final repo = ref.read(statsRepositoryProvider);
    if (!on) return repo.setReminder(enabled: false);
    final messenger = ScaffoldMessenger.of(context);
    final granted = await Reminders.requestPermission();
    if (!granted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Уведомления выключены. Разрешите их Qazaqsha в настройках телефона.',
          ),
        ),
      );
      return;
    }
    // The app listens to this setting and schedules the notification.
    await repo.setReminder(enabled: true);
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: stats.reminderMinutes ~/ 60,
        minute: stats.reminderMinutes % 60,
      ),
      helpText: 'Время напоминания',
    );
    if (picked == null) return;
    await ref
        .read(statsRepositoryProvider)
        .setReminder(enabled: true, minutes: picked.hour * 60 + picked.minute);
  }
}

class _DataCard extends ConsumerWidget {
  const _DataCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    const label = TextStyle(fontSize: 15, fontWeight: FontWeight.w900);
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.cloud_upload_rounded, color: c.accent),
            title: const Text('Сохранить прогресс', style: label),
            subtitle: const Text(
              'Скопировать код, чтобы перенести на другой телефон или в веб-версию',
            ),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.cloud_download_rounded, color: c.accent),
            title: const Text('Восстановить из кода', style: label),
            subtitle: const Text('Вставить сохранённый код'),
            onTap: () => _import(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.restart_alt_rounded, color: c.bad),
            title: Text(
              'Сбросить прогресс',
              style: label.copyWith(color: c.bad),
            ),
            subtitle: const Text('Начать курс заново. Свои слова останутся'),
            onTap: () => _reset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final code = await ref.read(backupRepositoryProvider).exportCode();
    await Clipboard.setData(ClipboardData(text: code));
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Код скопирован. Сохраните его, например, в «Избранном» Telegram.',
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _TextDialog(
        title: 'Восстановить прогресс',
        intro: 'Текущий прогресс заменится прогрессом из кода.',
        hint: 'QZB1-…',
        action: 'Восстановить',
        maxLines: 3,
        paste: true,
      ),
    );
    if (code == null || code.trim().isEmpty) return;
    try {
      await ref.read(backupRepositoryProvider).importCode(code);
      messenger.showSnackBar(
        const SnackBar(content: Text('Прогресс восстановлен')),
      );
    } on BadBackupCode {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Код не подошёл. Скопируйте его целиком.'),
        ),
      );
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text(
          'Опыт, серия, пройденные уроки, экзамены и достижения обнулятся. '
          'Это нельзя отменить. Свои слова и настройки останутся.\n\n'
          'Совет: сначала сохраните прогресс кодом.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.badButton),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await ref.read(backupRepositoryProvider).resetProgress();
    messenger.showSnackBar(
      const SnackBar(content: Text('Прогресс сброшен. Начнём сначала!')),
    );
  }
}

/// A dialog with one text field. Owns its controller, so the field stays
/// valid while the dialog animates out.
class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.hint,
    required this.action,
    this.initial,
    this.intro,
    this.maxLength,
    this.maxLines = 1,
    this.paste = false,
  });

  final String title;
  final String hint;
  final String action;
  final String? initial;
  final String? intro;
  final int? maxLength;
  final int maxLines;

  /// Show a "paste from clipboard" button.
  final bool paste;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text? when mounted) _controller.text = text;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.intro case final intro?) ...[
          Text(intro),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _controller,
          autofocus: true,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          textCapitalization: widget.paste
              ? TextCapitalization.none
              : TextCapitalization.words,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: widget.paste
                ? IconButton(
                    tooltip: 'Вставить',
                    icon: const Icon(Icons.content_paste_rounded),
                    onPressed: _paste,
                  )
                : null,
          ),
          onSubmitted: widget.maxLines == 1
              ? (v) => Navigator.pop(context, v)
              : null,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: Text(widget.action),
      ),
    ],
  );
}
