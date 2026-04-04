import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/repositories/mood_repository.dart';
import '../models/analytics_enums.dart';

/// Events for AnalyticsBloc.
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads analytics data.
class LoadAnalytics extends AnalyticsEvent {
  final AnalyticsPeriod period;

  const LoadAnalytics(this.period);

  @override
  List<Object?> get props => [period];
}

/// Switches between summary and visual modes.
class SwitchMode extends AnalyticsEvent {
  final AnalyticsMode mode;

  const SwitchMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Switches the active analytics period.
class SwitchPeriod extends AnalyticsEvent {
  final AnalyticsPeriod period;

  const SwitchPeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Switches the visual chart type.
class SwitchChartType extends AnalyticsEvent {
  final AnalyticsChartType chartType;

  const SwitchChartType(this.chartType);

  @override
  List<Object?> get props => [chartType];
}

/// States for AnalyticsBloc.
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial analytics state.
class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// Loading analytics data.
class AnalyticsLoading extends AnalyticsState {
  final AnalyticsMode mode;
  final AnalyticsPeriod period;
  final AnalyticsChartType chartType;

  const AnalyticsLoading({
    required this.mode,
    required this.period,
    required this.chartType,
  });

  AnalyticsLoading copyWith({
    AnalyticsMode? mode,
    AnalyticsPeriod? period,
    AnalyticsChartType? chartType,
  }) {
    return AnalyticsLoading(
      mode: mode ?? this.mode,
      period: period ?? this.period,
      chartType: chartType ?? this.chartType,
    );
  }

  @override
  List<Object?> get props => [mode, period, chartType];
}

/// Failed analytics state.
class AnalyticsError extends AnalyticsState {
  final String message;
  final AnalyticsMode mode;
  final AnalyticsPeriod period;
  final AnalyticsChartType chartType;

  const AnalyticsError({
    required this.message,
    required this.mode,
    required this.period,
    required this.chartType,
  });

  AnalyticsError copyWith({
    String? message,
    AnalyticsMode? mode,
    AnalyticsPeriod? period,
    AnalyticsChartType? chartType,
  }) {
    return AnalyticsError(
      message: message ?? this.message,
      mode: mode ?? this.mode,
      period: period ?? this.period,
      chartType: chartType ?? this.chartType,
    );
  }

  @override
  List<Object?> get props => [message, mode, period, chartType];
}

/// Fully loaded analytics data.
class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsMode mode;
  final AnalyticsPeriod period;
  final AnalyticsChartType chartType;
  final List<MoodEntry> moodEntries;
  final Map<MoodCategory, int> moodDistribution;
  final double averageMoodScore;
  final String moodNarrative;
  final String patternInsight;
  final String prediction;
  final String sessionThemes;

  const AnalyticsLoaded({
    required this.mode,
    required this.period,
    required this.chartType,
    required this.moodEntries,
    required this.moodDistribution,
    required this.averageMoodScore,
    required this.moodNarrative,
    required this.patternInsight,
    required this.prediction,
    required this.sessionThemes,
  });

  AnalyticsLoaded copyWith({
    AnalyticsMode? mode,
    AnalyticsPeriod? period,
    AnalyticsChartType? chartType,
    List<MoodEntry>? moodEntries,
    Map<MoodCategory, int>? moodDistribution,
    double? averageMoodScore,
    String? moodNarrative,
    String? patternInsight,
    String? prediction,
    String? sessionThemes,
  }) {
    return AnalyticsLoaded(
      mode: mode ?? this.mode,
      period: period ?? this.period,
      chartType: chartType ?? this.chartType,
      moodEntries: moodEntries ?? this.moodEntries,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      averageMoodScore: averageMoodScore ?? this.averageMoodScore,
      moodNarrative: moodNarrative ?? this.moodNarrative,
      patternInsight: patternInsight ?? this.patternInsight,
      prediction: prediction ?? this.prediction,
      sessionThemes: sessionThemes ?? this.sessionThemes,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    period,
    chartType,
    moodEntries,
    moodDistribution,
    averageMoodScore,
    moodNarrative,
    patternInsight,
    prediction,
    sessionThemes,
  ];
}

/// Analytics bloc for summary and chart visualizations.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final MoodRepository _moodRepository;
  final EnhancedGeminiService _aiService;

  AnalyticsMode _currentMode = AnalyticsMode.summary;
  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.week;
  AnalyticsChartType _currentChartType = AnalyticsChartType.line;

  AnalyticsBloc({
    required MoodRepository moodRepository,
    required EnhancedGeminiService aiService,
  }) : _moodRepository = moodRepository,
       _aiService = aiService,
       super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<SwitchMode>(_onSwitchMode);
    on<SwitchPeriod>(_onSwitchPeriod);
    on<SwitchChartType>(_onSwitchChartType);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    _currentPeriod = event.period;
    emit(
      AnalyticsLoading(
        mode: _currentMode,
        period: _currentPeriod,
        chartType: _currentChartType,
      ),
    );

    try {
      final now = DateTime.now();
      final startDate = _currentPeriod.startDate(now);
      final moodEntries = await _moodRepository.getMoodEntries(
        startDate: startDate,
        endDate: now,
      );
      moodEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final insights = await _buildInsights(moodEntries);

      emit(
        AnalyticsLoaded(
          mode: _currentMode,
          period: _currentPeriod,
          chartType: _currentChartType,
          moodEntries: moodEntries,
          moodDistribution: _buildMoodDistribution(moodEntries),
          averageMoodScore: _calculateAverageMoodScore(moodEntries),
          moodNarrative: insights.moodNarrative,
          patternInsight: insights.patternInsight,
          prediction: insights.prediction,
          sessionThemes: insights.sessionThemes,
        ),
      );
    } catch (error) {
      emit(
        AnalyticsError(
          message: 'Failed to load analytics: $error',
          mode: _currentMode,
          period: _currentPeriod,
          chartType: _currentChartType,
        ),
      );
    }
  }

  void _onSwitchMode(SwitchMode event, Emitter<AnalyticsState> emit) {
    _currentMode = event.mode;
    final currentState = state;

    if (currentState is AnalyticsLoaded) {
      emit(currentState.copyWith(mode: _currentMode));
      return;
    }

    if (currentState is AnalyticsLoading) {
      emit(currentState.copyWith(mode: _currentMode));
      return;
    }

    if (currentState is AnalyticsError) {
      emit(currentState.copyWith(mode: _currentMode));
    }
  }

  void _onSwitchPeriod(SwitchPeriod event, Emitter<AnalyticsState> emit) {
    add(LoadAnalytics(event.period));
  }

  void _onSwitchChartType(SwitchChartType event, Emitter<AnalyticsState> emit) {
    _currentChartType = event.chartType;
    final currentState = state;

    if (currentState is AnalyticsLoaded) {
      emit(currentState.copyWith(chartType: _currentChartType));
      return;
    }

    if (currentState is AnalyticsLoading) {
      emit(currentState.copyWith(chartType: _currentChartType));
      return;
    }

    if (currentState is AnalyticsError) {
      emit(currentState.copyWith(chartType: _currentChartType));
    }
  }

  double _calculateAverageMoodScore(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final total = entries.fold<double>(
      0,
      (sum, entry) => sum + (entry.moodScore * 2),
    );
    return total / entries.length;
  }

  Map<MoodCategory, int> _buildMoodDistribution(List<MoodEntry> entries) {
    final distribution = <MoodCategory, int>{};
    for (final entry in entries) {
      distribution[entry.category] = (distribution[entry.category] ?? 0) + 1;
    }
    return Map.unmodifiable(distribution);
  }

  Future<_AnalyticsInsightText> _buildInsights(List<MoodEntry> entries) async {
    if (entries.isEmpty) {
      return const _AnalyticsInsightText(
        moodNarrative:
            'Log a few moods this period to unlock your personalized narrative.',
        patternInsight:
            'Patterns will appear as you add more check-ins across days.',
        prediction:
            'Once enough data is available, AI will forecast likely mood shifts.',
        sessionThemes:
            'Session themes will be summarized after your next few check-ins.',
      );
    }

    try {
      final patternAnalysis = await _aiService.analyzePatterns(
        moodEntries: entries,
        periodDays: _currentPeriod.days,
      );

      final narrative = patternAnalysis.personalizedInsight.trim().isNotEmpty
          ? patternAnalysis.personalizedInsight.trim()
          : patternAnalysis.trendDescription.trim();

      final patternParts = <String>[];
      if (patternAnalysis.positivePatterns.isNotEmpty) {
        patternParts.add(
          'Helpful patterns: ${patternAnalysis.positivePatterns.take(2).join(', ')}.',
        );
      }
      if (patternAnalysis.commonTriggers.isNotEmpty) {
        patternParts.add(
          'Common triggers: ${patternAnalysis.commonTriggers.take(2).join(', ')}.',
        );
      }
      if (patternAnalysis.concerningPatterns.isNotEmpty) {
        patternParts.add(
          'Watch-outs: ${patternAnalysis.concerningPatterns.take(2).join(', ')}.',
        );
      }

      final prediction = _buildPredictionText(patternAnalysis);

      final themesText = patternAnalysis.recurringThemes.isNotEmpty
          ? 'Recurring themes: ${patternAnalysis.recurringThemes.take(5).join(', ')}.'
          : 'Continue tracking to reveal recurring session themes.';

      return _AnalyticsInsightText(
        moodNarrative: narrative.isNotEmpty
            ? narrative
            : 'Your emotional trend this period is ${patternAnalysis.overallTrend}.',
        patternInsight: patternParts.isNotEmpty
            ? patternParts.join(' ')
            : (patternAnalysis.trendDescription.isNotEmpty
                  ? patternAnalysis.trendDescription
                  : 'Keep checking in to unlock deeper pattern analysis.'),
        prediction: prediction,
        sessionThemes: themesText,
      );
    } catch (_) {
      return const _AnalyticsInsightText(
        moodNarrative:
            'You are steadily building a clearer picture of your emotional rhythm.',
        patternInsight:
            'We noticed a few repeating signals, and more check-ins will sharpen them.',
        prediction:
            'If your current routine stays consistent, expect a more stable mood baseline.',
        sessionThemes:
            'Themes are emerging around self-awareness, routines, and emotional balance.',
      );
    }
  }

  String _buildPredictionText(PatternAnalysis patternAnalysis) {
    final buffer = StringBuffer();

    switch (patternAnalysis.overallTrend) {
      case 'improving':
        buffer.write(
          'Your trend points to a steadier and more positive stretch ahead. ',
        );
        break;
      case 'declining':
        buffer.write(
          'The coming days may feel heavier unless support routines stay active. ',
        );
        break;
      case 'fluctuating':
        buffer.write(
          'Expect mixed mood swings; a consistent routine can smooth the curve. ',
        );
        break;
      default:
        buffer.write(
          'Your mood trend looks fairly stable for the next stretch. ',
        );
    }

    if (patternAnalysis.growthOpportunities.isNotEmpty) {
      buffer.write(
        'Focus on ${patternAnalysis.growthOpportunities.first.toLowerCase()}.',
      );
    } else if ((patternAnalysis.timePatterns?['bestTimeOfDay'] as String?) !=
        null) {
      final bestTime = patternAnalysis.timePatterns!['bestTimeOfDay'] as String;
      buffer.write('Lean into your strongest window during the $bestTime.');
    } else {
      buffer.write('Keep logging daily to improve prediction confidence.');
    }

    return buffer.toString().trim();
  }
}

class _AnalyticsInsightText {
  final String moodNarrative;
  final String patternInsight;
  final String prediction;
  final String sessionThemes;

  const _AnalyticsInsightText({
    required this.moodNarrative,
    required this.patternInsight,
    required this.prediction,
    required this.sessionThemes,
  });
}
