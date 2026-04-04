import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../data/models/mood_entry.dart';
import '../../data/models/journal_entry.dart';

/// Service for generating AI-powered reports and exportable summaries
class ReportGenerationService {
  late final GenerativeModel _reportModel;
  final String _apiKey;

  ReportGenerationService({required String apiKey}) : _apiKey = apiKey {
    _initializeModel();
  }

  void _initializeModel() {
    _reportModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.6,
        topP: 0.9,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.text(_reportSystemPrompt),
    );
  }

  static const String _reportSystemPrompt = '''
You are a compassionate mental health insights writer for a wellness app.
Your role is to create warm, encouraging, and insightful reports based on user data.

Guidelines:
- Be warm, supportive, and non-judgmental
- Celebrate progress, no matter how small
- Acknowledge challenges without dwelling on them
- Provide actionable, hopeful suggestions
- Use accessible language (8th grade reading level)
- Never diagnose or provide medical advice
- Maintain privacy - don't include specific details that could identify the user

Report styles:
- Weekly: Conversational, like a supportive friend summarizing the week
- Monthly: More reflective, highlighting growth and patterns
- Therapist Summary: Professional, factual, suitable for sharing with healthcare providers

Always respond with JSON in the specified format.
''';

  /// Generate a weekly narrative report
  Future<WeeklyReport> generateWeeklyReport({
    required List<MoodEntry> moodEntries,
    List<JournalEntry>? journalEntries,
    int exercisesCompleted = 0,
    int checkInStreak = 0,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      // Filter entries to this week
      final weekMoods = moodEntries.where((m) => 
        m.timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        m.timestamp.isBefore(weekEnd.add(const Duration(days: 1)))
      ).toList();

      if (weekMoods.isEmpty) {
        return WeeklyReport.noData(weekStart, weekEnd);
      }

      final moodSummary = _buildMoodSummary(weekMoods);
      final journalSummary = journalEntries != null 
          ? _buildJournalSummary(journalEntries.where((j) =>
              j.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)))).toList())
          : '';
      
      final stats = _calculateWeekStats(weekMoods);

      final prompt = '''
Generate a warm, supportive weekly mental health report for the user.

WEEK: ${_formatDate(weekStart)} to ${_formatDate(weekEnd)}

MOOD DATA THIS WEEK:
$moodSummary

${journalSummary.isNotEmpty ? 'JOURNAL THEMES:\n$journalSummary\n' : ''}

STATISTICS:
- Total check-ins: ${weekMoods.length}
- Average mood score: ${stats['average']?.toStringAsFixed(1)}/10
- Highest mood: ${stats['highest']}/10
- Lowest mood: ${stats['lowest']}/10
- Current streak: $checkInStreak days
- Exercises completed: $exercisesCompleted

Generate a report in JSON format:
{
  "greeting": "Personalized greeting mentioning day/time",
  "summary": "2-3 sentence warm summary of the week",
  "highlights": ["2-3 positive moments or achievements"],
  "challenges": ["1-2 challenges faced, framed supportively"],
  "patterns": ["1-2 patterns noticed"],
  "moodTrend": "improving/stable/declining/variable",
  "moodTrendExplanation": "Brief explanation of the trend",
  "topStrengths": ["1-2 strengths shown this week"],
  "suggestions": ["2-3 actionable suggestions for next week"],
  "affirmation": "A warm, personalized closing affirmation",
  "weeklyQuote": "An inspiring but not cliché quote relevant to their journey"
}
''';

      final response = await _reportModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return WeeklyReport.fromJson(json, weekStart, weekEnd, stats);
      }
    } catch (e) {
      debugPrint('ReportGenerationService: Weekly report failed: $e');
    }

    return WeeklyReport.error('Unable to generate report');
  }

  /// Generate a monthly reflection report
  Future<MonthlyReport> generateMonthlyReport({
    required List<MoodEntry> moodEntries,
    List<JournalEntry>? journalEntries,
    int totalExercises = 0,
    int longestStreak = 0,
  }) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      final monthName = DateFormat.MMMM().format(monthStart);
      
      // Filter entries to this month
      final monthMoods = moodEntries.where((m) => 
        m.timestamp.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        m.timestamp.isBefore(monthEnd.add(const Duration(days: 1)))
      ).toList();

      if (monthMoods.isEmpty) {
        return MonthlyReport.noData(monthName);
      }

      final moodSummary = _buildMoodSummary(monthMoods);
      final weeklyBreakdown = _buildWeeklyBreakdown(monthMoods);
      
      final stats = _calculateMonthStats(monthMoods);

      final prompt = '''
Generate a reflective monthly mental health report.

MONTH: $monthName

MOOD DATA:
$moodSummary

WEEKLY BREAKDOWN:
$weeklyBreakdown

MONTHLY STATISTICS:
- Total check-ins: ${monthMoods.length}
- Average mood: ${stats['average']?.toStringAsFixed(1)}/10
- Best week: Week ${stats['bestWeek']}
- Most common mood: ${stats['commonCategory']}
- Longest streak: $longestStreak days
- Total exercises: $totalExercises
- Mood range: ${stats['lowest']}-${stats['highest']}/10

Generate a monthly report in JSON format:
{
  "monthSummary": "3-4 sentence reflective summary of the month",
  "growthAreas": ["2-3 areas where growth was shown"],
  "consistencyScore": 1-10 (based on check-in frequency and streaks),
  "consistencyFeedback": "Feedback on consistency",
  "emotionalRange": "Description of emotional range experienced",
  "significantPatterns": ["2-3 significant patterns observed"],
  "monthlyWins": ["3-4 wins, big or small"],
  "areasForGrowth": ["1-2 gentle suggestions for growth"],
  "monthInReview": "A paragraph-length narrative of the month's journey",
  "lookingAhead": "Encouragement and focus for the coming month",
  "personalizedInsight": "A deep, personalized insight based on the data"
}
''';

      final response = await _reportModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return MonthlyReport.fromJson(json, monthName, stats);
      }
    } catch (e) {
      debugPrint('ReportGenerationService: Monthly report failed: $e');
    }

    return MonthlyReport.error('Unable to generate report');
  }

  /// Generate a shareable summary for therapists (privacy-conscious)
  Future<TherapistSummary> generateTherapistSummary({
    required List<MoodEntry> moodEntries,
    required String periodDescription,
    List<String>? userGoals,
    List<String>? concernsToHighlight,
  }) async {
    try {
      final stats = _calculateOverallStats(moodEntries);
      final patterns = _identifyPatterns(moodEntries);

      final prompt = '''
Generate a professional summary suitable for sharing with a mental health professional.

PERIOD: $periodDescription

MOOD DATA STATISTICS:
- Total entries: ${moodEntries.length}
- Average mood: ${stats['average']?.toStringAsFixed(1)}/10
- Mood range: ${stats['lowest']}-${stats['highest']}
- Trend: ${stats['trend']}
- Most frequent mood category: ${stats['commonCategory']}

IDENTIFIED PATTERNS:
$patterns

${userGoals?.isNotEmpty == true ? 'USER-STATED GOALS:\n${userGoals!.join("\n")}\n' : ''}
${concernsToHighlight?.isNotEmpty == true ? 'USER-HIGHLIGHTED CONCERNS:\n${concernsToHighlight!.join("\n")}\n' : ''}

Generate a professional summary in JSON format:
{
  "executiveSummary": "2-3 sentence clinical summary",
  "moodOverview": {
    "averageScore": number,
    "trend": "improving/stable/declining/variable",
    "range": "description of emotional range",
    "volatility": "low/moderate/high"
  },
  "observedPatterns": ["3-4 clinically relevant patterns"],
  "strengthsIdentified": ["2-3 coping strengths observed"],
  "potentialConcerns": ["1-2 areas that may warrant professional attention"],
  "engagementMetrics": {
    "checkInFrequency": "description",
    "exerciseUsage": "description",
    "journalingFrequency": "description"
  },
  "suggestedDiscussionTopics": ["2-3 topics for therapeutic exploration"],
  "disclaimer": "Standard disclaimer about app limitations"
}
''';

      final response = await _reportModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return TherapistSummary.fromJson(json, periodDescription);
      }
    } catch (e) {
      debugPrint('ReportGenerationService: Therapist summary failed: $e');
    }

    return TherapistSummary.error('Unable to generate summary');
  }

  /// Export report as shareable text
  Future<void> shareReport({
    required String reportText,
    required String reportTitle,
  }) async {
    await Share.share(
      reportText,
      subject: reportTitle,
    );
  }

  /// Export report as file
  Future<String?> exportReportToFile({
    required String reportContent,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');
      await file.writeAsString(reportContent);
      return file.path;
    } catch (e) {
      debugPrint('ReportGenerationService: Export failed: $e');
      return null;
    }
  }

  // ==================== Helper Methods ====================

  String _buildMoodSummary(List<MoodEntry> moods) {
    final buffer = StringBuffer();
    for (final mood in moods.take(30)) {
      buffer.writeln(
        '${_formatDate(mood.timestamp)}: ${mood.category.name} (${mood.intensity.value}/10)'
        '${mood.triggers?.isNotEmpty == true ? ' [Triggers: ${mood.triggers!.join(", ")}]' : ''}'
      );
    }
    return buffer.toString();
  }

  String _buildJournalSummary(List<JournalEntry> journals) {
    if (journals.isEmpty) return '';
    
    final themes = <String>[];
    for (final journal in journals.take(10)) {
      if (journal.themes?.isNotEmpty == true) {
        themes.addAll(journal.themes!);
      }
    }
    
    if (themes.isEmpty) return '';
    
    final themeCounts = <String, int>{};
    for (final theme in themes) {
      themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;
    }
    
    final sortedThemes = themeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return 'Common themes: ${sortedThemes.take(5).map((e) => e.key).join(", ")}';
  }

  String _buildWeeklyBreakdown(List<MoodEntry> moods) {
    final weeklyMoods = <int, List<int>>{};
    
    for (final mood in moods) {
      final weekOfMonth = ((mood.timestamp.day - 1) ~/ 7) + 1;
      weeklyMoods.putIfAbsent(weekOfMonth, () => []).add(mood.intensity.value);
    }
    
    final buffer = StringBuffer();
    weeklyMoods.forEach((week, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      buffer.writeln('Week $week: ${avg.toStringAsFixed(1)} avg (${scores.length} entries)');
    });
    
    return buffer.toString();
  }

  Map<String, dynamic> _calculateWeekStats(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return {'average': 0.0, 'highest': 0, 'lowest': 0};
    }
    
    final scores = moods.map((m) => m.intensity.value).toList();
    return {
      'average': scores.reduce((a, b) => a + b) / scores.length,
      'highest': scores.reduce((a, b) => a > b ? a : b),
      'lowest': scores.reduce((a, b) => a < b ? a : b),
    };
  }

  Map<String, dynamic> _calculateMonthStats(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return {
        'average': 0.0,
        'highest': 0,
        'lowest': 0,
        'bestWeek': 1,
        'commonCategory': 'unknown',
      };
    }
    
    final scores = moods.map((m) => m.intensity.value).toList();
    
    // Find best week
    final weeklyAvgs = <int, double>{};
    for (final mood in moods) {
      final week = ((mood.timestamp.day - 1) ~/ 7) + 1;
      weeklyAvgs.putIfAbsent(week, () => 0);
    }
    
    for (final mood in moods) {
      final week = ((mood.timestamp.day - 1) ~/ 7) + 1;
      final weekMoods = moods.where((m) => 
        ((m.timestamp.day - 1) ~/ 7) + 1 == week
      ).toList();
      weeklyAvgs[week] = weekMoods.map((m) => m.intensity.value).reduce((a, b) => a + b) / weekMoods.length;
    }
    
    int bestWeek = 1;
    double bestAvg = 0;
    weeklyAvgs.forEach((week, avg) {
      if (avg > bestAvg) {
        bestAvg = avg;
        bestWeek = week;
      }
    });
    
    // Most common category
    final categoryCounts = <MoodCategory, int>{};
    for (final mood in moods) {
      categoryCounts[mood.category] = (categoryCounts[mood.category] ?? 0) + 1;
    }
    final commonCategory = categoryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .name;
    
    return {
      'average': scores.reduce((a, b) => a + b) / scores.length,
      'highest': scores.reduce((a, b) => a > b ? a : b),
      'lowest': scores.reduce((a, b) => a < b ? a : b),
      'bestWeek': bestWeek,
      'commonCategory': commonCategory,
    };
  }

  Map<String, dynamic> _calculateOverallStats(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return {
        'average': 0.0,
        'highest': 0,
        'lowest': 0,
        'trend': 'insufficient data',
        'commonCategory': 'unknown',
      };
    }
    
    final scores = moods.map((m) => m.intensity.value).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;
    
    // Trend calculation
    String trend = 'stable';
    if (moods.length >= 14) {
      final recentAvg = scores.take(7).reduce((a, b) => a + b) / 7;
      final previousAvg = scores.skip(7).take(7).reduce((a, b) => a + b) / 7;
      if (recentAvg > previousAvg + 0.5) {
        trend = 'improving';
      } else if (recentAvg < previousAvg - 0.5) trend = 'declining';
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
    
    return {
      'average': average,
      'highest': scores.reduce((a, b) => a > b ? a : b),
      'lowest': scores.reduce((a, b) => a < b ? a : b),
      'trend': trend,
      'commonCategory': commonCategory,
    };
  }

  String _identifyPatterns(List<MoodEntry> moods) {
    final patterns = <String>[];
    
    // Time of day patterns
    final morningMoods = moods.where((m) => m.timestamp.hour >= 5 && m.timestamp.hour < 12);
    final eveningMoods = moods.where((m) => m.timestamp.hour >= 17 && m.timestamp.hour < 22);
    
    if (morningMoods.isNotEmpty && eveningMoods.isNotEmpty) {
      final morningAvg = morningMoods.map((m) => m.intensity.value).reduce((a, b) => a + b) / morningMoods.length;
      final eveningAvg = eveningMoods.map((m) => m.intensity.value).reduce((a, b) => a + b) / eveningMoods.length;
      
      if (morningAvg > eveningAvg + 1) {
        patterns.add('Mood tends to be better in mornings');
      } else if (eveningAvg > morningAvg + 1) {
        patterns.add('Mood tends to improve throughout the day');
      }
    }
    
    // Day of week patterns
    final weekdayMoods = moods.where((m) => m.timestamp.weekday <= 5);
    final weekendMoods = moods.where((m) => m.timestamp.weekday > 5);
    
    if (weekdayMoods.isNotEmpty && weekendMoods.isNotEmpty) {
      final weekdayAvg = weekdayMoods.map((m) => m.intensity.value).reduce((a, b) => a + b) / weekdayMoods.length;
      final weekendAvg = weekendMoods.map((m) => m.intensity.value).reduce((a, b) => a + b) / weekendMoods.length;
      
      if (weekendAvg > weekdayAvg + 1) {
        patterns.add('Mood is generally better on weekends');
      } else if (weekdayAvg > weekendAvg + 1) {
        patterns.add('Mood is generally better on weekdays');
      }
    }
    
    // Trigger patterns
    final allTriggers = moods.expand((m) => m.triggers ?? <String>[]).toList();
    if (allTriggers.isNotEmpty) {
      final triggerCounts = <String, int>{};
      for (final trigger in allTriggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
      final topTriggers = triggerCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (topTriggers.isNotEmpty) {
        patterns.add('Most common triggers: ${topTriggers.take(3).map((e) => e.key).join(", ")}');
      }
    }
    
    return patterns.isEmpty ? 'No significant patterns identified yet' : patterns.join('\n');
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}

// ==================== Data Classes ====================

/// Weekly report data
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final String greeting;
  final String summary;
  final List<String> highlights;
  final List<String> challenges;
  final List<String> patterns;
  final String moodTrend;
  final String moodTrendExplanation;
  final List<String> topStrengths;
  final List<String> suggestions;
  final String affirmation;
  final String weeklyQuote;
  final Map<String, dynamic> stats;
  final bool hasError;
  final String? errorMessage;

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.greeting,
    required this.summary,
    this.highlights = const [],
    this.challenges = const [],
    this.patterns = const [],
    required this.moodTrend,
    required this.moodTrendExplanation,
    this.topStrengths = const [],
    this.suggestions = const [],
    required this.affirmation,
    this.weeklyQuote = '',
    this.stats = const {},
    this.hasError = false,
    this.errorMessage,
  });

  factory WeeklyReport.fromJson(
    Map<String, dynamic> json,
    DateTime weekStart,
    DateTime weekEnd,
    Map<String, dynamic> stats,
  ) {
    return WeeklyReport(
      weekStart: weekStart,
      weekEnd: weekEnd,
      greeting: json['greeting'] as String? ?? 'Hello!',
      summary: json['summary'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)?.cast<String>() ?? [],
      challenges: (json['challenges'] as List<dynamic>?)?.cast<String>() ?? [],
      patterns: (json['patterns'] as List<dynamic>?)?.cast<String>() ?? [],
      moodTrend: json['moodTrend'] as String? ?? 'stable',
      moodTrendExplanation: json['moodTrendExplanation'] as String? ?? '',
      topStrengths: (json['topStrengths'] as List<dynamic>?)?.cast<String>() ?? [],
      suggestions: (json['suggestions'] as List<dynamic>?)?.cast<String>() ?? [],
      affirmation: json['affirmation'] as String? ?? '',
      weeklyQuote: json['weeklyQuote'] as String? ?? '',
      stats: stats,
    );
  }

  factory WeeklyReport.noData(DateTime weekStart, DateTime weekEnd) {
    return WeeklyReport(
      weekStart: weekStart,
      weekEnd: weekEnd,
      greeting: 'Hi there!',
      summary: "You haven't logged any moods this week yet. Start tracking to see your personalized weekly report!",
      moodTrend: 'unknown',
      moodTrendExplanation: '',
      affirmation: 'Every check-in is a step toward understanding yourself better.',
      hasError: true,
      errorMessage: 'No data for this week',
    );
  }

  factory WeeklyReport.error(String message) {
    return WeeklyReport(
      weekStart: DateTime.now(),
      weekEnd: DateTime.now(),
      greeting: '',
      summary: message,
      moodTrend: 'unknown',
      moodTrendExplanation: '',
      affirmation: '',
      hasError: true,
      errorMessage: message,
    );
  }

  /// Convert to shareable text format
  String toShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Weekly Mental Wellness Report');
    buffer.writeln('${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}');
    buffer.writeln('');
    buffer.writeln(greeting);
    buffer.writeln('');
    buffer.writeln('📝 Summary');
    buffer.writeln(summary);
    buffer.writeln('');
    
    if (highlights.isNotEmpty) {
      buffer.writeln('✨ Highlights');
      for (final h in highlights) {
        buffer.writeln('• $h');
      }
      buffer.writeln('');
    }
    
    if (patterns.isNotEmpty) {
      buffer.writeln('🔍 Patterns Noticed');
      for (final p in patterns) {
        buffer.writeln('• $p');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('📈 Mood Trend: $moodTrend');
    buffer.writeln(moodTrendExplanation);
    buffer.writeln('');
    
    if (suggestions.isNotEmpty) {
      buffer.writeln('💡 Suggestions for Next Week');
      for (final s in suggestions) {
        buffer.writeln('• $s');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('💙 $affirmation');
    
    if (weeklyQuote.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('"$weeklyQuote"');
    }
    
    return buffer.toString();
  }
}

/// Monthly report data
class MonthlyReport {
  final String monthName;
  final String monthSummary;
  final List<String> growthAreas;
  final int consistencyScore;
  final String consistencyFeedback;
  final String emotionalRange;
  final List<String> significantPatterns;
  final List<String> monthlyWins;
  final List<String> areasForGrowth;
  final String monthInReview;
  final String lookingAhead;
  final String personalizedInsight;
  final Map<String, dynamic> stats;
  final bool hasError;
  final String? errorMessage;

  MonthlyReport({
    required this.monthName,
    required this.monthSummary,
    this.growthAreas = const [],
    required this.consistencyScore,
    required this.consistencyFeedback,
    required this.emotionalRange,
    this.significantPatterns = const [],
    this.monthlyWins = const [],
    this.areasForGrowth = const [],
    required this.monthInReview,
    required this.lookingAhead,
    required this.personalizedInsight,
    this.stats = const {},
    this.hasError = false,
    this.errorMessage,
  });

  factory MonthlyReport.fromJson(
    Map<String, dynamic> json,
    String monthName,
    Map<String, dynamic> stats,
  ) {
    return MonthlyReport(
      monthName: monthName,
      monthSummary: json['monthSummary'] as String? ?? '',
      growthAreas: (json['growthAreas'] as List<dynamic>?)?.cast<String>() ?? [],
      consistencyScore: json['consistencyScore'] as int? ?? 5,
      consistencyFeedback: json['consistencyFeedback'] as String? ?? '',
      emotionalRange: json['emotionalRange'] as String? ?? '',
      significantPatterns: (json['significantPatterns'] as List<dynamic>?)?.cast<String>() ?? [],
      monthlyWins: (json['monthlyWins'] as List<dynamic>?)?.cast<String>() ?? [],
      areasForGrowth: (json['areasForGrowth'] as List<dynamic>?)?.cast<String>() ?? [],
      monthInReview: json['monthInReview'] as String? ?? '',
      lookingAhead: json['lookingAhead'] as String? ?? '',
      personalizedInsight: json['personalizedInsight'] as String? ?? '',
      stats: stats,
    );
  }

  factory MonthlyReport.noData(String monthName) {
    return MonthlyReport(
      monthName: monthName,
      monthSummary: "You haven't logged any moods this month yet.",
      consistencyScore: 0,
      consistencyFeedback: 'Start tracking to build your monthly insights!',
      emotionalRange: 'Unknown',
      monthInReview: '',
      lookingAhead: 'Track your moods daily to unlock personalized monthly reports.',
      personalizedInsight: '',
      hasError: true,
      errorMessage: 'No data for this month',
    );
  }

  factory MonthlyReport.error(String message) {
    return MonthlyReport(
      monthName: '',
      monthSummary: message,
      consistencyScore: 0,
      consistencyFeedback: '',
      emotionalRange: '',
      monthInReview: '',
      lookingAhead: '',
      personalizedInsight: '',
      hasError: true,
      errorMessage: message,
    );
  }
}

/// Therapist-shareable summary
class TherapistSummary {
  final String periodDescription;
  final String executiveSummary;
  final MoodOverview moodOverview;
  final List<String> observedPatterns;
  final List<String> strengthsIdentified;
  final List<String> potentialConcerns;
  final EngagementMetrics engagementMetrics;
  final List<String> suggestedDiscussionTopics;
  final String disclaimer;
  final bool hasError;
  final String? errorMessage;

  TherapistSummary({
    required this.periodDescription,
    required this.executiveSummary,
    required this.moodOverview,
    this.observedPatterns = const [],
    this.strengthsIdentified = const [],
    this.potentialConcerns = const [],
    required this.engagementMetrics,
    this.suggestedDiscussionTopics = const [],
    required this.disclaimer,
    this.hasError = false,
    this.errorMessage,
  });

  factory TherapistSummary.fromJson(Map<String, dynamic> json, String period) {
    final moodJson = json['moodOverview'] as Map<String, dynamic>? ?? {};
    final engagementJson = json['engagementMetrics'] as Map<String, dynamic>? ?? {};
    
    return TherapistSummary(
      periodDescription: period,
      executiveSummary: json['executiveSummary'] as String? ?? '',
      moodOverview: MoodOverview.fromJson(moodJson),
      observedPatterns: (json['observedPatterns'] as List<dynamic>?)?.cast<String>() ?? [],
      strengthsIdentified: (json['strengthsIdentified'] as List<dynamic>?)?.cast<String>() ?? [],
      potentialConcerns: (json['potentialConcerns'] as List<dynamic>?)?.cast<String>() ?? [],
      engagementMetrics: EngagementMetrics.fromJson(engagementJson),
      suggestedDiscussionTopics: (json['suggestedDiscussionTopics'] as List<dynamic>?)?.cast<String>() ?? [],
      disclaimer: json['disclaimer'] as String? ?? 
          'This summary is generated from self-reported data in a wellness app and should not be used as a diagnostic tool.',
    );
  }

  factory TherapistSummary.error(String message) {
    return TherapistSummary(
      periodDescription: '',
      executiveSummary: message,
      moodOverview: MoodOverview.empty(),
      engagementMetrics: EngagementMetrics.empty(),
      disclaimer: '',
      hasError: true,
      errorMessage: message,
    );
  }

  /// Convert to professional text format
  String toProfessionalText() {
    final buffer = StringBuffer();
    buffer.writeln('MENTAL WELLNESS APP - CLIENT SUMMARY');
    buffer.writeln('Period: $periodDescription');
    buffer.writeln('Generated: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('EXECUTIVE SUMMARY');
    buffer.writeln(executiveSummary);
    buffer.writeln('');
    buffer.writeln('MOOD OVERVIEW');
    buffer.writeln('Average Score: ${moodOverview.averageScore}/10');
    buffer.writeln('Trend: ${moodOverview.trend}');
    buffer.writeln('Range: ${moodOverview.range}');
    buffer.writeln('Volatility: ${moodOverview.volatility}');
    buffer.writeln('');
    
    if (observedPatterns.isNotEmpty) {
      buffer.writeln('OBSERVED PATTERNS');
      for (final p in observedPatterns) {
        buffer.writeln('• $p');
      }
      buffer.writeln('');
    }
    
    if (strengthsIdentified.isNotEmpty) {
      buffer.writeln('STRENGTHS IDENTIFIED');
      for (final s in strengthsIdentified) {
        buffer.writeln('• $s');
      }
      buffer.writeln('');
    }
    
    if (potentialConcerns.isNotEmpty) {
      buffer.writeln('POTENTIAL CONCERNS');
      for (final c in potentialConcerns) {
        buffer.writeln('• $c');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('ENGAGEMENT METRICS');
    buffer.writeln('Check-in Frequency: ${engagementMetrics.checkInFrequency}');
    buffer.writeln('Exercise Usage: ${engagementMetrics.exerciseUsage}');
    buffer.writeln('Journaling: ${engagementMetrics.journalingFrequency}');
    buffer.writeln('');
    
    if (suggestedDiscussionTopics.isNotEmpty) {
      buffer.writeln('SUGGESTED DISCUSSION TOPICS');
      for (final t in suggestedDiscussionTopics) {
        buffer.writeln('• $t');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('---');
    buffer.writeln('DISCLAIMER: $disclaimer');
    
    return buffer.toString();
  }
}

class MoodOverview {
  final double averageScore;
  final String trend;
  final String range;
  final String volatility;

  MoodOverview({
    required this.averageScore,
    required this.trend,
    required this.range,
    required this.volatility,
  });

  factory MoodOverview.fromJson(Map<String, dynamic> json) {
    return MoodOverview(
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      trend: json['trend'] as String? ?? 'unknown',
      range: json['range'] as String? ?? 'unknown',
      volatility: json['volatility'] as String? ?? 'unknown',
    );
  }

  factory MoodOverview.empty() {
    return MoodOverview(
      averageScore: 0,
      trend: 'unknown',
      range: 'unknown',
      volatility: 'unknown',
    );
  }
}

class EngagementMetrics {
  final String checkInFrequency;
  final String exerciseUsage;
  final String journalingFrequency;

  EngagementMetrics({
    required this.checkInFrequency,
    required this.exerciseUsage,
    required this.journalingFrequency,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) {
    return EngagementMetrics(
      checkInFrequency: json['checkInFrequency'] as String? ?? 'unknown',
      exerciseUsage: json['exerciseUsage'] as String? ?? 'unknown',
      journalingFrequency: json['journalingFrequency'] as String? ?? 'unknown',
    );
  }

  factory EngagementMetrics.empty() {
    return EngagementMetrics(
      checkInFrequency: 'unknown',
      exerciseUsage: 'unknown',
      journalingFrequency: 'unknown',
    );
  }
}
