import '../../../data/models/mood_entry.dart';

/// States for MoodBloc
abstract class MoodState {
  const MoodState();
}

/// Initial state
class MoodInitial extends MoodState {
  const MoodInitial();
}

/// Loading state
class MoodLoading extends MoodState {
  final String? message;

  const MoodLoading({this.message});
}

/// Mood entry saved successfully
class MoodSaved extends MoodState {
  final MoodEntry entry;
  final String? aiInsight;

  const MoodSaved({required this.entry, this.aiInsight});
}

/// Mood history loaded
class MoodHistoryLoaded extends MoodState {
  final List<MoodEntry> entries;
  final MoodTrend? trend;
  final double? averageIntensity;

  const MoodHistoryLoaded({
    required this.entries,
    this.trend,
    this.averageIntensity,
  });
}

/// Today's summary loaded
class TodaysSummaryLoaded extends MoodState {
  final List<MoodEntry> todaysEntries;
  final MoodCategory? dominantMood;
  final double? averageIntensity;

  const TodaysSummaryLoaded({
    required this.todaysEntries,
    this.dominantMood,
    this.averageIntensity,
  });
}

/// Weekly summary loaded
class WeeklySummaryLoaded extends MoodState {
  final List<MoodEntry> weekEntries;
  final MoodTrend trend;
  final double? averageIntensity;
  final Map<MoodCategory, int> moodDistribution;
  final String? patternInsight;

  const WeeklySummaryLoaded({
    required this.weekEntries,
    required this.trend,
    this.averageIntensity,
    required this.moodDistribution,
    this.patternInsight,
  });
}

/// AI insight generated
class MoodInsightGenerated extends MoodState {
  final String entryId;
  final String insight;

  const MoodInsightGenerated({required this.entryId, required this.insight});
}

/// Error state
class MoodError extends MoodState {
  final String message;

  const MoodError({required this.message});
}

/// Mood trend direction
enum MoodTrend {
  improving('📈', 'Improving'),
  stable('➡️', 'Stable'),
  declining('📉', 'Needs Attention');

  final String emoji;
  final String label;
  const MoodTrend(this.emoji, this.label);
}
