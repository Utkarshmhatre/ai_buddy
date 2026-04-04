import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Beta testing feedback and analytics service
/// Collects user feedback and usage patterns (privacy-respecting)
class BetaFeedbackService {
  static const String _feedbackKey = 'beta_feedback';
  static const String _analyticsKey = 'beta_analytics';
  static const String _sessionStartKey = 'session_start';
  
  final SharedPreferences _prefs;
  DateTime? _sessionStart;

  BetaFeedbackService(this._prefs);

  static Future<BetaFeedbackService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return BetaFeedbackService(prefs);
  }

  // ============== SESSION TRACKING ==============

  /// Start a new session
  void startSession() {
    _sessionStart = DateTime.now();
    _prefs.setString(_sessionStartKey, _sessionStart!.toIso8601String());
  }

  /// End current session and record duration
  Future<void> endSession() async {
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!);
      await _recordAnalytics(AnalyticsEvent(
        type: AnalyticsEventType.sessionEnd,
        timestamp: DateTime.now(),
        data: {'duration_minutes': duration.inMinutes},
      ));
    }
  }

  // ============== FEEDBACK COLLECTION ==============

  /// Submit user feedback
  Future<void> submitFeedback(UserFeedback feedback) async {
    final feedbackList = await _getFeedbackList();
    feedbackList.add(feedback);
    
    await _prefs.setString(
      _feedbackKey,
      jsonEncode(feedbackList.map((f) => f.toJson()).toList()),
    );

    // Also record as analytics event
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.feedbackSubmitted,
      timestamp: DateTime.now(),
      data: {
        'rating': feedback.rating,
        'category': feedback.category.name,
      },
    ));
  }

  /// Get all feedback (for export)
  Future<List<UserFeedback>> _getFeedbackList() async {
    final stored = _prefs.getString(_feedbackKey);
    if (stored == null) return [];
    
    final list = jsonDecode(stored) as List;
    return list.map((j) => UserFeedback.fromJson(j)).toList();
  }

  // ============== ANALYTICS (PRIVACY-FIRST) ==============

  /// Record analytics event (no PII)
  Future<void> _recordAnalytics(AnalyticsEvent event) async {
    final events = await _getAnalyticsList();
    events.add(event);
    
    // Keep only last 100 events to limit storage
    final trimmedEvents = events.length > 100 
        ? events.sublist(events.length - 100) 
        : events;
    
    await _prefs.setString(
      _analyticsKey,
      jsonEncode(trimmedEvents.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<AnalyticsEvent>> _getAnalyticsList() async {
    final stored = _prefs.getString(_analyticsKey);
    if (stored == null) return [];
    
    final list = jsonDecode(stored) as List;
    return list.map((j) => AnalyticsEvent.fromJson(j)).toList();
  }

  /// Track feature usage
  Future<void> trackFeatureUsed(String featureName) async {
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.featureUsed,
      timestamp: DateTime.now(),
      data: {'feature': featureName},
    ));
  }

  /// Track mood check-in
  Future<void> trackMoodCheckIn(int moodScore) async {
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.moodCheckIn,
      timestamp: DateTime.now(),
      data: {'score': moodScore},
    ));
  }

  /// Track chat interaction (no content, just count)
  Future<void> trackChatInteraction() async {
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.chatMessage,
      timestamp: DateTime.now(),
    ));
  }

  /// Track crisis resource access
  Future<void> trackCrisisResourceAccess(String resourceType) async {
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.crisisResourceAccess,
      timestamp: DateTime.now(),
      data: {'resource': resourceType},
    ));
  }

  /// Track journal entry (no content)
  Future<void> trackJournalEntry(String entryType) async {
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.journalEntry,
      timestamp: DateTime.now(),
      data: {'type': entryType},
    ));
  }

  /// Track exercise completion
  Future<void> trackExerciseCompleted(String exerciseType, int durationSeconds) async {
    await _recordAnalytics(AnalyticsEvent(
      type: AnalyticsEventType.exerciseCompleted,
      timestamp: DateTime.now(),
      data: {
        'type': exerciseType,
        'duration_seconds': durationSeconds,
      },
    ));
  }

  // ============== REPORTING ==============

  /// Generate anonymous usage report for beta testing
  Future<BetaUsageReport> generateUsageReport() async {
    final events = await _getAnalyticsList();
    final feedback = await _getFeedbackList();
    
    // Calculate metrics
    final sessionEvents = events.where((e) => e.type == AnalyticsEventType.sessionEnd);
    final totalSessionMinutes = sessionEvents.fold<int>(
      0, 
      (sum, e) => sum + ((e.data?['duration_minutes'] as int?) ?? 0),
    );
    
    final chatCount = events.where((e) => e.type == AnalyticsEventType.chatMessage).length;
    final journalCount = events.where((e) => e.type == AnalyticsEventType.journalEntry).length;
    final moodCheckIns = events.where((e) => e.type == AnalyticsEventType.moodCheckIn).length;
    final exerciseCount = events.where((e) => e.type == AnalyticsEventType.exerciseCompleted).length;
    final crisisAccess = events.where((e) => e.type == AnalyticsEventType.crisisResourceAccess).length;
    
    // Feature usage breakdown
    final featureUsage = <String, int>{};
    for (final event in events.where((e) => e.type == AnalyticsEventType.featureUsed)) {
      final feature = event.data?['feature'] as String? ?? 'unknown';
      featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
    }
    
    // Average feedback rating
    final ratings = feedback.map((f) => f.rating).toList();
    final avgRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    
    return BetaUsageReport(
      generatedAt: DateTime.now(),
      totalSessions: sessionEvents.length,
      totalSessionMinutes: totalSessionMinutes,
      chatInteractions: chatCount,
      journalEntries: journalCount,
      moodCheckIns: moodCheckIns,
      exercisesCompleted: exerciseCount,
      crisisResourceAccess: crisisAccess,
      featureUsage: featureUsage,
      averageFeedbackRating: avgRating,
      feedbackCount: feedback.length,
    );
  }

  /// Clear all beta testing data
  Future<void> clearAllData() async {
    await _prefs.remove(_feedbackKey);
    await _prefs.remove(_analyticsKey);
    await _prefs.remove(_sessionStartKey);
  }
}

// ============== DATA MODELS ==============

/// User feedback entry
class UserFeedback {
  final String id;
  final DateTime timestamp;
  final int rating; // 1-5 stars
  final FeedbackCategory category;
  final String? comment;
  final String? featureRelated;

  UserFeedback({
    String? id,
    DateTime? timestamp,
    required this.rating,
    required this.category,
    this.comment,
    this.featureRelated,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'rating': rating,
    'category': category.name,
    'comment': comment,
    'featureRelated': featureRelated,
  };

  factory UserFeedback.fromJson(Map<String, dynamic> json) => UserFeedback(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    rating: json['rating'],
    category: FeedbackCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => FeedbackCategory.general,
    ),
    comment: json['comment'],
    featureRelated: json['featureRelated'],
  );
}

/// Feedback categories
enum FeedbackCategory {
  general,
  chat,
  journal,
  mood,
  exercises,
  accessibility,
  crisis,
  bug,
  feature,
  design,
}

/// Analytics event types
enum AnalyticsEventType {
  sessionEnd,
  feedbackSubmitted,
  featureUsed,
  moodCheckIn,
  chatMessage,
  crisisResourceAccess,
  journalEntry,
  exerciseCompleted,
}

/// Analytics event
class AnalyticsEvent {
  final AnalyticsEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  AnalyticsEvent({
    required this.type,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
    type: AnalyticsEventType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => AnalyticsEventType.featureUsed,
    ),
    timestamp: DateTime.parse(json['timestamp']),
    data: json['data'],
  );
}

/// Beta usage report
class BetaUsageReport {
  final DateTime generatedAt;
  final int totalSessions;
  final int totalSessionMinutes;
  final int chatInteractions;
  final int journalEntries;
  final int moodCheckIns;
  final int exercisesCompleted;
  final int crisisResourceAccess;
  final Map<String, int> featureUsage;
  final double averageFeedbackRating;
  final int feedbackCount;

  BetaUsageReport({
    required this.generatedAt,
    required this.totalSessions,
    required this.totalSessionMinutes,
    required this.chatInteractions,
    required this.journalEntries,
    required this.moodCheckIns,
    required this.exercisesCompleted,
    required this.crisisResourceAccess,
    required this.featureUsage,
    required this.averageFeedbackRating,
    required this.feedbackCount,
  });

  Map<String, dynamic> toJson() => {
    'generatedAt': generatedAt.toIso8601String(),
    'totalSessions': totalSessions,
    'totalSessionMinutes': totalSessionMinutes,
    'chatInteractions': chatInteractions,
    'journalEntries': journalEntries,
    'moodCheckIns': moodCheckIns,
    'exercisesCompleted': exercisesCompleted,
    'crisisResourceAccess': crisisResourceAccess,
    'featureUsage': featureUsage,
    'averageFeedbackRating': averageFeedbackRating,
    'feedbackCount': feedbackCount,
  };

  String toReadableReport() {
    return '''
╔══════════════════════════════════════════════════════╗
║           AI BUDDY BETA USAGE REPORT                 ║
╠══════════════════════════════════════════════════════╣
║ Generated: ${generatedAt.toString().substring(0, 16)}
╠══════════════════════════════════════════════════════╣
║ SESSION METRICS
║   • Total Sessions: $totalSessions
║   • Total Time: $totalSessionMinutes minutes
║   • Avg Session: ${totalSessions > 0 ? (totalSessionMinutes / totalSessions).toStringAsFixed(1) : 0} min
╠══════════════════════════════════════════════════════╣
║ FEATURE USAGE
║   • Chat Interactions: $chatInteractions
║   • Journal Entries: $journalEntries
║   • Mood Check-ins: $moodCheckIns
║   • Exercises Completed: $exercisesCompleted
║   • Crisis Resources: $crisisResourceAccess
╠══════════════════════════════════════════════════════╣
║ FEEDBACK
║   • Responses: $feedbackCount
║   • Average Rating: ${averageFeedbackRating.toStringAsFixed(1)}/5.0
╚══════════════════════════════════════════════════════╝
''';
  }
}
