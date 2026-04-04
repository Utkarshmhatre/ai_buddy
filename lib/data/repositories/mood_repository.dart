import 'package:uuid/uuid.dart';

import '../../core/security/database_service.dart';
import '../../data/local/entities/mood_entry_entity.dart';
import '../../data/models/mood_entry.dart';

/// Repository for managing mood tracking entries
class MoodRepository {
  final DatabaseService _databaseService;
  final Uuid _uuid = const Uuid();

  MoodRepository(this._databaseService);

  /// Save a mood entry using the rich MoodEntry model
  Future<MoodEntry> saveMoodEntry({
    required MoodCategory category,
    required MoodIntensity intensity,
    String? notes,
    List<String>? triggers,
    List<String>? activities,
  }) async {
    final entryId = _uuid.v4();
    
    // Convert intensity to score (1-5 mapped to 1-10 scale)
    final moodScore = intensity.value * 2;
    
    await _databaseService.saveMoodEntry(
      entryId: entryId,
      moodScore: moodScore,
      moodLabel: category.name,
      source: 'check_in',
      conversationId: null,
      energyLevel: null,
      notes: notes,
      encryptNotes: notes != null,
      factors: [...?triggers, ...?activities],
    );
    
    return MoodEntry(
      id: entryId,
      category: category,
      intensity: intensity,
      notes: notes,
      triggers: triggers,
      activities: activities,
      timestamp: DateTime.now(),
    );
  }

  /// Get mood entries for a date range
  Future<List<MoodEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final entities = await _databaseService.getMoodEntries(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
    
    return entities.map(_moodEntryFromEntity).toList();
  }

  /// Get a single mood entry by ID
  Future<MoodEntry?> getMoodEntryById(String entryId) async {
    final entities = await _databaseService.getMoodEntries();
    final entity = entities.where((e) => e.entryId == entryId).firstOrNull;
    if (entity == null) return null;
    return _moodEntryFromEntity(entity);
  }

  /// Update AI insight for a mood entry
  Future<void> updateMoodInsight(String entryId, String insight) async {
    // Note: The current entity doesn't store AI insights
    // We would need to extend the entity or store in a separate collection
    // For now, we'll just log this - a full implementation would persist this
    print('MoodRepository: AI insight for $entryId: $insight');
  }

  /// Get today's mood entries
  Future<List<MoodEntry>> getTodaysMoodEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getMoodEntries(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get this week's mood entries
  Future<List<MoodEntry>> getThisWeeksMoodEntries() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return getMoodEntries(startDate: startOfDay, endDate: now);
  }

  /// Get average mood for a period
  Future<double?> getAverageMood({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _databaseService.getAverageMood(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Clear all mood entries
  Future<void> clearAllMoodEntries() async {
    await _databaseService.clearAllMoodEntries();
  }

  /// Get mood trend (comparing this week to last week)
  Future<MoodTrendRepository> getMoodTrend() async {
    final now = DateTime.now();
    
    // This week
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekAvg = await getAverageMood(
      startDate: DateTime(thisWeekStart.year, thisWeekStart.month, thisWeekStart.day),
      endDate: now,
    );
    
    // Last week
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    final lastWeekAvg = await getAverageMood(
      startDate: DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day),
      endDate: DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day, 23, 59, 59),
    );
    
    if (thisWeekAvg == null || lastWeekAvg == null) {
      return MoodTrendRepository.stable;
    }
    
    final difference = thisWeekAvg - lastWeekAvg;
    
    if (difference > 0.5) return MoodTrendRepository.improving;
    if (difference < -0.5) return MoodTrendRepository.declining;
    return MoodTrendRepository.stable;
  }

  /// Convert entity to model
  MoodEntry _moodEntryFromEntity(MoodEntryEntity entity) {
    // Convert moodLabel to MoodCategory
    final category = MoodCategory.values.firstWhere(
      (c) => c.name == entity.moodLabel,
      orElse: () => MoodCategory.calm,
    );
    
    // Convert moodScore (1-10) back to intensity (1-5)
    final intensityValue = (entity.moodScore / 2).round().clamp(1, 5);
    final intensity = MoodIntensity.values.firstWhere(
      (i) => i.value == intensityValue,
      orElse: () => MoodIntensity.neutral,
    );
    
    // Separate triggers and activities from factors
    final factors = entity.factors;
    
    return MoodEntry(
      id: entity.entryId,
      category: category,
      intensity: intensity,
      notes: _databaseService.getDecryptedNotes(entity),
      triggers: factors,
      timestamp: entity.timestamp,
    );
  }
}

/// Mood trend direction (repository version)
enum MoodTrendRepository {
  improving,
  stable,
  declining,
}
