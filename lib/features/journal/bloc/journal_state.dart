import 'package:equatable/equatable.dart';

import '../../../data/models/journal_entry.dart';
import '../../../data/repositories/journal_repository.dart';

/// States for JournalBloc
abstract class JournalState extends Equatable {
  const JournalState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class JournalInitial extends JournalState {
  const JournalInitial();
}

/// Loading state
class JournalLoading extends JournalState {
  const JournalLoading();
}

/// Journal entries loaded
class JournalEntriesLoaded extends JournalState {
  final List<JournalEntry> entries;
  final JournalStatistics? statistics;
  
  const JournalEntriesLoaded({
    required this.entries,
    this.statistics,
  });
  
  @override
  List<Object?> get props => [entries, statistics];
}

/// Prompt generated
class PromptGenerated extends JournalState {
  final JournalPrompt prompt;
  
  const PromptGenerated({required this.prompt});
  
  @override
  List<Object?> get props => [prompt];
}

/// Ready to write
class JournalWritingState extends JournalState {
  final JournalEntryType type;
  final String? prompt;
  final String currentContent;
  final int wordCount;
  final DateTime startTime;
  
  const JournalWritingState({
    required this.type,
    this.prompt,
    this.currentContent = '',
    this.wordCount = 0,
    required this.startTime,
  });
  
  JournalWritingState copyWith({
    JournalEntryType? type,
    String? prompt,
    String? currentContent,
    int? wordCount,
    DateTime? startTime,
  }) {
    return JournalWritingState(
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      currentContent: currentContent ?? this.currentContent,
      wordCount: wordCount ?? this.wordCount,
      startTime: startTime ?? this.startTime,
    );
  }
  
  @override
  List<Object?> get props => [type, prompt, currentContent, wordCount, startTime];
}

/// Entry saved successfully
class JournalEntrySaved extends JournalState {
  final JournalEntry entry;
  final bool isAnalyzing;
  
  const JournalEntrySaved({
    required this.entry,
    this.isAnalyzing = false,
  });
  
  @override
  List<Object?> get props => [entry, isAnalyzing];
}

/// Entry analyzed
class JournalEntryAnalyzed extends JournalState {
  final JournalEntry entry;
  final JournalAnalysis analysis;
  
  const JournalEntryAnalyzed({
    required this.entry,
    required this.analysis,
  });
  
  @override
  List<Object?> get props => [entry, analysis];
}

/// Statistics loaded
class JournalStatisticsLoaded extends JournalState {
  final JournalStatistics statistics;
  final List<String> recentThemes;
  
  const JournalStatisticsLoaded({
    required this.statistics,
    required this.recentThemes,
  });
  
  @override
  List<Object?> get props => [statistics, recentThemes];
}

/// Entry deleted
class JournalEntryDeleted extends JournalState {
  final String entryId;
  
  const JournalEntryDeleted({required this.entryId});
  
  @override
  List<Object?> get props => [entryId];
}

/// Search results state
class JournalSearchResults extends JournalState {
  final List<JournalEntry> entries;
  final String query;
  final JournalEntryType? filterType;
  final List<String>? filterMoodTags;
  final int totalResults;
  
  const JournalSearchResults({
    required this.entries,
    required this.query,
    this.filterType,
    this.filterMoodTags,
    required this.totalResults,
  });
  
  @override
  List<Object?> get props => [entries, query, filterType, filterMoodTags, totalResults];
}

/// Entry updated state
class JournalEntryUpdated extends JournalState {
  final JournalEntry entry;
  
  const JournalEntryUpdated({required this.entry});
  
  @override
  List<Object?> get props => [entry];
}

/// Error state
class JournalError extends JournalState {
  final String message;
  
  const JournalError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
