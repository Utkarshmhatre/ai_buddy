import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/entities/conversation_entity.dart';
import '../../data/local/entities/journal_entry_entity.dart';
import '../../data/local/entities/message_entity.dart';
import '../../data/local/entities/mood_entry_entity.dart';
import '../../data/local/entities/user_profile_entity.dart';
import 'encryption_service.dart';

/// Service for managing the local Isar database
class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;
  
  final EncryptionService _encryptionService;

  DatabaseService._internal(this._encryptionService);

  /// Get singleton instance
  static Future<DatabaseService> getInstance({
    required EncryptionService encryptionService,
  }) async {
    if (_instance == null) {
      _instance = DatabaseService._internal(encryptionService);
      await _instance!._initialize();
    }
    return _instance!;
  }

  /// Initialize the database
  Future<void> _initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        ConversationEntitySchema,
        JournalEntryEntitySchema,
        MessageEntitySchema,
        MoodEntryEntitySchema,
        UserProfileEntitySchema,
      ],
      directory: dir.path,
      name: 'ai_buddy_db',
      // Note: Isar doesn't support encryption directly in newer versions
      // We handle encryption at the application level for sensitive fields
    );
  }

  /// Get the Isar instance
  Isar get isar {
    if (_isar == null) {
      throw StateError('DatabaseService not initialized. Call getInstance() first.');
    }
    return _isar!;
  }

  /// Get encryption service for encrypting sensitive data
  EncryptionService get encryption => _encryptionService;

  // ==================== Conversation Operations ====================

  /// Create a new conversation
  Future<ConversationEntity> createConversation({
    required String conversationId,
    String? title,
    String? userName,
  }) async {
    final entity = ConversationEntity.create(
      conversationId: conversationId,
      title: title,
      userName: userName,
    );
    
    await isar.writeTxn(() async {
      await isar.conversationEntitys.put(entity);
    });
    
    return entity;
  }

  /// Get conversation by ID
  Future<ConversationEntity?> getConversation(String conversationId) async {
    return await isar.conversationEntitys
        .where()
        .conversationIdEqualTo(conversationId)
        .findFirst();
  }

  /// Get active conversation
  Future<ConversationEntity?> getActiveConversation() async {
    return await isar.conversationEntitys
        .where()
        .isActiveEqualTo(true)
        .sortByUpdatedAtDesc()
        .findFirst();
  }

  /// Get all conversations
  Future<List<ConversationEntity>> getAllConversations() async {
    return await isar.conversationEntitys
        .where()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Update conversation
  Future<void> updateConversation(ConversationEntity conversation) async {
    conversation.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.conversationEntitys.put(conversation);
    });
  }

  /// Delete conversation and its messages
  Future<void> deleteConversation(String conversationId) async {
    await isar.writeTxn(() async {
      // Delete all messages in conversation
      await isar.messageEntitys
          .where()
          .conversationIdEqualTo(conversationId)
          .deleteAll();
      
      // Delete conversation
      await isar.conversationEntitys
          .where()
          .conversationIdEqualTo(conversationId)
          .deleteAll();
    });
  }

  // ==================== Message Operations ====================

  /// Save a message
  Future<MessageEntity> saveMessage({
    required String messageId,
    required String conversationId,
    required String content,
    required String sender,
    bool encryptContent = true,
    String? emotionType,
    String? emotionIntensity,
    int? crisisLevel,
    List<String>? suggestedActions,
  }) async {
    // Encrypt sensitive content if requested
    final storedContent = encryptContent 
        ? _encryptionService.encrypt(content)
        : content;

    final entity = MessageEntity.create(
      messageId: messageId,
      conversationId: conversationId,
      content: storedContent,
      sender: sender,
      isEncrypted: encryptContent,
      emotionType: emotionType,
      emotionIntensity: emotionIntensity,
      crisisLevel: crisisLevel,
      suggestedActions: suggestedActions,
    );
    
    await isar.writeTxn(() async {
      await isar.messageEntitys.put(entity);
    });
    
    return entity;
  }

  /// Get messages for a conversation
  Future<List<MessageEntity>> getMessages(
    String conversationId, {
    int? limit,
    int? offset,
  }) async {
    final query = isar.messageEntitys
        .where()
        .conversationIdEqualTo(conversationId)
        .sortByTimestamp();
    
    final results = await query.findAll();
    
    // Apply offset and limit in memory for simplicity
    var filtered = results;
    if (offset != null) {
      filtered = filtered.skip(offset).toList();
    }
    if (limit != null) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }

  /// Get decrypted message content
  String getDecryptedContent(MessageEntity message) {
    if (message.isEncrypted) {
      return _encryptionService.decrypt(message.content);
    }
    return message.content;
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await isar.writeTxn(() async {
      await isar.messageEntitys
          .where()
          .messageIdEqualTo(messageId)
          .deleteAll();
    });
  }

  // ==================== Mood Entry Operations ====================

  /// Save a mood entry
  Future<MoodEntryEntity> saveMoodEntry({
    required String entryId,
    required int moodScore,
    required String moodLabel,
    required String source,
    String? conversationId,
    int? energyLevel,
    String? notes,
    bool encryptNotes = true,
    List<String>? factors,
  }) async {
    // Encrypt notes if requested
    final storedNotes = (notes != null && encryptNotes)
        ? _encryptionService.encrypt(notes)
        : notes;

    final entity = MoodEntryEntity.create(
      entryId: entryId,
      moodScore: moodScore,
      moodLabel: moodLabel,
      source: source,
      conversationId: conversationId,
      energyLevel: energyLevel,
      notes: storedNotes,
      isEncrypted: notes != null && encryptNotes,
      factors: factors,
    );
    
    await isar.writeTxn(() async {
      await isar.moodEntryEntitys.put(entity);
    });
    
    return entity;
  }

  /// Get mood entries for a date range
  Future<List<MoodEntryEntity>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final allEntries = await isar.moodEntryEntitys
        .where()
        .sortByTimestampDesc()
        .findAll();
    
    var filtered = allEntries;
    
    // Filter by date range in memory
    if (startDate != null && endDate != null) {
      filtered = filtered.where((e) => 
        e.timestamp.isAfter(startDate) && e.timestamp.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    }
    
    if (limit != null) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }

  /// Get average mood for a date range
  Future<double?> getAverageMood({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await getMoodEntries(startDate: startDate, endDate: endDate);
    if (entries.isEmpty) return null;
    
    final sum = entries.fold<int>(0, (sum, e) => sum + e.moodScore);
    return sum / entries.length;
  }

  /// Get decrypted notes
  String? getDecryptedNotes(MoodEntryEntity entry) {
    if (entry.notes == null) return null;
    if (entry.isEncrypted) {
      return _encryptionService.decrypt(entry.notes!);
    }
    return entry.notes;
  }

  // ==================== User Profile Operations ====================

  /// Get or create user profile
  Future<UserProfileEntity> getOrCreateProfile(String deviceId) async {
    var profile = await isar.userProfileEntitys
        .where()
        .deviceIdEqualTo(deviceId)
        .findFirst();
    
    if (profile == null) {
      profile = UserProfileEntity.create(deviceId: deviceId);
      await isar.writeTxn(() async {
        await isar.userProfileEntitys.put(profile!);
      });
    }
    
    return profile;
  }

  /// Update user profile
  Future<void> updateProfile(UserProfileEntity profile) async {
    profile.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.userProfileEntitys.put(profile);
    });
  }

  /// Update streak
  Future<void> updateStreak(String deviceId) async {
    final profile = await getOrCreateProfile(deviceId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (profile.lastActiveDate != null) {
      final lastActive = DateTime(
        profile.lastActiveDate!.year,
        profile.lastActiveDate!.month,
        profile.lastActiveDate!.day,
      );
      
      final difference = today.difference(lastActive).inDays;
      
      if (difference == 1) {
        // Consecutive day
        profile.currentStreak++;
        if (profile.currentStreak > profile.longestStreak) {
          profile.longestStreak = profile.currentStreak;
        }
      } else if (difference > 1) {
        // Streak broken
        profile.currentStreak = 1;
      }
      // If difference == 0, same day, don't change streak
    } else {
      profile.currentStreak = 1;
    }
    
    profile.lastActiveDate = now;
    await updateProfile(profile);
  }

  // ==================== Cleanup Operations ====================

  /// Clear all conversations and messages
  Future<void> clearAllConversations() async {
    await isar.writeTxn(() async {
      await isar.conversationEntitys.clear();
      await isar.messageEntitys.clear();
    });
  }

  /// Clear all mood entries
  Future<void> clearAllMoodEntries() async {
    await isar.writeTxn(() async {
      await isar.moodEntryEntitys.clear();
    });
  }

  // ==================== Retention / Purge Operations ====================

  /// Delete messages older than the given date
  Future<int> deleteMessagesOlderThan(DateTime cutoffDate) async {
    return await isar.writeTxn(() async {
      return await isar.messageEntitys
          .filter()
          .timestampLessThan(cutoffDate)
          .deleteAll();
    });
  }

  /// Delete mood entries older than the given date
  Future<int> deleteMoodEntriesOlderThan(DateTime cutoffDate) async {
    return await isar.writeTxn(() async {
      return await isar.moodEntryEntitys
          .filter()
          .timestampLessThan(cutoffDate)
          .deleteAll();
    });
  }

  /// Delete journal entries older than the given date
  Future<int> deleteJournalEntriesOlderThan(DateTime cutoffDate) async {
    return await isar.writeTxn(() async {
      return await isar.journalEntryEntitys
          .filter()
          .createdAtLessThan(cutoffDate)
          .deleteAll();
    });
  }

  /// Delete empty conversations older than the given date
  /// (conversations with no messages)
  Future<int> deleteEmptyConversationsOlderThan(DateTime cutoffDate) async {
    // Get all conversations older than cutoff
    final oldConversations = await isar.conversationEntitys
        .filter()
        .updatedAtLessThan(cutoffDate)
        .findAll();
    
    int deletedCount = 0;
    
    await isar.writeTxn(() async {
      for (final conv in oldConversations) {
        // Check if conversation has any messages
        final messageCount = await isar.messageEntitys
            .filter()
            .conversationIdEqualTo(conv.conversationId)
            .count();
        
        if (messageCount == 0) {
          await isar.conversationEntitys.delete(conv.id);
          deletedCount++;
        }
      }
    });
    
    return deletedCount;
  }

  /// Get count of messages
  Future<int> getMessageCount() async {
    return await isar.messageEntitys.count();
  }

  /// Get count of mood entries
  Future<int> getMoodEntryCount() async {
    return await isar.moodEntryEntitys.count();
  }

  /// Get count of journal entries
  Future<int> getJournalEntryCount() async {
    return await isar.journalEntryEntitys.count();
  }

  /// Get count of conversations
  Future<int> getConversationCount() async {
    return await isar.conversationEntitys.count();
  }

  /// Delete all data (for account deletion / GDPR right to erasure)
  Future<void> deleteAllData() async {
    await isar.writeTxn(() async {
      await isar.conversationEntitys.clear();
      await isar.messageEntitys.clear();
      await isar.moodEntryEntitys.clear();
      await isar.userProfileEntitys.clear();
    });
    
    // Also clear encryption keys
    await _encryptionService.clearKeys();
  }

  /// Close database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _instance = null;
  }
}
