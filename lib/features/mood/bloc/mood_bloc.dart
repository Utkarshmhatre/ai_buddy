import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/gemini_service.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/repositories/mood_repository.dart';
import 'mood_event.dart';
import 'mood_state.dart';

/// BLoC for mood tracking functionality
class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository _moodRepository;
  final GeminiService _geminiService;

  MoodBloc({
    required MoodRepository moodRepository,
    required GeminiService geminiService,
  })  : _moodRepository = moodRepository,
        _geminiService = geminiService,
        super(const MoodInitial()) {
    on<LogMood>(_onLogMood);
    on<LoadMoodHistory>(_onLoadMoodHistory);
    on<LoadTodaysSummary>(_onLoadTodaysSummary);
    on<LoadWeeklySummary>(_onLoadWeeklySummary);
    on<GenerateMoodInsight>(_onGenerateMoodInsight);
    on<GeneratePatternInsight>(_onGeneratePatternInsight);
    on<ClearMoodError>(_onClearMoodError);
  }

  Future<void> _onLogMood(LogMood event, Emitter<MoodState> emit) async {
    emit(const MoodLoading(message: 'Saving your mood...'));

    try {
      // Save mood entry
      final entry = await _moodRepository.saveMoodEntry(
        category: event.category,
        intensity: event.intensity,
        notes: event.notes,
        triggers: event.triggers,
        activities: event.activities,
      );

      // Generate AI insight asynchronously
      String? aiInsight;
      try {
        aiInsight = await _geminiService.generateMoodInsightFromParams(
          category: event.category.label,
          intensity: event.intensity.label,
          notes: event.notes,
          triggers: event.triggers,
        );

        // Update entry with AI insight
        if (aiInsight != null) {
          await _moodRepository.updateMoodInsight(entry.id, aiInsight);
        }
      } catch (e) {
        // AI insight is optional, don't fail the save
        print('MoodBloc: AI insight generation failed: $e');
      }

      emit(MoodSaved(
        entry: entry.copyWith(aiInsight: aiInsight),
        aiInsight: aiInsight,
      ));
    } catch (e) {
      emit(MoodError(message: 'Failed to save mood: $e'));
    }
  }

  Future<void> _onLoadMoodHistory(
    LoadMoodHistory event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading(message: 'Loading mood history...'));

    try {
      final startDate = event.daysBack != null
          ? DateTime.now().subtract(Duration(days: event.daysBack!))
          : null;

      final entries = await _moodRepository.getMoodEntries(
        startDate: startDate,
        limit: event.limit,
      );

      // Calculate trend and average
      final trend = await _moodRepository.getMoodTrend();
      final average = _calculateAverageIntensity(entries);

      emit(MoodHistoryLoaded(
        entries: entries,
        trend: _convertTrend(trend),
        averageIntensity: average,
      ));
    } catch (e) {
      emit(MoodError(message: 'Failed to load mood history: $e'));
    }
  }

  Future<void> _onLoadTodaysSummary(
    LoadTodaysSummary event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());

    try {
      final entries = await _moodRepository.getTodaysMoodEntries();

      // Find dominant mood
      final moodCounts = <MoodCategory, int>{};
      for (final entry in entries) {
        moodCounts[entry.category] = (moodCounts[entry.category] ?? 0) + 1;
      }

      MoodCategory? dominantMood;
      if (moodCounts.isNotEmpty) {
        dominantMood = moodCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      emit(TodaysSummaryLoaded(
        todaysEntries: entries,
        dominantMood: dominantMood,
        averageIntensity: _calculateAverageIntensity(entries),
      ));
    } catch (e) {
      emit(MoodError(message: 'Failed to load today\'s summary: $e'));
    }
  }

  Future<void> _onLoadWeeklySummary(
    LoadWeeklySummary event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());

    try {
      final entries = await _moodRepository.getThisWeeksMoodEntries();
      final trend = await _moodRepository.getMoodTrend();

      // Calculate mood distribution
      final distribution = <MoodCategory, int>{};
      for (final entry in entries) {
        distribution[entry.category] = (distribution[entry.category] ?? 0) + 1;
      }

      emit(WeeklySummaryLoaded(
        weekEntries: entries,
        trend: _convertTrend(trend),
        averageIntensity: _calculateAverageIntensity(entries),
        moodDistribution: distribution,
      ));
    } catch (e) {
      emit(MoodError(message: 'Failed to load weekly summary: $e'));
    }
  }

  Future<void> _onGenerateMoodInsight(
    GenerateMoodInsight event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading(message: 'Generating insight...'));

    try {
      final entry = await _moodRepository.getMoodEntryById(event.entryId);
      if (entry == null) {
        emit(const MoodError(message: 'Mood entry not found'));
        return;
      }

      final insight = await _geminiService.generateMoodInsightFromParams(
        category: entry.category.label,
        intensity: entry.intensity.label,
        notes: entry.notes,
        triggers: entry.triggers,
      );

      if (insight != null) {
        await _moodRepository.updateMoodInsight(event.entryId, insight);
        emit(MoodInsightGenerated(entryId: event.entryId, insight: insight));
      } else {
        emit(const MoodError(message: 'Could not generate insight'));
      }
    } catch (e) {
      emit(MoodError(message: 'Failed to generate insight: $e'));
    }
  }

  Future<void> _onGeneratePatternInsight(
    GeneratePatternInsight event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading(message: 'Analyzing patterns...'));

    try {
      final entries = await _moodRepository.getThisWeeksMoodEntries();
      if (entries.isEmpty) {
        emit(const MoodError(message: 'Not enough data for pattern analysis'));
        return;
      }

      // Build summary for AI
      final moodSummary = entries.map((e) => 
        '${e.category.label} (${e.intensity.label}) on ${e.timestamp.day}/${e.timestamp.month}'
      ).join(', ');

      final insight = await _geminiService.generatePatternInsight(moodSummary);

      if (insight != null) {
        final trend = await _moodRepository.getMoodTrend();
        final distribution = <MoodCategory, int>{};
        for (final entry in entries) {
          distribution[entry.category] = (distribution[entry.category] ?? 0) + 1;
        }

        emit(WeeklySummaryLoaded(
          weekEntries: entries,
          trend: _convertTrend(trend),
          averageIntensity: _calculateAverageIntensity(entries),
          moodDistribution: distribution,
          patternInsight: insight,
        ));
      } else {
        emit(const MoodError(message: 'Could not analyze patterns'));
      }
    } catch (e) {
      emit(MoodError(message: 'Failed to analyze patterns: $e'));
    }
  }

  void _onClearMoodError(ClearMoodError event, Emitter<MoodState> emit) {
    emit(const MoodInitial());
  }

  double? _calculateAverageIntensity(List<MoodEntry> entries) {
    if (entries.isEmpty) return null;
    final total = entries.fold<int>(0, (sum, e) => sum + e.intensity.value);
    return total / entries.length;
  }

  MoodTrend _convertTrend(MoodTrendRepository trend) {
    switch (trend) {
      case MoodTrendRepository.improving:
        return MoodTrend.improving;
      case MoodTrendRepository.declining:
        return MoodTrend.declining;
      case MoodTrendRepository.stable:
        return MoodTrend.stable;
    }
  }
}
