import 'package:ai_buddy/core/ai/enhanced_gemini_service.dart';
import 'package:ai_buddy/data/models/mood_entry.dart';
import 'package:ai_buddy/data/repositories/mood_repository.dart';
import 'package:ai_buddy/features/analytics/bloc/analytics_bloc.dart';
import 'package:ai_buddy/features/analytics/screens/analytics_screen.dart';
import 'package:ai_buddy/features/analytics/widgets/summary_view.dart';
import 'package:ai_buddy/features/analytics/widgets/visual_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Given AnalyticsLoaded state, AnalyticsScreen shows SummaryView by default',
    (tester) async {
      final bloc = AnalyticsBloc(
        moodRepository: TestMoodRepository(_sampleMoodEntries()),
        aiService: TestEnhancedGeminiService(_samplePatternAnalysis()),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AnalyticsBloc>.value(
            value: bloc,
            child: const AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SummaryView), findsOneWidget);
      expect(find.byType(VisualView), findsNothing);
    },
  );

  testWidgets('Tapping Visual segment shows VisualView', (tester) async {
    final bloc = AnalyticsBloc(
      moodRepository: TestMoodRepository(_sampleMoodEntries()),
      aiService: TestEnhancedGeminiService(_samplePatternAnalysis()),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AnalyticsBloc>.value(
          value: bloc,
          child: const AnalyticsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Visual').first);
    await tester.pumpAndSettle();

    expect(find.byType(VisualView), findsOneWidget);
  });
}

PatternAnalysis _samplePatternAnalysis() {
  return PatternAnalysis(
    overallTrend: 'improving',
    trendDescription: 'Mood trend is improving.',
    commonTriggers: const ['Deadlines'],
    positivePatterns: const ['Morning walk'],
    concerningPatterns: const ['Late sleep'],
    recurringThemes: const ['Routine', 'Rest'],
    strengths: const ['Consistency'],
    growthOpportunities: const ['Evening routine'],
    personalizedInsight: 'You are becoming more emotionally steady this week.',
  );
}

List<MoodEntry> _sampleMoodEntries() {
  final now = DateTime.now();
  return [
    MoodEntry(
      category: MoodCategory.happy,
      intensity: MoodIntensity.high,
      timestamp: now.subtract(const Duration(days: 1)),
    ),
    MoodEntry(
      category: MoodCategory.calm,
      intensity: MoodIntensity.neutral,
      timestamp: now.subtract(const Duration(days: 2)),
    ),
    MoodEntry(
      category: MoodCategory.anxious,
      intensity: MoodIntensity.low,
      timestamp: now.subtract(const Duration(days: 4)),
    ),
  ];
}

class TestEnhancedGeminiService extends EnhancedGeminiService {
  final PatternAnalysis result;

  TestEnhancedGeminiService(this.result) : super(apiKey: 'test-key');

  @override
  Future<PatternAnalysis> analyzePatterns({
    required List<MoodEntry> moodEntries,
    List<dynamic>? journalEntries,
    int periodDays = 30,
  }) async {
    return result;
  }
}

class TestMoodRepository implements MoodRepository {
  final List<MoodEntry> _allEntries;

  TestMoodRepository(this._allEntries);

  @override
  Future<MoodEntry> saveMoodEntry({
    required MoodCategory category,
    required MoodIntensity intensity,
    String? notes,
    List<String>? triggers,
    List<String>? activities,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<MoodEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return _allEntries.where((entry) {
      final afterStart =
          startDate == null || !entry.timestamp.isBefore(startDate);
      final beforeEnd = endDate == null || !entry.timestamp.isAfter(endDate);
      return afterStart && beforeEnd;
    }).toList();
  }

  @override
  Future<MoodEntry?> getMoodEntryById(String entryId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateMoodInsight(String entryId, String insight) async {}

  @override
  Future<List<MoodEntry>> getTodaysMoodEntries() {
    throw UnimplementedError();
  }

  @override
  Future<List<MoodEntry>> getThisWeeksMoodEntries() {
    throw UnimplementedError();
  }

  @override
  Future<double?> getAverageMood({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearAllMoodEntries() {
    throw UnimplementedError();
  }

  @override
  Future<MoodTrendRepository> getMoodTrend() async {
    return MoodTrendRepository.stable;
  }
}
