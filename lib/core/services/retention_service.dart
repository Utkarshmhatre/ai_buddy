import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../security/database_service.dart';
import '../security/encryption_service.dart';

/// Service for managing data retention and automatic purging of old data
class RetentionService {
  static RetentionService? _instance;
  
  static const String _retentionDaysKey = 'retention_days';
  static const String _lastPurgeKey = 'last_purge_date';
  static const String _autoPurgeEnabledKey = 'auto_purge_enabled';
  
  // Default retention periods (in days)
  static const int defaultRetentionDays = 90;
  static const int minRetentionDays = 7;
  static const int maxRetentionDays = 365;
  
  // Predefined retention options
  static const Map<String, int> retentionOptions = {
    '1 week': 7,
    '30 days': 30,
    '90 days': 90,
    '6 months': 180,
    '1 year': 365,
    'Forever': -1, // -1 means no auto-purge
  };
  
  late SharedPreferences _prefs;
  DatabaseService? _databaseService;
  bool _initialized = false;
  Timer? _purgeTimer;
  
  RetentionService._();
  
  /// Get singleton instance
  static Future<RetentionService> getInstance() async {
    if (_instance == null) {
      _instance = RetentionService._();
      await _instance!._initialize();
    }
    return _instance!;
  }
  
  Future<void> _initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    try {
      final encryptionService = EncryptionService();
      await encryptionService.initialize();
      _databaseService = await DatabaseService.getInstance(
        encryptionService: encryptionService,
      );
    } catch (e) {
      debugPrint('RetentionService: Database not available: $e');
    }
    
    _initialized = true;
    
    // Schedule periodic purge check (every 6 hours)
    _schedulePurgeCheck();
    
    // Check if purge is needed on startup
    await _checkAndPurgeIfNeeded();
  }
  
  void _schedulePurgeCheck() {
    _purgeTimer?.cancel();
    _purgeTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _checkAndPurgeIfNeeded(),
    );
  }
  
  /// Get current retention period in days
  int get retentionDays {
    return _prefs.getInt(_retentionDaysKey) ?? defaultRetentionDays;
  }
  
  /// Set retention period in days
  Future<void> setRetentionDays(int days) async {
    if (days != -1 && (days < minRetentionDays || days > maxRetentionDays)) {
      throw ArgumentError(
        'Retention days must be between $minRetentionDays and $maxRetentionDays, or -1 for forever',
      );
    }
    await _prefs.setInt(_retentionDaysKey, days);
  }
  
  /// Check if auto-purge is enabled
  bool get isAutoPurgeEnabled {
    return _prefs.getBool(_autoPurgeEnabledKey) ?? true;
  }
  
  /// Enable or disable auto-purge
  Future<void> setAutoPurgeEnabled(bool enabled) async {
    await _prefs.setBool(_autoPurgeEnabledKey, enabled);
  }
  
  /// Get the date of the last purge
  DateTime? get lastPurgeDate {
    final timestamp = _prefs.getInt(_lastPurgeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Get human-readable retention period string
  String get retentionPeriodLabel {
    final days = retentionDays;
    if (days == -1) return 'Forever';
    if (days == 7) return '1 week';
    if (days == 30) return '30 days';
    if (days == 90) return '90 days';
    if (days == 180) return '6 months';
    if (days == 365) return '1 year';
    return '$days days';
  }
  
  /// Check if purge is needed and perform it
  Future<void> _checkAndPurgeIfNeeded() async {
    if (!isAutoPurgeEnabled) return;
    if (retentionDays == -1) return; // Forever means no purge
    
    final lastPurge = lastPurgeDate;
    final now = DateTime.now();
    
    // Only purge once per day at most
    if (lastPurge != null && 
        now.difference(lastPurge).inHours < 24) {
      return;
    }
    
    await purgeOldData();
  }
  
  /// Manually trigger data purge
  Future<PurgeResult> purgeOldData() async {
    if (_databaseService == null) {
      return PurgeResult(
        success: false,
        error: 'Database not available',
      );
    }
    
    final days = retentionDays;
    if (days == -1) {
      return PurgeResult(
        success: true,
        message: 'Auto-purge disabled (retention set to forever)',
      );
    }
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    try {
      // Count items before purge
      final beforeCounts = await _getDataCounts();
      
      // Purge old data from each collection
      await _purgeOldMessages(cutoffDate);
      await _purgeOldMoodEntries(cutoffDate);
      await _purgeOldJournalEntries(cutoffDate);
      await _purgeOldConversations(cutoffDate);
      
      // Count items after purge
      final afterCounts = await _getDataCounts();
      
      // Calculate deleted counts
      final deletedMessages = beforeCounts['messages']! - afterCounts['messages']!;
      final deletedMoods = beforeCounts['moods']! - afterCounts['moods']!;
      final deletedJournals = beforeCounts['journals']! - afterCounts['journals']!;
      final deletedConversations = beforeCounts['conversations']! - afterCounts['conversations']!;
      
      // Update last purge date
      await _prefs.setInt(_lastPurgeKey, DateTime.now().millisecondsSinceEpoch);
      
      return PurgeResult(
        success: true,
        deletedMessages: deletedMessages,
        deletedMoodEntries: deletedMoods,
        deletedJournalEntries: deletedJournals,
        deletedConversations: deletedConversations,
        cutoffDate: cutoffDate,
      );
    } catch (e) {
      debugPrint('RetentionService: Purge failed: $e');
      return PurgeResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  Future<Map<String, int>> _getDataCounts() async {
    // Get counts from database
    // This is a simplified version - actual implementation would query DB
    return {
      'messages': 0,
      'moods': 0,
      'journals': 0,
      'conversations': 0,
    };
  }
  
  Future<void> _purgeOldMessages(DateTime cutoffDate) async {
    if (_databaseService == null) return;
    await _databaseService!.deleteMessagesOlderThan(cutoffDate);
  }
  
  Future<void> _purgeOldMoodEntries(DateTime cutoffDate) async {
    if (_databaseService == null) return;
    await _databaseService!.deleteMoodEntriesOlderThan(cutoffDate);
  }
  
  Future<void> _purgeOldJournalEntries(DateTime cutoffDate) async {
    if (_databaseService == null) return;
    await _databaseService!.deleteJournalEntriesOlderThan(cutoffDate);
  }
  
  Future<void> _purgeOldConversations(DateTime cutoffDate) async {
    if (_databaseService == null) return;
    await _databaseService!.deleteEmptyConversationsOlderThan(cutoffDate);
  }
  
  /// Delete all user data immediately
  Future<bool> deleteAllData() async {
    if (_databaseService == null) return false;
    
    try {
      await _databaseService!.deleteAllData();
      await _prefs.remove(_lastPurgeKey);
      return true;
    } catch (e) {
      debugPrint('RetentionService: Delete all failed: $e');
      return false;
    }
  }
  
  /// Get estimated storage usage
  Future<StorageInfo> getStorageInfo() async {
    // Simplified - actual implementation would calculate real sizes
    return StorageInfo(
      totalSizeBytes: 0,
      messagesSizeBytes: 0,
      moodsSizeBytes: 0,
      journalsSizeBytes: 0,
      conversationsSizeBytes: 0,
    );
  }
  
  void dispose() {
    _purgeTimer?.cancel();
  }
}

/// Result of a purge operation
class PurgeResult {
  final bool success;
  final String? error;
  final String? message;
  final int deletedMessages;
  final int deletedMoodEntries;
  final int deletedJournalEntries;
  final int deletedConversations;
  final DateTime? cutoffDate;
  
  PurgeResult({
    required this.success,
    this.error,
    this.message,
    this.deletedMessages = 0,
    this.deletedMoodEntries = 0,
    this.deletedJournalEntries = 0,
    this.deletedConversations = 0,
    this.cutoffDate,
  });
  
  int get totalDeleted => 
      deletedMessages + deletedMoodEntries + deletedJournalEntries + deletedConversations;
  
  String get summary {
    if (!success) return error ?? 'Purge failed';
    if (message != null) return message!;
    if (totalDeleted == 0) return 'No old data to remove';
    
    final parts = <String>[];
    if (deletedMessages > 0) parts.add('$deletedMessages messages');
    if (deletedMoodEntries > 0) parts.add('$deletedMoodEntries mood entries');
    if (deletedJournalEntries > 0) parts.add('$deletedJournalEntries journal entries');
    if (deletedConversations > 0) parts.add('$deletedConversations conversations');
    
    return 'Removed: ${parts.join(', ')}';
  }
}

/// Storage information
class StorageInfo {
  final int totalSizeBytes;
  final int messagesSizeBytes;
  final int moodsSizeBytes;
  final int journalsSizeBytes;
  final int conversationsSizeBytes;
  
  StorageInfo({
    required this.totalSizeBytes,
    required this.messagesSizeBytes,
    required this.moodsSizeBytes,
    required this.journalsSizeBytes,
    required this.conversationsSizeBytes,
  });
  
  String get totalSizeFormatted => _formatBytes(totalSizeBytes);
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
