import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';

import '../../core/security/database_service.dart';
import '../../data/local/entities/journal_entry_entity.dart';
import '../../data/models/journal_entry.dart';

/// Statistics about journal entries
class JournalStatistics {
  final int totalEntries;
  final int totalWords;
  final int averageWordsPerEntry;
  final int totalWritingMinutes;
  final Map<JournalEntryType, int> entriesByType;
  final double? averageMoodScore;
  final int streakDays;

  JournalStatistics({
    required this.totalEntries,
    required this.totalWords,
    required this.averageWordsPerEntry,
    required this.totalWritingMinutes,
    required this.entriesByType,
    this.averageMoodScore,
    required this.streakDays,
  });
}

/// Repository for managing journal entries
class JournalRepository {
  final DatabaseService _databaseService;
  final Uuid _uuid = const Uuid();

  JournalRepository(this._databaseService);

  Isar get _isar => _databaseService.isar;

  /// Save a new journal entry
  Future<JournalEntry> saveJournalEntry({
    String? prompt,
    required String content,
    String? richTextDelta,
    required JournalEntryType type,
    String? aiAnalysis,
    List<String>? themes,
    List<String>? emotions,
    int? derivedMoodScore,
    String? linkedMoodEntryId,
    int? writingDurationSeconds,
  }) async {
    final entryId = _uuid.v4();
    
    final entity = JournalEntryEntity.create(
      entryId: entryId,
      prompt: prompt,
      content: content, // Will be encrypted below
      richTextDelta: richTextDelta,
      isEncrypted: true,
      aiAnalysis: aiAnalysis,
      themes: themes,
      emotions: emotions,
      derivedMoodScore: derivedMoodScore,
      entryType: type.name,
      linkedMoodEntryId: linkedMoodEntryId,
      writingDurationSeconds: writingDurationSeconds,
    );
    
    // Encrypt content before saving
    entity.content = _databaseService.encryption.encrypt(content);
    entity.isEncrypted = true;
    
    await _isar.writeTxn(() async {
      await _isar.journalEntryEntitys.put(entity);
    });
    
    return JournalEntry(
      id: entryId,
      prompt: prompt,
      content: content, // Return unencrypted for immediate use
      richTextDelta: richTextDelta,
      type: type,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      aiAnalysis: aiAnalysis,
      themes: themes,
      emotions: emotions,
      derivedMoodScore: derivedMoodScore,
      linkedMoodEntryId: linkedMoodEntryId,
      wordCount: entity.wordCount,
      writingDurationSeconds: writingDurationSeconds,
    );
  }

  /// Update an existing journal entry
  Future<void> updateJournalEntry(JournalEntry entry) async {
    final entities = await _isar.journalEntryEntitys
        .where()
        .entryIdEqualTo(entry.id)
        .findAll();
    
    if (entities.isEmpty) return;
    final entity = entities.first;
    
    entity.content = _databaseService.encryption.encrypt(entry.content);
    entity.richTextDelta = entry.richTextDelta;
    entity.isEncrypted = true;
    entity.aiAnalysis = entry.aiAnalysis;
    entity.themes = entry.themes;
    entity.emotions = entry.emotions;
    entity.derivedMoodScore = entry.derivedMoodScore;
    entity.wordCount = entry.wordCount;
    entity.updatedAt = DateTime.now();
    entity.hasAiAnalysis = entry.aiAnalysis != null;
    
    await _isar.writeTxn(() async {
      await _isar.journalEntryEntitys.put(entity);
    });
  }

  /// Get all journal entries with optional filtering
  Future<List<JournalEntry>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
    JournalEntryType? type,
    int? limit,
  }) async {
    final allEntities = await _isar.journalEntryEntitys
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    
    var filtered = allEntities.where((e) {
      if (startDate != null && e.createdAt.isBefore(startDate)) return false;
      if (endDate != null && e.createdAt.isAfter(endDate)) return false;
      if (type != null && e.entryType != type.name) return false;
      return true;
    }).toList();
    
    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered.map(_journalEntryFromEntity).toList();
  }

  /// Get a single journal entry by ID
  Future<JournalEntry?> getJournalEntryById(String entryId) async {
    final entities = await _isar.journalEntryEntitys
        .where()
        .entryIdEqualTo(entryId)
        .findAll();
    
    if (entities.isEmpty) return null;
    return _journalEntryFromEntity(entities.first);
  }

  /// Get entries from today
  Future<List<JournalEntry>> getTodaysEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getJournalEntries(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get entries from this week
  Future<List<JournalEntry>> getThisWeeksEntries() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return getJournalEntries(startDate: startOfDay, endDate: now);
  }

  /// Delete a journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    final entities = await _isar.journalEntryEntitys
        .where()
        .entryIdEqualTo(entryId)
        .findAll();
    
    if (entities.isEmpty) return;
    
    await _isar.writeTxn(() async {
      await _isar.journalEntryEntitys.delete(entities.first.id);
    });
  }

  /// Clear all journal entries
  Future<void> clearAllJournalEntries() async {
    await _isar.writeTxn(() async {
      await _isar.journalEntryEntitys.clear();
    });
  }

  /// Get recent themes from journal entries
  Future<List<String>> getRecentThemes({int limit = 10}) async {
    final entries = await getJournalEntries(limit: 20);
    
    final themeCount = <String, int>{};
    for (final entry in entries) {
      if (entry.themes != null) {
        for (final theme in entry.themes!) {
          themeCount[theme] = (themeCount[theme] ?? 0) + 1;
        }
      }
    }
    
    final sortedThemes = themeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedThemes.take(limit).map((e) => e.key).toList();
  }

  /// Get journal statistics
  Future<JournalStatistics> getStatistics() async {
    final allEntries = await _isar.journalEntryEntitys
        .where()
        .findAll();
    
    if (allEntries.isEmpty) {
      return JournalStatistics(
        totalEntries: 0,
        totalWords: 0,
        averageWordsPerEntry: 0,
        totalWritingMinutes: 0,
        entriesByType: {},
        streakDays: 0,
      );
    }
    
    int totalWords = 0;
    int totalWritingSeconds = 0;
    final entriesByType = <JournalEntryType, int>{};
    double moodSum = 0;
    int moodCount = 0;
    
    for (final entity in allEntries) {
      totalWords += entity.wordCount;
      totalWritingSeconds += entity.writingDurationSeconds ?? 0;
      
      final type = JournalEntryType.values.firstWhere(
        (t) => t.name == entity.entryType,
        orElse: () => JournalEntryType.free,
      );
      entriesByType[type] = (entriesByType[type] ?? 0) + 1;
      
      if (entity.derivedMoodScore != null) {
        moodSum += entity.derivedMoodScore!;
        moodCount++;
      }
    }
    
    // Calculate streak
    final sortedEntries = allEntries.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streakDays = 0;
    DateTime? lastDate;
    
    for (final entity in sortedEntries) {
      final entryDate = DateTime(
        entity.createdAt.year,
        entity.createdAt.month,
        entity.createdAt.day,
      );
      
      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        if (entryDate == todayDate || 
            entryDate == todayDate.subtract(const Duration(days: 1))) {
          streakDays = 1;
          lastDate = entryDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (entryDate == expectedDate) {
          streakDays++;
          lastDate = entryDate;
        } else if (entryDate == lastDate) {
          // Same day, continue
          continue;
        } else {
          break;
        }
      }
    }
    
    return JournalStatistics(
      totalEntries: allEntries.length,
      totalWords: totalWords,
      averageWordsPerEntry: allEntries.isNotEmpty 
          ? (totalWords / allEntries.length).round() 
          : 0,
      totalWritingMinutes: (totalWritingSeconds / 60).round(),
      entriesByType: entriesByType,
      averageMoodScore: moodCount > 0 ? moodSum / moodCount : null,
      streakDays: streakDays,
    );
  }

  /// Convert entity to model
  JournalEntry _journalEntryFromEntity(JournalEntryEntity entity) {
    // Decrypt content if encrypted
    final content = entity.isEncrypted
        ? _databaseService.encryption.decrypt(entity.content)
        : entity.content;
    
    return JournalEntry(
      id: entity.entryId,
      prompt: entity.prompt,
      content: content,
      richTextDelta: entity.richTextDelta,
      type: JournalEntryType.values.firstWhere(
        (t) => t.name == entity.entryType,
        orElse: () => JournalEntryType.free,
      ),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      aiAnalysis: entity.aiAnalysis,
      themes: entity.themes,
      emotions: entity.emotions,
      derivedMoodScore: entity.derivedMoodScore,
      linkedMoodEntryId: entity.linkedMoodEntryId,
      wordCount: entity.wordCount,
      writingDurationSeconds: entity.writingDurationSeconds,
    );
  }

  /// Search journal entries by query and filters
  Future<List<JournalEntry>> searchEntries({
    required String query,
    JournalEntryType? filterType,
    List<String>? filterMoodTags,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allEntries = await getJournalEntries(
      startDate: startDate,
      endDate: endDate,
      type: filterType,
    );

    if (query.isEmpty && filterMoodTags == null) {
      return allEntries;
    }

    final queryLower = query.toLowerCase();
    
    return allEntries.where((entry) {
      // Check query match
      bool queryMatches = query.isEmpty;
      if (!queryMatches) {
        queryMatches = entry.content.toLowerCase().contains(queryLower) ||
            (entry.prompt?.toLowerCase().contains(queryLower) ?? false) ||
            (entry.aiAnalysis?.toLowerCase().contains(queryLower) ?? false) ||
            (entry.themes?.any((t) => t.toLowerCase().contains(queryLower)) ?? false);
      }

      // Check mood tag filters
      bool moodTagMatches = filterMoodTags == null || filterMoodTags.isEmpty;
      if (!moodTagMatches && entry.emotions != null) {
        moodTagMatches = filterMoodTags.any((tag) => 
            entry.emotions!.any((e) => e.toLowerCase() == tag.toLowerCase()));
      }

      return queryMatches && moodTagMatches;
    }).toList();
  }

  /// Update journal entry with rich text delta and mood tags
  Future<JournalEntry> updateEntryWithDetails({
    required String entryId,
    required String content,
    String? richTextDelta,
    List<String>? moodTags,
  }) async {
    final entities = await _isar.journalEntryEntitys
        .where()
        .entryIdEqualTo(entryId)
        .findAll();
    
    if (entities.isEmpty) {
      throw Exception('Journal entry not found');
    }

    final entity = entities.first;
    
    entity.content = _databaseService.encryption.encrypt(content);
    entity.isEncrypted = true;
    entity.wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    entity.updatedAt = DateTime.now();
    
    // Store mood tags as emotions
    if (moodTags != null) {
      entity.emotions = moodTags;
    }
    
    // TODO: Add richTextDelta field to entity in future migration
    // For now we store plain text content
    
    await _isar.writeTxn(() async {
      await _isar.journalEntryEntitys.put(entity);
    });
    
    return _journalEntryFromEntity(entity);
  }
}

