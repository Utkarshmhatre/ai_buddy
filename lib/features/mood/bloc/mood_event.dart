import '../../../data/models/mood_entry.dart';

/// Events for MoodBloc
abstract class MoodEvent {
  const MoodEvent();
}

/// Log a new mood entry
class LogMood extends MoodEvent {
  final MoodCategory category;
  final MoodIntensity intensity;
  final String? notes;
  final List<String>? triggers;
  final List<String>? activities;

  const LogMood({
    required this.category,
    required this.intensity,
    this.notes,
    this.triggers,
    this.activities,
  });
}

/// Load mood history
class LoadMoodHistory extends MoodEvent {
  final int? daysBack;
  final int? limit;

  const LoadMoodHistory({this.daysBack, this.limit});
}

/// Load today's mood summary
class LoadTodaysSummary extends MoodEvent {
  const LoadTodaysSummary();
}

/// Load weekly mood summary with trend
class LoadWeeklySummary extends MoodEvent {
  const LoadWeeklySummary();
}

/// Generate AI insight for a specific mood entry
class GenerateMoodInsight extends MoodEvent {
  final String entryId;

  const GenerateMoodInsight({required this.entryId});
}

/// Generate AI insight for recent mood patterns
class GeneratePatternInsight extends MoodEvent {
  const GeneratePatternInsight();
}

/// Clear any error state
class ClearMoodError extends MoodEvent {
  const ClearMoodError();
}
