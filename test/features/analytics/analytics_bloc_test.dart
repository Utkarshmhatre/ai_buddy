import 'package:ai_buddy/core/ai/enhanced_gemini_service.dart';
import 'package:ai_buddy/data/models/mood_entry.dart';
import 'package:ai_buddy/data/repositories/mood_repository.dart';
import 'package:ai_buddy/features/analytics/bloc/analytics_bloc.dart';
import 'package:ai_buddy/features/analytics/models/analytics_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TestMoodRepository moodRepository;
  late TestEnhancedGeminiService aiService;
  late AnalyticsBloc bloc;

  setUp(() {
    moodRepository = TestMoodRepository(_sampleMoodEntries());
    aiService = TestEnhancedGeminiService(_samplePatternAnalysis());
    bloc = AnalyticsBloc(moodRepository: moodRepository, aiService: aiService);
  });

  tearDown(() async {
    await bloc.close();
  });

  test(
    'LoadAnalytics(week) emits Loading then Loaded with non-null moodNarrative',
    () async {
      final statesFuture = bloc.stream.take(2).toList();

      bloc.add(const LoadAnalytics(AnalyticsPeriod.week));

      final states = await statesFuture;
      expect(states.first, isA<AnalyticsLoading>());

      final loaded = states.last as AnalyticsLoaded;
      expect(loaded.period, AnalyticsPeriod.week);
      expect(loaded.moodNarrative, isNotEmpty);
    },
  );

  test(
    'SwitchMode emits Loaded with updated mode and does not reload data',
    () async {
      final initialLoaded = await _loadWeek(bloc);
      final repoCallsBefore = moodRepository.getMoodEntriesCalls;
      final aiCallsBefore = aiService.analyzePatternsCalls;

      final nextLoadedFuture = bloc.stream.firstWhere(
        (state) => state is AnalyticsLoaded,
      );
      bloc.add(const SwitchMode(AnalyticsMode.visual));

      final nextLoaded = await nextLoadedFuture as AnalyticsLoaded;
      expect(nextLoaded.mode, AnalyticsMode.visual);
      expect(nextLoaded.period, initialLoaded.period);
      expect(nextLoaded.moodNarrative, initialLoaded.moodNarrative);
      expect(nextLoaded.patternInsight, initialLoaded.patternInsight);
      expect(moodRepository.getMoodEntriesCalls, repoCallsBefore);
      expect(aiService.analyzePatternsCalls, aiCallsBefore);
    },
  );

  test('SwitchPeriod(month) emits Loading then Loaded', () async {
    await _loadWeek(bloc);

    final statesFuture = bloc.stream.take(2).toList();
    bloc.add(const SwitchPeriod(AnalyticsPeriod.month));

    final states = await statesFuture;
    expect(states.first, isA<AnalyticsLoading>());

    final loaded = states.last as AnalyticsLoaded;
    expect(loaded.period, AnalyticsPeriod.month);
  });

  test(
    'SwitchChartType emits Loaded with updated chartType and does not reload data',
    () async {
      await _loadWeek(bloc);
      final repoCallsBefore = moodRepository.getMoodEntriesCalls;
      final aiCallsBefore = aiService.analyzePatternsCalls;

      final nextLoadedFuture = bloc.stream.firstWhere(
        (state) => state is AnalyticsLoaded,
      );
      bloc.add(const SwitchChartType(AnalyticsChartType.distribution));

      final nextLoaded = await nextLoadedFuture as AnalyticsLoaded;
      expect(nextLoaded.chartType, AnalyticsChartType.distribution);
      expect(moodRepository.getMoodEntriesCalls, repoCallsBefore);
      expect(aiService.analyzePatternsCalls, aiCallsBefore);
    },
  );
}

Future<AnalyticsLoaded> _loadWeek(AnalyticsBloc bloc) async {
  final loadedFuture = bloc.stream.firstWhere(
    (state) => state is AnalyticsLoaded,
  );
  bloc.add(const LoadAnalytics(AnalyticsPeriod.week));
  return await loadedFuture as AnalyticsLoaded;
}

PatternAnalysis _samplePatternAnalysis() {
  return PatternAnalysis(
    overallTrend: 'improving',
    trendDescription: 'Your mood trend is gradually improving.',
    commonTriggers: const ['Work stress'],
    positivePatterns: const ['Morning walk'],
    concerningPatterns: const ['Poor sleep'],
    recurringThemes: const ['Balance', 'Gratitude'],
    strengths: const ['Consistency'],
    growthOpportunities: const ['Evening wind-down'],
    personalizedInsight:
        'You have been steadily building momentum with healthier coping routines.',
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
      timestamp: now.subtract(const Duration(days: 3)),
    ),
    MoodEntry(
      category: MoodCategory.anxious,
      intensity: MoodIntensity.low,
      timestamp: now.subtract(const Duration(days: 10)),
    ),
    MoodEntry(
      category: MoodCategory.grateful,
      intensity: MoodIntensity.high,
      timestamp: now.subtract(const Duration(days: 20)),
    ),
    MoodEntry(
      category: MoodCategory.hopeful,
      intensity: MoodIntensity.veryHigh,
      timestamp: now.subtract(const Duration(days: 50)),
    ),
  ];
}

class TestEnhancedGeminiService extends EnhancedGeminiService {
  int analyzePatternsCalls = 0;
  final PatternAnalysis result;

  TestEnhancedGeminiService(this.result) : super(apiKey: 'test-key');

  @override
  Future<PatternAnalysis> analyzePatterns({
    required List<MoodEntry> moodEntries,
    List<dynamic>? journalEntries,
    int periodDays = 30,
  }) async {
    analyzePatternsCalls += 1;
    return result;
  }
}

class TestMoodRepository implements MoodRepository {
  int getMoodEntriesCalls = 0;
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
    getMoodEntriesCalls += 1;

    var filtered = _allEntries.where((entry) {
      final afterStart =
          startDate == null || !entry.timestamp.isBefore(startDate);
      final beforeEnd = endDate == null || !entry.timestamp.isAfter(endDate);
      return afterStart && beforeEnd;
    }).toList();

    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
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
