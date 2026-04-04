import 'package:isar/isar.dart';

part 'journal_entry_entity.g.dart';

/// Entity for storing journal entries with AI-generated prompts and analysis
@collection
class JournalEntryEntity {
  /// Default constructor required by Isar
  JournalEntryEntity();
  
  Id id = Isar.autoIncrement;
  
  /// Unique identifier for the journal entry
  @Index(unique: true)
  late String entryId;
  
  /// The journal prompt that was used (if AI-generated)
  String? prompt;
  
  /// The user's journal entry content
  late String content;
  
  /// Rich text delta JSON for formatting (Quill format)
  String? richTextDelta;
  
  /// Whether the content is encrypted
  late bool isEncrypted;
  
  /// AI-generated analysis of the entry
  String? aiAnalysis;
  
  /// Detected themes/topics (serialized with '|||')
  String? themesJson;
  
  /// Detected emotions (serialized with '|||')
  String? emotionsJson;
  
  /// Mood score derived from entry (1-10)
  int? derivedMoodScore;
  
  /// Entry type: 'free', 'prompted', 'gratitude', 'reflection'
  @Index()
  late String entryType;
  
  /// Optional linked mood entry ID
  String? linkedMoodEntryId;
  
  /// Word count for statistics
  late int wordCount;
  
  /// Writing duration in seconds (if tracked)
  int? writingDurationSeconds;
  
  /// Creation timestamp
  @Index()
  late DateTime createdAt;
  
  /// Last modified timestamp
  late DateTime updatedAt;
  
  /// Day of week for pattern analysis (1-7, Monday=1)
  @Index()
  late int dayOfWeek;
  
  /// Hour of day for pattern analysis (0-23)
  @Index()
  late int hourOfDay;
  
  /// Whether this entry has been analyzed by AI
  late bool hasAiAnalysis;
  
  // ==================== Helpers ====================
  
  /// Get themes as list
  List<String>? get themes {
    if (themesJson == null || themesJson!.isEmpty) return null;
    return themesJson!.split('|||').where((s) => s.isNotEmpty).toList();
  }
  
  /// Set themes from list
  set themes(List<String>? value) {
    themesJson = value?.join('|||');
  }
  
  /// Get emotions as list
  List<String>? get emotions {
    if (emotionsJson == null || emotionsJson!.isEmpty) return null;
    return emotionsJson!.split('|||').where((s) => s.isNotEmpty).toList();
  }
  
  /// Set emotions from list
  set emotions(List<String>? value) {
    emotionsJson = value?.join('|||');
  }
  
  /// Factory constructor for creating new entries
  factory JournalEntryEntity.create({
    required String entryId,
    String? prompt,
    required String content,
    String? richTextDelta,
    bool isEncrypted = false,
    String? aiAnalysis,
    List<String>? themes,
    List<String>? emotions,
    int? derivedMoodScore,
    required String entryType,
    String? linkedMoodEntryId,
    int? writingDurationSeconds,
  }) {
    final now = DateTime.now();
    final entity = JournalEntryEntity()
      ..entryId = entryId
      ..prompt = prompt
      ..content = content
      ..richTextDelta = richTextDelta
      ..isEncrypted = isEncrypted
      ..aiAnalysis = aiAnalysis
      ..themesJson = themes?.join('|||')
      ..emotionsJson = emotions?.join('|||')
      ..derivedMoodScore = derivedMoodScore
      ..entryType = entryType
      ..linkedMoodEntryId = linkedMoodEntryId
      ..wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length
      ..writingDurationSeconds = writingDurationSeconds
      ..createdAt = now
      ..updatedAt = now
      ..dayOfWeek = now.weekday
      ..hourOfDay = now.hour
      ..hasAiAnalysis = aiAnalysis != null;
    return entity;
  }
}
