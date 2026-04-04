import 'package:uuid/uuid.dart';

/// Type of journal entry
enum JournalEntryType {
  free('Free Writing', 'Write freely about anything on your mind'),
  prompted('AI Prompted', 'Guided writing with AI-generated prompts'),
  gratitude('Gratitude', 'Focus on things you\'re thankful for'),
  reflection('Reflection', 'Reflect on experiences and growth'),
  goalSetting('Goal Setting', 'Set and explore your goals'),
  emotionExplorer('Emotion Explorer', 'Deep dive into your feelings');

  final String label;
  final String description;
  const JournalEntryType(this.label, this.description);
}

/// Model for a journal entry
class JournalEntry {
  final String id;
  final String? prompt;
  final String content;
  final String? richTextDelta; // Quill Delta JSON for rich text formatting
  final JournalEntryType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? aiAnalysis;
  final List<String>? themes;
  final List<String>? emotions;
  final int? derivedMoodScore;
  final String? linkedMoodEntryId;
  final int wordCount;
  final int? writingDurationSeconds;

  JournalEntry({
    String? id,
    this.prompt,
    required this.content,
    this.richTextDelta,
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.aiAnalysis,
    this.themes,
    this.emotions,
    this.derivedMoodScore,
    this.linkedMoodEntryId,
    int? wordCount,
    this.writingDurationSeconds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        wordCount = wordCount ?? 
            content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  /// Check if entry has rich text formatting
  bool get hasRichText => richTextDelta != null && richTextDelta!.isNotEmpty;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'content': content,
        'richTextDelta': richTextDelta,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'aiAnalysis': aiAnalysis,
        'themes': themes,
        'emotions': emotions,
        'derivedMoodScore': derivedMoodScore,
        'linkedMoodEntryId': linkedMoodEntryId,
        'wordCount': wordCount,
        'writingDurationSeconds': writingDurationSeconds,
      };

  /// Create from JSON
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      prompt: json['prompt'] as String?,
      content: json['content'] as String,
      richTextDelta: json['richTextDelta'] as String?,
      type: JournalEntryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => JournalEntryType.free,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      aiAnalysis: json['aiAnalysis'] as String?,
      themes: (json['themes'] as List<dynamic>?)?.cast<String>(),
      emotions: (json['emotions'] as List<dynamic>?)?.cast<String>(),
      derivedMoodScore: json['derivedMoodScore'] as int?,
      linkedMoodEntryId: json['linkedMoodEntryId'] as String?,
      wordCount: json['wordCount'] as int?,
      writingDurationSeconds: json['writingDurationSeconds'] as int?,
    );
  }

  JournalEntry copyWith({
    String? id,
    String? prompt,
    String? content,
    String? richTextDelta,
    JournalEntryType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? aiAnalysis,
    List<String>? themes,
    List<String>? emotions,
    int? derivedMoodScore,
    String? linkedMoodEntryId,
    int? wordCount,
    int? writingDurationSeconds,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      content: content ?? this.content,
      richTextDelta: richTextDelta ?? this.richTextDelta,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      themes: themes ?? this.themes,
      emotions: emotions ?? this.emotions,
      derivedMoodScore: derivedMoodScore ?? this.derivedMoodScore,
      linkedMoodEntryId: linkedMoodEntryId ?? this.linkedMoodEntryId,
      wordCount: wordCount ?? this.wordCount,
      writingDurationSeconds: writingDurationSeconds ?? this.writingDurationSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// AI-generated journal prompt
class JournalPrompt {
  final String id;
  final String prompt;
  final JournalEntryType type;
  final String? category; // e.g., 'self-discovery', 'coping', 'growth'
  final bool isUsed;
  final DateTime generatedAt;

  JournalPrompt({
    String? id,
    required this.prompt,
    required this.type,
    this.category,
    this.isUsed = false,
    DateTime? generatedAt,
  })  : id = id ?? const Uuid().v4(),
        generatedAt = generatedAt ?? DateTime.now();

  JournalPrompt copyWith({
    String? id,
    String? prompt,
    JournalEntryType? type,
    String? category,
    bool? isUsed,
    DateTime? generatedAt,
  }) {
    return JournalPrompt(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      category: category ?? this.category,
      isUsed: isUsed ?? this.isUsed,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

/// Journal analysis result from AI
class JournalAnalysis {
  final String entryId;
  final String summary;
  final List<String> themes;
  final List<String> emotions;
  final int moodScore;
  final String? insight;
  final List<String>? suggestedActions;
  final Map<String, dynamic>? patterns;

  JournalAnalysis({
    required this.entryId,
    required this.summary,
    required this.themes,
    required this.emotions,
    required this.moodScore,
    this.insight,
    this.suggestedActions,
    this.patterns,
  });

  factory JournalAnalysis.fromJson(Map<String, dynamic> json) {
    return JournalAnalysis(
      entryId: json['entryId'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      themes: (json['themes'] as List<dynamic>?)?.cast<String>() ?? [],
      emotions: (json['emotions'] as List<dynamic>?)?.cast<String>() ?? [],
      moodScore: json['moodScore'] as int? ?? 5,
      insight: json['insight'] as String?,
      suggestedActions: (json['suggestedActions'] as List<dynamic>?)?.cast<String>(),
      patterns: json['patterns'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'summary': summary,
        'themes': themes,
        'emotions': emotions,
        'moodScore': moodScore,
        'insight': insight,
        'suggestedActions': suggestedActions,
        'patterns': patterns,
      };
}
