import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../data/models/mood_entry.dart';

/// Smart notification service with AI-optimized timing
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification channel IDs
  static const String _moodCheckInChannel = 'mood_check_in';
  static const String _exerciseReminderChannel = 'exercise_reminder';
  static const String _journalPromptChannel = 'journal_prompt';
  static const String _streakProtectionChannel = 'streak_protection';
  static const String _insightChannel = 'daily_insight';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _moodCheckInChannel,
          'Mood Check-ins',
          description: 'Reminders to check in with your mood',
          importance: Importance.defaultImportance,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _exerciseReminderChannel,
          'Exercise Reminders',
          description: 'Reminders for wellness exercises',
          importance: Importance.defaultImportance,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _journalPromptChannel,
          'Journal Prompts',
          description: 'Daily journaling prompts',
          importance: Importance.low,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _streakProtectionChannel,
          'Streak Protection',
          description: 'Reminders to maintain your streak',
          importance: Importance.high,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _insightChannel,
          'Daily Insights',
          description: 'AI-generated daily insights',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('NotificationService: Tapped notification with payload: $payload');
      // Handle navigation based on payload
      // This would typically use a navigation service or event bus
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // ==================== Smart Notification Scheduling ====================

  /// Schedule mood check-in at optimal time based on user patterns
  Future<void> scheduleMoodCheckIn({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    final messages = [
      "How are you feeling right now? 💙",
      "Ready for a quick mood check-in?",
      "Taking a moment to check in with yourself is powerful. 🌟",
      "Your feelings matter. How's your day going?",
      "Just checking in. How are you? 💚",
    ];

    final message = customMessage ?? (messages..shuffle()).first;

    await _scheduleDaily(
      id: 1,
      channelId: _moodCheckInChannel,
      title: 'Mood Check-In',
      body: message,
      hour: hour,
      minute: minute,
      payload: jsonEncode({'action': 'mood_check_in'}),
    );
  }

  /// Schedule exercise reminder with context-aware messaging
  Future<void> scheduleExerciseReminder({
    required int hour,
    required int minute,
    String? exerciseType,
    MoodCategory? recentMood,
  }) async {
    String message;
    
    if (recentMood != null) {
      switch (recentMood) {
        case MoodCategory.anxious:
          message = "A quick breathing exercise might help ease your mind. 🌬️";
          break;
        case MoodCategory.stressed:
          message = "Time for some grounding? It only takes a few minutes. 🌿";
          break;
        case MoodCategory.sad:
          message = "A gentle moment of self-care might feel good right now. 💙";
          break;
        default:
          message = "Ready for a quick wellness moment? 🌟";
      }
    } else {
      message = "A few minutes of mindfulness can make a big difference. ✨";
    }

    await _scheduleDaily(
      id: 2,
      channelId: _exerciseReminderChannel,
      title: 'Wellness Moment',
      body: message,
      hour: hour,
      minute: minute,
      payload: jsonEncode({
        'action': 'exercise',
        'type': exerciseType ?? 'breathing',
      }),
    );
  }

  /// Schedule journal prompt with AI-generated content
  Future<void> scheduleJournalPrompt({
    required int hour,
    required int minute,
    String? prompt,
  }) async {
    final defaultPrompts = [
      "What's on your mind today?",
      "What are you grateful for right now?",
      "How did you grow today, even in a small way?",
      "What's one kind thing you did for yourself?",
      "What would make tomorrow a good day?",
    ];

    final message = prompt ?? (defaultPrompts..shuffle()).first;

    await _scheduleDaily(
      id: 3,
      channelId: _journalPromptChannel,
      title: 'Journal Time 📝',
      body: message,
      hour: hour,
      minute: minute,
      payload: jsonEncode({'action': 'journal'}),
    );
  }

  /// Schedule streak protection reminder
  Future<void> scheduleStreakProtection({
    required int currentStreak,
    required DateTime lastCheckIn,
  }) async {
    // Only schedule if user has an active streak
    if (currentStreak < 2) return;

    // Calculate when to remind (before streak breaks)
    final now = DateTime.now();
    final daysSinceCheckIn = now.difference(lastCheckIn).inHours;

    // If it's been more than 20 hours, send urgent reminder
    if (daysSinceCheckIn >= 20 && daysSinceCheckIn < 24) {
      await _showImmediateNotification(
        id: 100,
        channelId: _streakProtectionChannel,
        title: '🔥 Protect Your $currentStreak-Day Streak!',
        body: "You're so close to losing your streak. A quick check-in takes just seconds!",
        payload: jsonEncode({'action': 'mood_check_in', 'urgent': true}),
      );
    }
  }

  /// Send daily insight notification
  Future<void> sendDailyInsight({
    required String insight,
    int hour = 9,
    int minute = 0,
  }) async {
    await _scheduleDaily(
      id: 4,
      channelId: _insightChannel,
      title: '✨ Your Daily Insight',
      body: insight,
      hour: hour,
      minute: minute,
      payload: jsonEncode({'action': 'insights'}),
    );
  }

  /// Send follow-up notification after conversation
  Future<void> sendFollowUp({
    required String message,
    Duration delay = const Duration(hours: 2),
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _notifications.zonedSchedule(
      50 + DateTime.now().millisecondsSinceEpoch % 50,
      'Checking In 💙',
      message,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _moodCheckInChannel,
          'Mood Check-ins',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'action': 'follow_up'}),
    );
  }

  // ==================== Helper Methods ====================

  Future<void> _scheduleDaily({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').toUpperCase(),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    debugPrint('NotificationService: Scheduled notification for ${scheduledDate.hour}:${scheduledDate.minute}');
  }

  Future<void> _showImmediateNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').toUpperCase(),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('NotificationService: All notifications cancelled');
  }

  /// Cancel specific notification by ID
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // ==================== User Preferences ====================

  /// Save notification preferences
  Future<void> savePreferences(NotificationPreferences prefs) async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString('notification_prefs', jsonEncode(prefs.toJson()));
  }

  /// Load notification preferences
  Future<NotificationPreferences> loadPreferences() async {
    final storage = await SharedPreferences.getInstance();
    final json = storage.getString('notification_prefs');
    
    if (json != null) {
      return NotificationPreferences.fromJson(jsonDecode(json));
    }
    
    return NotificationPreferences.defaults();
  }

  /// Apply notification preferences
  Future<void> applyPreferences(NotificationPreferences prefs) async {
    // Cancel all existing scheduled notifications
    await cancelAll();

    if (!prefs.enabled) return;

    if (prefs.moodCheckInEnabled) {
      await scheduleMoodCheckIn(
        hour: prefs.moodCheckInHour,
        minute: prefs.moodCheckInMinute,
      );
    }

    if (prefs.exerciseReminderEnabled) {
      await scheduleExerciseReminder(
        hour: prefs.exerciseReminderHour,
        minute: prefs.exerciseReminderMinute,
      );
    }

    if (prefs.journalPromptEnabled) {
      await scheduleJournalPrompt(
        hour: prefs.journalPromptHour,
        minute: prefs.journalPromptMinute,
      );
    }

    await savePreferences(prefs);
    debugPrint('NotificationService: Applied preferences');
  }
}

/// User notification preferences
class NotificationPreferences {
  final bool enabled;
  final bool moodCheckInEnabled;
  final int moodCheckInHour;
  final int moodCheckInMinute;
  final bool exerciseReminderEnabled;
  final int exerciseReminderHour;
  final int exerciseReminderMinute;
  final bool journalPromptEnabled;
  final int journalPromptHour;
  final int journalPromptMinute;
  final bool streakProtectionEnabled;
  final bool dailyInsightEnabled;

  const NotificationPreferences({
    this.enabled = true,
    this.moodCheckInEnabled = true,
    this.moodCheckInHour = 10,
    this.moodCheckInMinute = 0,
    this.exerciseReminderEnabled = true,
    this.exerciseReminderHour = 15,
    this.exerciseReminderMinute = 0,
    this.journalPromptEnabled = true,
    this.journalPromptHour = 20,
    this.journalPromptMinute = 0,
    this.streakProtectionEnabled = true,
    this.dailyInsightEnabled = true,
  });

  factory NotificationPreferences.defaults() => const NotificationPreferences();

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] ?? true,
      moodCheckInEnabled: json['moodCheckInEnabled'] ?? true,
      moodCheckInHour: json['moodCheckInHour'] ?? 10,
      moodCheckInMinute: json['moodCheckInMinute'] ?? 0,
      exerciseReminderEnabled: json['exerciseReminderEnabled'] ?? true,
      exerciseReminderHour: json['exerciseReminderHour'] ?? 15,
      exerciseReminderMinute: json['exerciseReminderMinute'] ?? 0,
      journalPromptEnabled: json['journalPromptEnabled'] ?? true,
      journalPromptHour: json['journalPromptHour'] ?? 20,
      journalPromptMinute: json['journalPromptMinute'] ?? 0,
      streakProtectionEnabled: json['streakProtectionEnabled'] ?? true,
      dailyInsightEnabled: json['dailyInsightEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'moodCheckInEnabled': moodCheckInEnabled,
    'moodCheckInHour': moodCheckInHour,
    'moodCheckInMinute': moodCheckInMinute,
    'exerciseReminderEnabled': exerciseReminderEnabled,
    'exerciseReminderHour': exerciseReminderHour,
    'exerciseReminderMinute': exerciseReminderMinute,
    'journalPromptEnabled': journalPromptEnabled,
    'journalPromptHour': journalPromptHour,
    'journalPromptMinute': journalPromptMinute,
    'streakProtectionEnabled': streakProtectionEnabled,
    'dailyInsightEnabled': dailyInsightEnabled,
  };

  NotificationPreferences copyWith({
    bool? enabled,
    bool? moodCheckInEnabled,
    int? moodCheckInHour,
    int? moodCheckInMinute,
    bool? exerciseReminderEnabled,
    int? exerciseReminderHour,
    int? exerciseReminderMinute,
    bool? journalPromptEnabled,
    int? journalPromptHour,
    int? journalPromptMinute,
    bool? streakProtectionEnabled,
    bool? dailyInsightEnabled,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      moodCheckInEnabled: moodCheckInEnabled ?? this.moodCheckInEnabled,
      moodCheckInHour: moodCheckInHour ?? this.moodCheckInHour,
      moodCheckInMinute: moodCheckInMinute ?? this.moodCheckInMinute,
      exerciseReminderEnabled: exerciseReminderEnabled ?? this.exerciseReminderEnabled,
      exerciseReminderHour: exerciseReminderHour ?? this.exerciseReminderHour,
      exerciseReminderMinute: exerciseReminderMinute ?? this.exerciseReminderMinute,
      journalPromptEnabled: journalPromptEnabled ?? this.journalPromptEnabled,
      journalPromptHour: journalPromptHour ?? this.journalPromptHour,
      journalPromptMinute: journalPromptMinute ?? this.journalPromptMinute,
      streakProtectionEnabled: streakProtectionEnabled ?? this.streakProtectionEnabled,
      dailyInsightEnabled: dailyInsightEnabled ?? this.dailyInsightEnabled,
    );
  }
}
