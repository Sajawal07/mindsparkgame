import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'storage_service.dart';
import '../models/daily_session_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _dailyChannelId = 'daily_reminders_channel';
  static const String _dailyChannelName = 'Daily Reminders';

  static const int _dailyReminderId = 9001;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    // Timezone setup is required for accurate "7:00 PM local" scheduling.
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // Fall back to UTC/whatever tz package default is; still allows scheduling.
    }

    // Create/ensure Android channel.
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _dailyChannelId,
        _dailyChannelName,
        description: 'Reminders for your daily brain challenge',
        importance: Importance.high,
      ),
    );

    // Request runtime permission on Android 13+.
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> setEnabled(bool enabled) async {
    if (!enabled || !StorageService.instance.getNotificationsEnabled()) {
      await _cancelDailyReminder();
      return;
    }

    final isTodayComplete = await _isTodayCompleteFromStorage();
    await syncDailyReminder(isTodayComplete: isTodayComplete);
  }

  Future<bool> _isTodayCompleteFromStorage() async {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final json = StorageService.instance.getDailySession(todayKey);
    if (json == null) return false;

    return DailySessionModel.fromJson(json).isComplete;
  }

  Future<void> syncDailyReminder({required bool isTodayComplete}) async {
    if (!StorageService.instance.getNotificationsEnabled()) {
      await _cancelDailyReminder();
      return;
    }

    await _cancelDailyReminder();

    final now = tz.TZDateTime.now(tz.local);
    final todaySeven = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 0);
    final nextReminder = isTodayComplete || now.isAfter(todaySeven)
        ? todaySeven.add(const Duration(days: 1))
        : todaySeven;

    if (nextReminder.isBefore(now)) return;

    const androidDetails = AndroidNotificationDetails(
      _dailyChannelId,
      _dailyChannelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Daily Challenge is waiting',
      'Your brain challenge is ready. Come back at 7:00 PM!',
      nextReminder,
      const NotificationDetails(android: androidDetails),
      payload: 'daily_reminder',
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> showDailyCompleted({
    required int brainScore,
    required int coinsEarned,
    required int xpEarned,
    required int streak,
  }) async {
    if (!StorageService.instance.getNotificationsEnabled()) return;

    final id = _uniqueNotificationId();
    const androidDetails = AndroidNotificationDetails(
      _dailyChannelId,
      _dailyChannelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id,
      'Daily Challenge completed!',
      'Brain Score: $brainScore • Coins: $coinsEarned • XP: $xpEarned • Streak: $streak days',
      const NotificationDetails(android: androidDetails),
      payload: 'daily_completed',
    );
  }

  Future<void> showStreakMilestone({
    required int milestoneDays,
    required String rewardText,
  }) async {
    if (!StorageService.instance.getNotificationsEnabled()) return;

    final id = _uniqueNotificationId();
    const androidDetails = AndroidNotificationDetails(
      _dailyChannelId,
      _dailyChannelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id,
      'Streak milestone: $milestoneDays days',
      rewardText,
      const NotificationDetails(android: androidDetails),
      payload: 'streak_milestone_$milestoneDays',
    );
  }

  int _uniqueNotificationId() {
    // Keep within 32-bit signed integer range.
    return DateTime.now().millisecondsSinceEpoch % 0x7fffffff;
  }

  Future<void> _cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }
}

