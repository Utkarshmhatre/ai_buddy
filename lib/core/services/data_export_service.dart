import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/journal_entry.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/chat_repository.dart';

/// Service for exporting user data
class DataExportService {
  final JournalRepository? journalRepository;
  final MoodRepository? moodRepository;
  final ChatRepository? chatRepository;
  
  DataExportService({
    this.journalRepository,
    this.moodRepository,
    this.chatRepository,
  });
  
  /// Export all user data as JSON
  Future<ExportResult> exportAllData({
    bool includeJournal = true,
    bool includeMood = true,
    bool includeChat = true,
  }) async {
    try {
      final exportData = <String, dynamic>{
        'exportInfo': {
          'appName': 'AI Buddy',
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
        },
      };
      
      // Export journal entries
      if (includeJournal && journalRepository != null) {
        final journalEntries = await journalRepository!.getJournalEntries();
        exportData['journalEntries'] = journalEntries.map((e) => _journalEntryToJson(e)).toList();
      }
      
      // Export mood entries (get all entries without date filter)
      if (includeMood && moodRepository != null) {
        final moodEntries = await moodRepository!.getMoodEntries();
        exportData['moodEntries'] = moodEntries.map((e) => _moodEntryToJson(e)).toList();
      }
      
      // Export chat messages
      if (includeChat && chatRepository != null) {
        final conversations = await chatRepository!.getAllConversations();
        final allMessages = <Map<String, dynamic>>[];
        for (final convo in conversations) {
          for (final msg in convo.messages) {
            allMessages.add(msg.toJson());
          }
        }
        exportData['chatMessages'] = allMessages;
      }
      
      // Generate statistics
      exportData['statistics'] = _generateStatistics(exportData);
      
      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Save to file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/ai_buddy_export_$timestamp.json');
      await file.writeAsString(jsonString);
      
      return ExportResult(
        success: true,
        filePath: file.path,
        fileSize: await file.length(),
        recordCount: _countRecords(exportData),
      );
    } catch (e) {
      debugPrint('Export error: $e');
      return ExportResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Share the exported data file
  Future<bool> shareExportedData(String filePath) async {
    try {
      final file = XFile(filePath);
      final result = await Share.shareXFiles(
        [file],
        subject: 'AI Buddy Data Export',
        text: 'My AI Buddy data export',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Share error: $e');
      return false;
    }
  }
  
  /// Export as readable text format (for printing/reading)
  Future<ExportResult> exportAsText() async {
    try {
      final buffer = StringBuffer();
      
      buffer.writeln('=' * 50);
      buffer.writeln('AI BUDDY DATA EXPORT');
      buffer.writeln('Exported: ${DateTime.now().toLocal()}');
      buffer.writeln('=' * 50);
      buffer.writeln();
      
      // Export mood entries
      if (moodRepository != null) {
        buffer.writeln('MOOD ENTRIES');
        buffer.writeln('-' * 30);
        final moodEntries = await moodRepository!.getMoodEntries();
        for (final entry in moodEntries) {
          buffer.writeln('Date: ${_formatDate(entry.timestamp)}');
          buffer.writeln('Mood: ${entry.category.label} (${entry.intensity.name})');
          if (entry.notes?.isNotEmpty == true) {
            buffer.writeln('Note: ${entry.notes}');
          }
          buffer.writeln();
        }
        buffer.writeln();
      }
      
      // Export journal entries
      if (journalRepository != null) {
        buffer.writeln('JOURNAL ENTRIES');
        buffer.writeln('-' * 30);
        final journalEntries = await journalRepository!.getJournalEntries();
        for (final entry in journalEntries) {
          buffer.writeln('Date: ${_formatDate(entry.createdAt)}');
          buffer.writeln('Type: ${entry.type.label}');
          if (entry.prompt != null) {
            buffer.writeln('Prompt: ${entry.prompt}');
          }
          buffer.writeln('Entry:');
          buffer.writeln(entry.content);
          if (entry.aiAnalysis != null) {
            buffer.writeln('AI Analysis: ${entry.aiAnalysis}');
          }
          buffer.writeln();
          buffer.writeln('-' * 20);
          buffer.writeln();
        }
      }
      
      // Save to file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/ai_buddy_export_$timestamp.txt');
      await file.writeAsString(buffer.toString());
      
      return ExportResult(
        success: true,
        filePath: file.path,
        fileSize: await file.length(),
      );
    } catch (e) {
      return ExportResult(success: false, error: e.toString());
    }
  }
  
  Map<String, dynamic> _journalEntryToJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'type': entry.type.name,
      'prompt': entry.prompt,
      'content': entry.content,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
      'wordCount': entry.wordCount,
      'themes': entry.themes,
      'emotions': entry.emotions,
      'aiAnalysis': entry.aiAnalysis,
      'moodScore': entry.derivedMoodScore,
    };
  }
  
  Map<String, dynamic> _moodEntryToJson(MoodEntry entry) {
    return {
      'id': entry.id,
      'category': entry.category.name,
      'intensity': entry.intensity.name,
      'notes': entry.notes,
      'timestamp': entry.timestamp.toIso8601String(),
      'triggers': entry.triggers,
      'activities': entry.activities,
      'aiInsight': entry.aiInsight,
    };
  }
  
  Map<String, dynamic> _generateStatistics(Map<String, dynamic> data) {
    final stats = <String, dynamic>{};
    
    if (data['journalEntries'] != null) {
      final entries = data['journalEntries'] as List;
      stats['totalJournalEntries'] = entries.length;
    }
    
    if (data['moodEntries'] != null) {
      final entries = data['moodEntries'] as List;
      stats['totalMoodEntries'] = entries.length;
    }
    
    if (data['chatMessages'] != null) {
      final messages = data['chatMessages'] as List;
      stats['totalChatMessages'] = messages.length;
    }
    
    return stats;
  }
  
  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    if (data['journalEntries'] != null) count += (data['journalEntries'] as List).length;
    if (data['moodEntries'] != null) count += (data['moodEntries'] as List).length;
    if (data['chatMessages'] != null) count += (data['chatMessages'] as List).length;
    return count;
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Result of an export operation
class ExportResult {
  final bool success;
  final String? filePath;
  final int? fileSize;
  final int? recordCount;
  final String? error;
  
  ExportResult({
    required this.success,
    this.filePath,
    this.fileSize,
    this.recordCount,
    this.error,
  });
  
  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize bytes';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
