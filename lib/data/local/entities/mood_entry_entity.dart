import 'package:isar/isar.dart';

part 'mood_entry_entity.g.dart';

/// Isar collection for storing mood tracking entries
@collection
class MoodEntryEntity {
  Id id = Isar.autoIncrement;

  /// Unique entry identifier
  @Index(unique: true)
  late String entryId;

  /// Optional link to conversation where mood was detected
  String? conversationId;

  /// Mood score (1-10)
  @Index()
  late int moodScore;

  /// Mood label (happy, sad, anxious, calm, etc.)
  late String moodLabel;

  /// Energy level (1-10)
  int? energyLevel;

  /// User's notes about the mood
  String? notes;

  /// Whether notes are encrypted
  late bool isEncrypted;

  /// Source of entry: 'manual', 'ai_detected', 'check_in'
  late String source;

  /// Contributing factors (serialized)
  String? factorsJson;

  /// When the entry was created
  @Index()
  late DateTime timestamp;

  /// Day of week (for pattern analysis)
  @Index()
  late int dayOfWeek;

  /// Hour of day (for pattern analysis)
  @Index()
  late int hourOfDay;

  /// Constructor
  MoodEntryEntity();

  /// Create from values
  factory MoodEntryEntity.create({
    required String entryId,
    required int moodScore,
    required String moodLabel,
    required String source,
    String? conversationId,
    int? energyLevel,
    String? notes,
    bool isEncrypted = false,
    List<String>? factors,
  }) {
    final now = DateTime.now();
    final entity = MoodEntryEntity()
      ..entryId = entryId
      ..conversationId = conversationId
      ..moodScore = moodScore
      ..moodLabel = moodLabel
      ..energyLevel = energyLevel
      ..notes = notes
      ..isEncrypted = isEncrypted
      ..source = source
      ..factorsJson = factors?.join('|||')
      ..timestamp = now
      ..dayOfWeek = now.weekday
      ..hourOfDay = now.hour;
    return entity;
  }

  /// Get factors as list
  List<String>? get factors {
    if (factorsJson == null || factorsJson!.isEmpty) return null;
    return factorsJson!.split('|||');
  }

  /// Set factors from list
  set factors(List<String>? value) {
    factorsJson = value?.join('|||');
  }
}
