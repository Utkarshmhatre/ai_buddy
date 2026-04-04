import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../data/models/mood_entry.dart';
import '../../data/models/journal_entry.dart';

/// Predictive mood analysis service for forecasting and proactive suggestions
class PredictiveMoodService {
  late final GenerativeModel _predictionModel;
  final String _apiKey;

  PredictiveMoodService({required String apiKey}) : _apiKey = apiKey {
    _initializeModel();
  }

  void _initializeModel() {
    _predictionModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3, // Lower for more consistent predictions
        topP: 0.9,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.text(_predictionSystemPrompt),
    );
  }

  static const String _predictionSystemPrompt = '''
You are an expert mood pattern analyst for a mental health app.
Your role is to analyze mood data and predict future mood states based on patterns.

You analyze:
- Time-based patterns (day of week, time of day, seasonal)
- Trigger correlations (activities, events, sleep, social interactions)
- Trend trajectories (improving, declining, stable, cyclical)
- Historical patterns unique to this user

Provide predictions with:
- Confidence levels (0.0-1.0)
- Reasoning based on patterns
- Proactive suggestions to improve predicted outcomes
- Risk factors to watch for

Always be hopeful but realistic. Never guarantee outcomes.
Always respond with JSON in the specified format.
''';

  /// Predict mood for the upcoming period based on historical data
  Future<MoodPrediction> predictMood({
    required List<MoodEntry> moodHistory,
    List<JournalEntry>? journalHistory,
    DateTime? targetDate,
  }) async {
    if (moodHistory.isEmpty) {
      return MoodPrediction.insufficientData();
    }

    try {
      final target = targetDate ?? DateTime.now().add(const Duration(days: 1));
      
      // Build data summary for AI
      final moodSummary = _buildMoodSummary(moodHistory);
      final journalSummary = journalHistory != null 
          ? _buildJournalSummary(journalHistory) 
          : '';
      
      // Calculate basic statistics
      final stats = _calculateStatistics(moodHistory);

      final prompt = '''
Analyze the following mood data and predict the user's likely mood state for ${_formatDate(target)}:

MOOD HISTORY (Last ${moodHistory.length} entries):
$moodSummary

${journalSummary.isNotEmpty ? 'JOURNAL INSIGHTS:\n$journalSummary\n' : ''}

CALCULATED STATISTICS:
- Average mood score: ${stats['average']?.toStringAsFixed(1)}
- Mood trend (7 days): ${stats['trend']}
- Most common category: ${stats['commonCategory']}
- Most frequent triggers: ${stats['topTriggers']}
- Best day of week: ${stats['bestDay']}
- Challenging day of week: ${stats['challengingDay']}

TARGET DATE CONTEXT:
- Day of week: ${_getDayOfWeek(target)}
- Time context: ${_getTimeContext(target)}

Provide a prediction in JSON format:
{
  "predictedMoodCategory": "one of: happy, calm, anxious, stressed, sad, angry, neutral, confused, hopeful",
  "predictedMoodScore": number 1-10,
  "confidence": number 0.0-1.0,
  "reasoning": "Brief explanation of why this prediction",
  "riskFactors": ["potential challenges to watch for"],
  "protectiveFactors": ["factors likely to help"],
  "proactiveSuggestions": [
    {"suggestion": "specific actionable tip", "timing": "when to do it", "priority": "high/medium/low"}
  ],
  "patternInsights": ["interesting patterns observed"],
  "comparisonToBaseline": "better/same/worse than usual"
}
''';

      final response = await _predictionModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return MoodPrediction.fromJson(json, target);
      }
    } catch (e) {
      debugPrint('PredictiveMoodService: Prediction failed: $e');
    }

    return MoodPrediction.error('Unable to generate prediction');
  }

  /// Generate weekly mood forecast
  Future<WeeklyForecast> generateWeeklyForecast({
    required List<MoodEntry> moodHistory,
  }) async {
    if (moodHistory.length < 7) {
      return WeeklyForecast.insufficientData();
    }

    try {
      final stats = _calculateStatistics(moodHistory);
      final moodSummary = _buildMoodSummary(moodHistory);

      final prompt = '''
Based on the mood history, provide a 7-day forecast:

MOOD HISTORY:
$moodSummary

STATISTICS:
- Average mood: ${stats['average']?.toStringAsFixed(1)}
- Best days: ${stats['bestDay']}
- Challenging days: ${stats['challengingDay']}
- Current trend: ${stats['trend']}

Generate a weekly forecast in JSON format:
{
  "overallOutlook": "positive/neutral/cautious",
  "outlookDescription": "Brief description of the week ahead",
  "dailyPredictions": [
    {
      "dayOfWeek": "Monday",
      "predictedScore": 7,
      "briefNote": "Why this day might be like this"
    }
  ],
  "weeklyRisks": ["potential challenges this week"],
  "weeklyOpportunities": ["opportunities for positive moments"],
  "keyRecommendation": "One most important recommendation for the week"
}
''';

      final response = await _predictionModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return WeeklyForecast.fromJson(json);
      }
    } catch (e) {
      debugPrint('PredictiveMoodService: Weekly forecast failed: $e');
    }

    return WeeklyForecast.error('Unable to generate forecast');
  }

  /// Detect anomalies in mood patterns
  Future<List<MoodAnomaly>> detectAnomalies({
    required List<MoodEntry> moodHistory,
  }) async {
    if (moodHistory.length < 14) {
      return [];
    }

    try {
      final moodSummary = _buildMoodSummary(moodHistory);
      final stats = _calculateStatistics(moodHistory);

      final prompt = '''
Analyze this mood history for anomalies or concerning patterns:

MOOD HISTORY:
$moodSummary

BASELINE STATISTICS:
- Average mood: ${stats['average']?.toStringAsFixed(1)}
- Typical range: ${stats['minScore']}-${stats['maxScore']}

Identify any anomalies in JSON format:
{
  "anomalies": [
    {
      "type": "sudden_drop|sudden_improvement|unusual_pattern|concerning_trend|irregular_timing",
      "severity": "low|medium|high",
      "description": "What was detected",
      "date": "when it occurred (ISO date)",
      "recommendation": "What to do about it"
    }
  ],
  "overallAssessment": "stable|needs_attention|concerning",
  "positivePatterns": ["any positive patterns noticed"]
}
''';

      final response = await _predictionModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        final anomaliesJson = json['anomalies'] as List<dynamic>? ?? [];
        return anomaliesJson.map((a) => MoodAnomaly.fromJson(a)).toList();
      }
    } catch (e) {
      debugPrint('PredictiveMoodService: Anomaly detection failed: $e');
    }

    return [];
  }

  /// Get optimal times for activities based on mood patterns
  Future<OptimalTimings> getOptimalTimings({
    required List<MoodEntry> moodHistory,
  }) async {
    if (moodHistory.length < 14) {
      return OptimalTimings.defaults();
    }

    try {
      // Group moods by time of day
      final morningMoods = <int>[];
      final afternoonMoods = <int>[];
      final eveningMoods = <int>[];
      final nightMoods = <int>[];

      for (final mood in moodHistory) {
        final hour = mood.timestamp.hour;
        final score = mood.intensity.value;
        
        if (hour >= 5 && hour < 12) {
          morningMoods.add(score);
        } else if (hour >= 12 && hour < 17) {
          afternoonMoods.add(score);
        } else if (hour >= 17 && hour < 21) {
          eveningMoods.add(score);
        } else {
          nightMoods.add(score);
        }
      }

      // Calculate averages
      double avg(List<int> list) => 
          list.isEmpty ? 0 : list.reduce((a, b) => a + b) / list.length;

      final timeData = {
        'morning': {'avg': avg(morningMoods), 'count': morningMoods.length},
        'afternoon': {'avg': avg(afternoonMoods), 'count': afternoonMoods.length},
        'evening': {'avg': avg(eveningMoods), 'count': eveningMoods.length},
        'night': {'avg': avg(nightMoods), 'count': nightMoods.length},
      };

      // Find best times
      String bestTime = 'morning';
      String challengingTime = 'morning';
      double bestAvg = 0;
      double worstAvg = 10;

      timeData.forEach((time, data) {
        final count = data['count'] as int;
        if (count >= 3) {
          final average = data['avg'] as double;
          if (average > bestAvg) {
            bestAvg = average;
            bestTime = time;
          }
          if (average < worstAvg) {
            worstAvg = average;
            challengingTime = time;
          }
        }
      });

      return OptimalTimings(
        bestTimeForCheckIn: _mapTimePeriodToHour(bestTime),
        bestTimeForExercises: _mapTimePeriodToHour(challengingTime), // During challenging times
        bestTimeForJournaling: 20, // Default evening
        bestDayOfWeek: _findBestDay(moodHistory),
        reasoning: 'Based on ${moodHistory.length} mood entries, your best mood times are during $bestTime. Consider exercises during $challengingTime when you might need extra support.',
      );
    } catch (e) {
      debugPrint('PredictiveMoodService: Optimal timings failed: $e');
    }

    return OptimalTimings.defaults();
  }

  // ==================== Helper Methods ====================

  String _buildMoodSummary(List<MoodEntry> moods) {
    final recentMoods = moods.take(30).toList();
    final buffer = StringBuffer();
    
    for (final mood in recentMoods) {
      buffer.writeln(
        '${_formatDate(mood.timestamp)}: ${mood.category.name} '
        '(${mood.intensity.value}/10)'
        '${mood.triggers?.isNotEmpty == true ? ' - Triggers: ${mood.triggers!.join(", ")}' : ''}'
      );
    }
    
    return buffer.toString();
  }

  String _buildJournalSummary(List<JournalEntry> journals) {
    final recent = journals.take(10).toList();
    if (recent.isEmpty) return '';

    final buffer = StringBuffer();
    for (final journal in recent) {
      buffer.writeln(
        '${_formatDate(journal.createdAt)}: Themes: ${journal.themes?.join(", ") ?? "none"}, '
        'Mood: ${journal.derivedMoodScore ?? "unknown"}'
      );
    }
    return buffer.toString();
  }

  Map<String, dynamic> _calculateStatistics(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return {
        'average': 0.0,
        'trend': 'unknown',
        'commonCategory': 'unknown',
        'topTriggers': 'none',
        'bestDay': 'unknown',
        'challengingDay': 'unknown',
        'minScore': 0,
        'maxScore': 0,
      };
    }

    // Average
    final scores = moods.map((m) => m.intensity.value).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;

    // Trend (compare recent week to previous)
    String trend = 'stable';
    if (moods.length >= 14) {
      final recentAvg = scores.take(7).reduce((a, b) => a + b) / 7;
      final previousAvg = scores.skip(7).take(7).reduce((a, b) => a + b) / 7;
      if (recentAvg > previousAvg + 0.5) {
        trend = 'improving';
      } else if (recentAvg < previousAvg - 0.5) {
        trend = 'declining';
      }
    }

    // Most common category
    final categoryCounts = <MoodCategory, int>{};
    for (final mood in moods) {
      categoryCounts[mood.category] = (categoryCounts[mood.category] ?? 0) + 1;
    }
    final commonCategory = categoryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .name;

    // Top triggers
    final allTriggers = moods.expand((m) => m.triggers ?? <String>[]).toList();
    final triggerCounts = <String, int>{};
    for (final trigger in allTriggers) {
      triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
    }
    final topTriggers = triggerCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final topTriggersList = topTriggers.take(3).map((e) => e.key).join(', ');

    // Best/worst day of week
    final dayScores = <int, List<int>>{};
    for (final mood in moods) {
      final day = mood.timestamp.weekday;
      dayScores.putIfAbsent(day, () => []).add(mood.intensity.value);
    }
    
    String bestDay = 'unknown';
    String challengingDay = 'unknown';
    double bestAvg = 0;
    double worstAvg = 10;
    
    dayScores.forEach((day, scores) {
      if (scores.length >= 2) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        if (avg > bestAvg) {
          bestAvg = avg;
          bestDay = _getDayName(day);
        }
        if (avg < worstAvg) {
          worstAvg = avg;
          challengingDay = _getDayName(day);
        }
      }
    });

    return {
      'average': average,
      'trend': trend,
      'commonCategory': commonCategory,
      'topTriggers': topTriggersList.isEmpty ? 'none identified' : topTriggersList,
      'bestDay': bestDay,
      'challengingDay': challengingDay,
      'minScore': scores.reduce((a, b) => a < b ? a : b),
      'maxScore': scores.reduce((a, b) => a > b ? a : b),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    return _getDayName(date.weekday);
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getTimeContext(DateTime date) {
    final hour = date.hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  int _mapTimePeriodToHour(String period) {
    switch (period) {
      case 'morning': return 9;
      case 'afternoon': return 14;
      case 'evening': return 19;
      case 'night': return 21;
      default: return 10;
    }
  }

  int _findBestDay(List<MoodEntry> moods) {
    final dayScores = <int, List<int>>{};
    for (final mood in moods) {
      final day = mood.timestamp.weekday;
      dayScores.putIfAbsent(day, () => []).add(mood.intensity.value);
    }
    
    int bestDay = 1;
    double bestAvg = 0;
    
    dayScores.forEach((day, scores) {
      if (scores.length >= 2) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        if (avg > bestAvg) {
          bestAvg = avg;
          bestDay = day;
        }
      }
    });
    
    return bestDay;
  }
}

// ==================== Data Classes ====================

/// Single day mood prediction
class MoodPrediction {
  final DateTime targetDate;
  final MoodCategory? predictedCategory;
  final int predictedScore;
  final double confidence;
  final String reasoning;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final List<ProactiveSuggestion> suggestions;
  final List<String> patternInsights;
  final String comparisonToBaseline;
  final bool hasError;
  final String? errorMessage;

  MoodPrediction({
    required this.targetDate,
    this.predictedCategory,
    required this.predictedScore,
    required this.confidence,
    required this.reasoning,
    this.riskFactors = const [],
    this.protectiveFactors = const [],
    this.suggestions = const [],
    this.patternInsights = const [],
    this.comparisonToBaseline = 'same',
    this.hasError = false,
    this.errorMessage,
  });

  factory MoodPrediction.fromJson(Map<String, dynamic> json, DateTime targetDate) {
    final category = _parseMoodCategory(json['predictedMoodCategory'] as String?);
    final suggestionsJson = json['proactiveSuggestions'] as List<dynamic>? ?? [];
    
    return MoodPrediction(
      targetDate: targetDate,
      predictedCategory: category,
      predictedScore: json['predictedMoodScore'] as int? ?? 5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      reasoning: json['reasoning'] as String? ?? '',
      riskFactors: (json['riskFactors'] as List<dynamic>?)?.cast<String>() ?? [],
      protectiveFactors: (json['protectiveFactors'] as List<dynamic>?)?.cast<String>() ?? [],
      suggestions: suggestionsJson.map((s) => ProactiveSuggestion.fromJson(s)).toList(),
      patternInsights: (json['patternInsights'] as List<dynamic>?)?.cast<String>() ?? [],
      comparisonToBaseline: json['comparisonToBaseline'] as String? ?? 'same',
    );
  }

  factory MoodPrediction.insufficientData() {
    return MoodPrediction(
      targetDate: DateTime.now(),
      predictedScore: 5,
      confidence: 0,
      reasoning: 'Not enough data to make a prediction. Keep tracking your mood!',
      hasError: true,
      errorMessage: 'Insufficient data',
    );
  }

  factory MoodPrediction.error(String message) {
    return MoodPrediction(
      targetDate: DateTime.now(),
      predictedScore: 5,
      confidence: 0,
      reasoning: message,
      hasError: true,
      errorMessage: message,
    );
  }

  static MoodCategory? _parseMoodCategory(String? name) {
    if (name == null) return null;
    try {
      return MoodCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Proactive suggestion with timing
class ProactiveSuggestion {
  final String suggestion;
  final String timing;
  final String priority;

  ProactiveSuggestion({
    required this.suggestion,
    required this.timing,
    required this.priority,
  });

  factory ProactiveSuggestion.fromJson(Map<String, dynamic> json) {
    return ProactiveSuggestion(
      suggestion: json['suggestion'] as String? ?? '',
      timing: json['timing'] as String? ?? 'anytime',
      priority: json['priority'] as String? ?? 'medium',
    );
  }
}

/// Weekly mood forecast
class WeeklyForecast {
  final String overallOutlook;
  final String outlookDescription;
  final List<DailyPrediction> dailyPredictions;
  final List<String> weeklyRisks;
  final List<String> weeklyOpportunities;
  final String keyRecommendation;
  final bool hasError;
  final String? errorMessage;

  WeeklyForecast({
    required this.overallOutlook,
    required this.outlookDescription,
    this.dailyPredictions = const [],
    this.weeklyRisks = const [],
    this.weeklyOpportunities = const [],
    required this.keyRecommendation,
    this.hasError = false,
    this.errorMessage,
  });

  factory WeeklyForecast.fromJson(Map<String, dynamic> json) {
    final dailyJson = json['dailyPredictions'] as List<dynamic>? ?? [];
    
    return WeeklyForecast(
      overallOutlook: json['overallOutlook'] as String? ?? 'neutral',
      outlookDescription: json['outlookDescription'] as String? ?? '',
      dailyPredictions: dailyJson.map((d) => DailyPrediction.fromJson(d)).toList(),
      weeklyRisks: (json['weeklyRisks'] as List<dynamic>?)?.cast<String>() ?? [],
      weeklyOpportunities: (json['weeklyOpportunities'] as List<dynamic>?)?.cast<String>() ?? [],
      keyRecommendation: json['keyRecommendation'] as String? ?? '',
    );
  }

  factory WeeklyForecast.insufficientData() {
    return WeeklyForecast(
      overallOutlook: 'unknown',
      outlookDescription: 'Track your mood for at least a week to see forecasts.',
      keyRecommendation: 'Keep logging your daily mood!',
      hasError: true,
      errorMessage: 'Insufficient data',
    );
  }

  factory WeeklyForecast.error(String message) {
    return WeeklyForecast(
      overallOutlook: 'unknown',
      outlookDescription: message,
      keyRecommendation: '',
      hasError: true,
      errorMessage: message,
    );
  }
}

/// Daily prediction within weekly forecast
class DailyPrediction {
  final String dayOfWeek;
  final int predictedScore;
  final String briefNote;

  DailyPrediction({
    required this.dayOfWeek,
    required this.predictedScore,
    required this.briefNote,
  });

  factory DailyPrediction.fromJson(Map<String, dynamic> json) {
    return DailyPrediction(
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      predictedScore: json['predictedScore'] as int? ?? 5,
      briefNote: json['briefNote'] as String? ?? '',
    );
  }
}

/// Detected mood anomaly
class MoodAnomaly {
  final String type;
  final String severity;
  final String description;
  final String? date;
  final String recommendation;

  MoodAnomaly({
    required this.type,
    required this.severity,
    required this.description,
    this.date,
    required this.recommendation,
  });

  factory MoodAnomaly.fromJson(Map<String, dynamic> json) {
    return MoodAnomaly(
      type: json['type'] as String? ?? 'unknown',
      severity: json['severity'] as String? ?? 'low',
      description: json['description'] as String? ?? '',
      date: json['date'] as String?,
      recommendation: json['recommendation'] as String? ?? '',
    );
  }
}

/// Optimal timing recommendations
class OptimalTimings {
  final int bestTimeForCheckIn;
  final int bestTimeForExercises;
  final int bestTimeForJournaling;
  final int bestDayOfWeek;
  final String reasoning;

  OptimalTimings({
    required this.bestTimeForCheckIn,
    required this.bestTimeForExercises,
    required this.bestTimeForJournaling,
    required this.bestDayOfWeek,
    required this.reasoning,
  });

  factory OptimalTimings.defaults() {
    return OptimalTimings(
      bestTimeForCheckIn: 10,
      bestTimeForExercises: 15,
      bestTimeForJournaling: 20,
      bestDayOfWeek: 1,
      reasoning: 'Using default timings. Track more moods for personalized recommendations.',
    );
  }
}
