import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The daily "time to study" notification. Android only: the web version
/// can't wake up on its own.
abstract final class Reminders {
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static const _id = 1;
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void>? _init;

  static Future<void> _ensureInit() => _init ??= () async {
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(
          '@drawable/ic_launcher_monochrome',
        ),
      ),
    );
  }();

  /// Asks for the notification permission (Android 13+). True if granted.
  static Future<bool> requestPermission() async {
    await _ensureInit();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Every day at [minutes] after midnight, local time.
  static Future<void> scheduleDaily(int minutes) async {
    await _ensureInit();
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      title: 'Пора позаниматься казахским',
      body: 'Пять минут сегодня — и серия продолжается 🔥',
      scheduledDate: at,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Напоминание о занятиях',
          channelDescription: 'Раз в день, в выбранное время',
        ),
      ),
      // Inexact is fine for a reminder and needs no exact-alarm permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel() async {
    await _ensureInit();
    await _plugin.cancel(id: _id);
  }
}
