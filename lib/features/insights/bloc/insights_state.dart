import 'package:equatable/equatable.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../data/models/mood_entry.dart';

/// States for InsightsBloc
abstract class InsightsState extends Equatable {
  const InsightsState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

/// Loading state
class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

/// Insights loaded successfully
class InsightsLoaded extends InsightsState {
  final PatternAnalysis? patternAnalysis;
  final WeeklySummary? weeklySummary;
  final List<MoodEntry> recentMoods;
  final int checkInStreak;
  final int totalCheckIns;
  final double? averageMood;
  final List<String> topTriggers;
  final List<String> helpfulActivities;
  
  const InsightsLoaded({
    this.patternAnalysis,
    this.weeklySummary,
    this.recentMoods = const [],
    this.checkInStreak = 0,
    this.totalCheckIns = 0,
    this.averageMood,
    this.topTriggers = const [],
    this.helpfulActivities = const [],
  });
  
  InsightsLoaded copyWith({
    PatternAnalysis? patternAnalysis,
    WeeklySummary? weeklySummary,
    List<MoodEntry>? recentMoods,
    int? checkInStreak,
    int? totalCheckIns,
    double? averageMood,
    List<String>? topTriggers,
    List<String>? helpfulActivities,
  }) {
    return InsightsLoaded(
      patternAnalysis: patternAnalysis ?? this.patternAnalysis,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      recentMoods: recentMoods ?? this.recentMoods,
      checkInStreak: checkInStreak ?? this.checkInStreak,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      averageMood: averageMood ?? this.averageMood,
      topTriggers: topTriggers ?? this.topTriggers,
      helpfulActivities: helpfulActivities ?? this.helpfulActivities,
    );
  }
  
  @override
  List<Object?> get props => [
    patternAnalysis,
    weeklySummary,
    recentMoods,
    checkInStreak,
    totalCheckIns,
    averageMood,
    topTriggers,
    helpfulActivities,
  ];
}

/// Error state
class InsightsError extends InsightsState {
  final String message;
  
  const InsightsError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Weekly summary model
class WeeklySummary {
  final String summaryText;
  final int moodChangePercent;
  final int totalCheckIns;
  final int exercisesCompleted;
  final String recommendation;
  
  WeeklySummary({
    required this.summaryText,
    required this.moodChangePercent,
    required this.totalCheckIns,
    required this.exercisesCompleted,
    required this.recommendation,
  });
}
