import 'package:equatable/equatable.dart';

import '../../../data/models/journal_entry.dart';

/// Events for JournalBloc
abstract class JournalEvent extends Equatable {
  const JournalEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load journal entries
class LoadJournalEntries extends JournalEvent {
  final int? limit;
  final JournalEntryType? type;
  
  const LoadJournalEntries({this.limit, this.type});
  
  @override
  List<Object?> get props => [limit, type];
}

/// Generate a new journal prompt
class GeneratePrompt extends JournalEvent {
  final JournalEntryType type;
  final String? currentMoodCategory;
  
  const GeneratePrompt({
    required this.type,
    this.currentMoodCategory,
  });
  
  @override
  List<Object?> get props => [type, currentMoodCategory];
}

/// Start a new journal entry
class StartJournalEntry extends JournalEvent {
  final JournalEntryType type;
  final String? prompt;
  
  const StartJournalEntry({
    required this.type,
    this.prompt,
  });
  
  @override
  List<Object?> get props => [type, prompt];
}

/// Save journal entry
class SaveJournalEntry extends JournalEvent {
  final String content;
  final JournalEntryType type;
  final String? prompt;
  final int? writingDurationSeconds;
  final bool analyzeWithAI;
  final String? richTextDelta;
  
  const SaveJournalEntry({
    required this.content,
    required this.type,
    this.prompt,
    this.writingDurationSeconds,
    this.analyzeWithAI = true,
    this.richTextDelta,
  });
  
  @override
  List<Object?> get props => [content, type, prompt, writingDurationSeconds, analyzeWithAI, richTextDelta];
}

/// Analyze a journal entry with AI
class AnalyzeEntry extends JournalEvent {
  final String entryId;
  
  const AnalyzeEntry({required this.entryId});
  
  @override
  List<Object?> get props => [entryId];
}

/// Delete a journal entry
class DeleteJournalEntry extends JournalEvent {
  final String entryId;
  
  const DeleteJournalEntry({required this.entryId});
  
  @override
  List<Object?> get props => [entryId];
}

/// Load journal statistics
class LoadJournalStatistics extends JournalEvent {
  const LoadJournalStatistics();
  
  @override
  List<Object?> get props => [];
}

/// Load recent themes
class LoadRecentThemes extends JournalEvent {
  const LoadRecentThemes();
}

/// Update current entry content (for auto-save)
class UpdateEntryContent extends JournalEvent {
  final String content;
  
  const UpdateEntryContent({required this.content});
  
  @override
  List<Object?> get props => [content];
}

/// Search journal entries
class SearchJournalEntries extends JournalEvent {
  final String query;
  final JournalEntryType? filterType;
  final List<String>? filterMoodTags;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const SearchJournalEntries({
    required this.query,
    this.filterType,
    this.filterMoodTags,
    this.startDate,
    this.endDate,
  });
  
  @override
  List<Object?> get props => [query, filterType, filterMoodTags, startDate, endDate];
}

/// Update an existing journal entry
class UpdateJournalEntry extends JournalEvent {
  final String entryId;
  final String content;
  final String? richTextDelta;
  final List<String>? moodTags;
  
  const UpdateJournalEntry({
    required this.entryId,
    required this.content,
    this.richTextDelta,
    this.moodTags,
  });
  
  @override
  List<Object?> get props => [entryId, content, richTextDelta, moodTags];
}

/// Clear search and filters
class ClearJournalFilters extends JournalEvent {
  const ClearJournalFilters();
}

