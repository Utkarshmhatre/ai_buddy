import 'package:uuid/uuid.dart';

/// Mood intensity scale (1-5)
enum MoodIntensity {
  veryLow(1, 'Very Low'),
  low(2, 'Low'),
  neutral(3, 'Neutral'),
  high(4, 'High'),
  veryHigh(5, 'Very High');

  final int value;
  final String label;
  const MoodIntensity(this.value, this.label);
}

/// Predefined mood categories for quick selection
enum MoodCategory {
  happy('😊', 'Happy', [0xFF82C785]),
  calm('😌', 'Calm', [0xFF5DADE2]),
  grateful('🙏', 'Grateful', [0xFFB19CD9]),
  anxious('😰', 'Anxious', [0xFFF5B041]),
  sad('😢', 'Sad', [0xFF7FB3D5]),
  angry('😤', 'Angry', [0xFFE57373]),
  stressed('😫', 'Stressed', [0xFFE59866]),
  hopeful('🌟', 'Hopeful', [0xFFAED6F1]),
  loved('🥰', 'Loved', [0xFFFFABAB]),
  lonely('😔', 'Lonely', [0xFF85929E]),
  confused('🤔', 'Confused', [0xFFD7DBDD]),
  energetic('⚡', 'Energetic', [0xFFF9E79F]);

  final String emoji;
  final String label;
  final List<int> colors;
  const MoodCategory(this.emoji, this.label, this.colors);
}

/// Individual mood entry with AI analysis
class MoodEntry {
  final String id;
  final MoodCategory category;
  final MoodIntensity intensity;
  final String? notes;
  final List<String>? triggers;
  final List<String>? activities;
  final DateTime timestamp;
  final String? aiInsight; // AI-generated insight about the mood
  final Map<String, dynamic>? metadata;

  MoodEntry({
    String? id,
    required this.category,
    required this.intensity,
    this.notes,
    this.triggers,
    this.activities,
    DateTime? timestamp,
    this.aiInsight,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'intensity': intensity.name,
        'notes': notes,
        'triggers': triggers,
        'activities': activities,
        'timestamp': timestamp.toIso8601String(),
        'aiInsight': aiInsight,
        'metadata': metadata,
      };

  /// Create from JSON
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      category: MoodCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MoodCategory.calm,
      ),
      intensity: MoodIntensity.values.firstWhere(
        (e) => e.name == json['intensity'],
        orElse: () => MoodIntensity.neutral,
      ),
      notes: json['notes'] as String?,
      triggers: (json['triggers'] as List<dynamic>?)?.cast<String>(),
      activities: (json['activities'] as List<dynamic>?)?.cast<String>(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      aiInsight: json['aiInsight'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  MoodEntry copyWith({
    String? id,
    MoodCategory? category,
    MoodIntensity? intensity,
    String? notes,
    List<String>? triggers,
    List<String>? activities,
    DateTime? timestamp,
    String? aiInsight,
    Map<String, dynamic>? metadata,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      triggers: triggers ?? this.triggers,
      activities: activities ?? this.activities,
      timestamp: timestamp ?? this.timestamp,
      aiInsight: aiInsight ?? this.aiInsight,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get mood score for analytics (1-5 scale, higher is more positive)
  int get moodScore {
    const positiveCategories = [
      MoodCategory.happy,
      MoodCategory.calm,
      MoodCategory.grateful,
      MoodCategory.hopeful,
      MoodCategory.loved,
      MoodCategory.energetic,
    ];

    if (positiveCategories.contains(category)) {
      return intensity.value;
    } else {
      return 6 - intensity.value; // Invert for negative moods
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
