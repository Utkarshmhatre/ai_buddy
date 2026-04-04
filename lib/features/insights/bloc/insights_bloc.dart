import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/repositories/mood_repository.dart';
import 'insights_event.dart';
import 'insights_state.dart';

/// BLoC for managing insights and pattern recognition
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final MoodRepository _moodRepository;
  final EnhancedGeminiService _aiService;
  
  InsightsBloc({
    required MoodRepository moodRepository,
    required EnhancedGeminiService aiService,
  })  : _moodRepository = moodRepository,
        _aiService = aiService,
        super(const InsightsInitial()) {
    on<LoadInsights>(_onLoadInsights);
    on<RefreshPatternAnalysis>(_onRefreshPatternAnalysis);
    on<GenerateWeeklySummary>(_onGenerateWeeklySummary);
  }
  
  Future<void> _onLoadInsights(
    LoadInsights event,
    Emitter<InsightsState> emit,
  ) async {
    emit(const InsightsLoading());
    
    try {
      // Get recent mood entries
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final recentMoods = await _moodRepository.getMoodEntries(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      
      // Calculate basic statistics
      final checkInStreak = _calculateStreak(recentMoods);
      final totalCheckIns = recentMoods.length;
      final averageMood = await _moodRepository.getAverageMood(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      
      // Get top triggers and helpful activities
      final topTriggers = _extractTopItems(
        recentMoods.expand((m) => m.triggers ?? []).cast<String>().toList(),
      );
      final helpfulActivities = _extractTopItems(
        recentMoods.expand((m) => m.activities ?? []).cast<String>().toList(),
      );
      
      emit(InsightsLoaded(
        recentMoods: recentMoods,
        checkInStreak: checkInStreak,
        totalCheckIns: totalCheckIns,
        averageMood: averageMood,
        topTriggers: topTriggers,
        helpfulActivities: helpfulActivities,
      ));
      
      // Trigger AI pattern analysis in background
      add(const RefreshPatternAnalysis());
      
    } catch (e) {
      emit(InsightsError(message: 'Failed to load insights: $e'));
    }
  }
  
  Future<void> _onRefreshPatternAnalysis(
    RefreshPatternAnalysis event,
    Emitter<InsightsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InsightsLoaded) return;
    
    try {
      // Get AI pattern analysis
      final patternAnalysis = await _aiService.analyzePatterns(
        moodEntries: currentState.recentMoods,
      );
      
      emit(currentState.copyWith(patternAnalysis: patternAnalysis));
      
    } catch (e) {
      // Pattern analysis failed, but we still have basic insights
      // Don't emit error, just log it
      print('Pattern analysis failed: $e');
    }
  }
  
  Future<void> _onGenerateWeeklySummary(
    GenerateWeeklySummary event,
    Emitter<InsightsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InsightsLoaded) return;
    
    try {
      // Get this week's data
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));
      
      final thisWeekMoods = await _moodRepository.getMoodEntries(
        startDate: weekAgo,
        endDate: now,
      );
      
      final lastWeekMoods = await _moodRepository.getMoodEntries(
        startDate: twoWeeksAgo,
        endDate: weekAgo,
      );
      
      // Calculate mood change
      final thisWeekAvg = _calculateAverageMood(thisWeekMoods);
      final lastWeekAvg = _calculateAverageMood(lastWeekMoods);
      
      int moodChangePercent = 0;
      if (lastWeekAvg != null && lastWeekAvg > 0) {
        moodChangePercent = (((thisWeekAvg ?? 0) - lastWeekAvg) / lastWeekAvg * 100).round();
      }
      
      // Generate summary text
      final summaryText = _generateSummaryText(
        thisWeekMoods,
        moodChangePercent,
        currentState.patternAnalysis,
      );
      
      final summary = WeeklySummary(
        summaryText: summaryText,
        moodChangePercent: moodChangePercent,
        totalCheckIns: thisWeekMoods.length,
        exercisesCompleted: 0, // TODO: Track exercises
        recommendation: _generateRecommendation(currentState.patternAnalysis),
      );
      
      emit(currentState.copyWith(weeklySummary: summary));
      
    } catch (e) {
      print('Failed to generate weekly summary: $e');
    }
  }
  
  int _calculateStreak(List<MoodEntry> moods) {
    if (moods.isEmpty) return 0;
    
    // Sort by date descending
    final sorted = moods.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final mood in sorted) {
      final moodDate = DateTime(
        mood.timestamp.year,
        mood.timestamp.month,
        mood.timestamp.day,
      );
      
      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        if (moodDate == todayDate || 
            moodDate == todayDate.subtract(const Duration(days: 1))) {
          streak = 1;
          lastDate = moodDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (moodDate == expectedDate) {
          streak++;
          lastDate = moodDate;
        } else if (moodDate == lastDate) {
          // Same day, continue
          continue;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }
  
  List<String> _extractTopItems(List<String> items, {int limit = 5}) {
    final counts = <String, int>{};
    for (final item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).map((e) => e.key).toList();
  }
  
  double? _calculateAverageMood(List<MoodEntry> moods) {
    if (moods.isEmpty) return null;
    
    final sum = moods.fold<double>(
      0,
      (sum, mood) => sum + mood.intensity.value,
    );
    
    return sum / moods.length;
  }
  
  String _generateSummaryText(
    List<MoodEntry> moods,
    int moodChangePercent,
    PatternAnalysis? patterns,
  ) {
    if (moods.isEmpty) {
      return "You haven't logged any moods this week. Regular check-ins help you understand your emotional patterns better.";
    }
    
    final buffer = StringBuffer();
    
    // Opening based on mood change
    if (moodChangePercent > 10) {
      buffer.write("Great progress this week! Your mood has improved by $moodChangePercent%. ");
    } else if (moodChangePercent < -10) {
      buffer.write("This week has been challenging. Your mood was lower than last week. ");
    } else {
      buffer.write("You've maintained steady emotional balance this week. ");
    }
    
    // Add check-in info
    buffer.write("You completed ${moods.length} mood check-ins. ");
    
    // Add pattern insight if available
    if (patterns != null && patterns.trendDescription.isNotEmpty) {
      buffer.write(patterns.trendDescription);
    }
    
    return buffer.toString();
  }
  
  String _generateRecommendation(PatternAnalysis? patterns) {
    if (patterns != null && patterns.growthOpportunities.isNotEmpty) {
      return patterns.growthOpportunities.first;
    }
    return "Try to maintain consistency with your mood check-ins for better insights.";
  }
}
