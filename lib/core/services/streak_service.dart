import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/journal_repository.dart';

/// Service for calculating and tracking user activity streaks
class StreakService {
  final MoodRepository _moodRepository;
  final JournalRepository _journalRepository;

  StreakService({
    required MoodRepository moodRepository,
    required JournalRepository journalRepository,
  })  : _moodRepository = moodRepository,
        _journalRepository = journalRepository;

  /// Calculate the current streak (consecutive days with activity)
  Future<StreakData> getStreakData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get all activity dates from mood entries and journal entries
    final activityDates = await _getAllActivityDates();

    if (activityDates.isEmpty) {
      return StreakData(
        currentStreak: 0,
        longestStreak: 0,
        totalActiveDays: 0,
        lastActiveDate: null,
        hasActivityToday: false,
      );
    }

    // Sort dates in descending order (most recent first)
    final sortedDates = activityDates.toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate current streak
    int currentStreak = 0;
    var checkDate = today;

    // If no activity today, start checking from yesterday
    final hasActivityToday = activityDates.contains(today);
    if (!hasActivityToday) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (activityDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? previousDate;

    for (final date in sortedDates.reversed) {
      if (previousDate == null) {
        tempStreak = 1;
      } else {
        final diff = date.difference(previousDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }
      previousDate = date;
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalActiveDays: activityDates.length,
      lastActiveDate: sortedDates.first,
      hasActivityToday: hasActivityToday,
    );
  }

  /// Get all unique dates with activity (mood check-ins or journal entries)
  Future<Set<DateTime>> _getAllActivityDates() async {
    final dates = <DateTime>{};

    // Get mood entries from the last 365 days
    final moodEntries = await _moodRepository.getMoodEntries(
      startDate: DateTime.now().subtract(const Duration(days: 365)),
    );

    for (final entry in moodEntries) {
      dates.add(DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      ));
    }

    // Get journal entries from the last 365 days
    final journalEntries = await _journalRepository.getJournalEntries(
      startDate: DateTime.now().subtract(const Duration(days: 365)),
    );

    for (final entry in journalEntries) {
      dates.add(DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      ));
    }

    return dates;
  }

  /// Get weekly activity summary
  Future<WeeklyActivitySummary> getWeeklyActivity() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final moodEntries = await _moodRepository.getMoodEntries(startDate: startDate);
    final journalEntries = await _journalRepository.getJournalEntries(startDate: startDate);

    // Create daily activity map
    final dailyActivity = <int, DailyActivity>{};
    for (int i = 0; i < 7; i++) {
      dailyActivity[i] = DailyActivity(
        dayOfWeek: i + 1,
        moodCheckIns: 0,
        journalEntries: 0,
      );
    }

    for (final entry in moodEntries) {
      final dayIndex = entry.timestamp.weekday - 1;
      if (dailyActivity.containsKey(dayIndex)) {
        dailyActivity[dayIndex] = dailyActivity[dayIndex]!.copyWith(
          moodCheckIns: dailyActivity[dayIndex]!.moodCheckIns + 1,
        );
      }
    }

    for (final entry in journalEntries) {
      final dayIndex = entry.createdAt.weekday - 1;
      if (dailyActivity.containsKey(dayIndex)) {
        dailyActivity[dayIndex] = dailyActivity[dayIndex]!.copyWith(
          journalEntries: dailyActivity[dayIndex]!.journalEntries + 1,
        );
      }
    }

    return WeeklyActivitySummary(
      dailyActivity: dailyActivity.values.toList(),
      totalMoodCheckIns: moodEntries.length,
      totalJournalEntries: journalEntries.length,
    );
  }
}

/// Data class for streak information
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final DateTime? lastActiveDate;
  final bool hasActivityToday;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActiveDays,
    required this.lastActiveDate,
    required this.hasActivityToday,
  });

  /// Get encouraging message based on streak
  String get encouragementMessage {
    if (currentStreak == 0) {
      return 'Start your streak today! 🌟';
    } else if (currentStreak < 3) {
      return 'Great start! Keep going! 💪';
    } else if (currentStreak < 7) {
      return 'You\'re on fire! 🔥';
    } else if (currentStreak < 14) {
      return 'One week strong! Amazing! 🎉';
    } else if (currentStreak < 30) {
      return 'Incredible dedication! 🏆';
    } else {
      return 'You\'re unstoppable! 👑';
    }
  }
}

/// Daily activity data
class DailyActivity {
  final int dayOfWeek;
  final int moodCheckIns;
  final int journalEntries;

  const DailyActivity({
    required this.dayOfWeek,
    required this.moodCheckIns,
    required this.journalEntries,
  });

  bool get hasActivity => moodCheckIns > 0 || journalEntries > 0;

  DailyActivity copyWith({
    int? dayOfWeek,
    int? moodCheckIns,
    int? journalEntries,
  }) {
    return DailyActivity(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      moodCheckIns: moodCheckIns ?? this.moodCheckIns,
      journalEntries: journalEntries ?? this.journalEntries,
    );
  }
}

/// Weekly activity summary
class WeeklyActivitySummary {
  final List<DailyActivity> dailyActivity;
  final int totalMoodCheckIns;
  final int totalJournalEntries;

  const WeeklyActivitySummary({
    required this.dailyActivity,
    required this.totalMoodCheckIns,
    required this.totalJournalEntries,
  });

  int get activeDaysThisWeek =>
      dailyActivity.where((d) => d.hasActivity).length;
}
