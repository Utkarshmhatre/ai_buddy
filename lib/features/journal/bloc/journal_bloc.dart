import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../data/models/journal_entry.dart';
import '../../../data/repositories/journal_repository.dart';
import 'journal_event.dart';
import 'journal_state.dart';

/// BLoC for managing journal functionality
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository _journalRepository;
  final EnhancedGeminiService _aiService;
  
  JournalBloc({
    required JournalRepository journalRepository,
    required EnhancedGeminiService aiService,
  })  : _journalRepository = journalRepository,
        _aiService = aiService,
        super(const JournalInitial()) {
    on<LoadJournalEntries>(_onLoadEntries);
    on<GeneratePrompt>(_onGeneratePrompt);
    on<StartJournalEntry>(_onStartEntry);
    on<SaveJournalEntry>(_onSaveEntry);
    on<AnalyzeEntry>(_onAnalyzeEntry);
    on<DeleteJournalEntry>(_onDeleteEntry);
    on<LoadJournalStatistics>(_onLoadStatistics);
    on<LoadRecentThemes>(_onLoadRecentThemes);
    on<UpdateEntryContent>(_onUpdateContent);
    on<SearchJournalEntries>(_onSearchEntries);
    on<UpdateJournalEntry>(_onUpdateEntry);
    on<ClearJournalFilters>(_onClearFilters);
  }
  
  Future<void> _onLoadEntries(
    LoadJournalEntries event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());
    
    try {
      final entries = await _journalRepository.getJournalEntries(
        limit: event.limit,
        type: event.type,
      );
      
      final statistics = await _journalRepository.getStatistics();
      
      emit(JournalEntriesLoaded(
        entries: entries,
        statistics: statistics,
      ));
    } catch (e) {
      emit(JournalError(message: 'Failed to load journal entries: $e'));
    }
  }
  
  Future<void> _onGeneratePrompt(
    GeneratePrompt event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());
    
    try {
      final recentThemes = await _journalRepository.getRecentThemes();
      
      final prompt = await _aiService.generateJournalPrompt(
        type: event.type,
        recentThemes: recentThemes,
        timeOfDay: _getTimeOfDay(),
      );
      
      emit(PromptGenerated(prompt: prompt));
    } catch (e) {
      // Fallback to default prompt
      emit(PromptGenerated(
        prompt: JournalPrompt(
          prompt: _getDefaultPrompt(event.type),
          type: event.type,
        ),
      ));
    }
  }
  
  Future<void> _onStartEntry(
    StartJournalEntry event,
    Emitter<JournalState> emit,
  ) async {
    emit(JournalWritingState(
      type: event.type,
      prompt: event.prompt,
      startTime: DateTime.now(),
    ));
  }
  
  Future<void> _onSaveEntry(
    SaveJournalEntry event,
    Emitter<JournalState> emit,
  ) async {
    try {
      // Save the entry
      final entry = await _journalRepository.saveJournalEntry(
        content: event.content,
        type: event.type,
        prompt: event.prompt,
        writingDurationSeconds: event.writingDurationSeconds,
        richTextDelta: event.richTextDelta,
      );
      
      emit(JournalEntrySaved(
        entry: entry,
        isAnalyzing: event.analyzeWithAI,
      ));
      
      // Analyze with AI if requested
      if (event.analyzeWithAI) {
        try {
          final analysis = await _aiService.analyzeJournalEntry(entry);
          
          // Update entry with analysis
          final updatedEntry = entry.copyWith(
            aiAnalysis: analysis.insight,
            themes: analysis.themes,
            emotions: analysis.emotions,
            derivedMoodScore: analysis.moodScore,
          );
          
          await _journalRepository.updateJournalEntry(updatedEntry);
          
          emit(JournalEntryAnalyzed(
            entry: updatedEntry,
            analysis: analysis,
          ));
        } catch (e) {
          // Analysis failed but entry was saved
          emit(JournalEntrySaved(entry: entry, isAnalyzing: false));
        }
      }
    } catch (e) {
      emit(JournalError(message: 'Failed to save journal entry: $e'));
    }
  }
  
  Future<void> _onAnalyzeEntry(
    AnalyzeEntry event,
    Emitter<JournalState> emit,
  ) async {
    // Don't emit JournalLoading here - it interferes with other operations
    // Analysis runs in background and will emit result when done
    
    try {
      final entry = await _journalRepository.getJournalEntryById(event.entryId);
      if (entry == null) {
        // Entry not found, just load all entries
        final entries = await _journalRepository.getJournalEntries();
        final statistics = await _journalRepository.getStatistics();
        emit(JournalEntriesLoaded(entries: entries, statistics: statistics));
        return;
      }
      
      final analysis = await _aiService.analyzeJournalEntry(entry);
      
      // Update entry with analysis
      final updatedEntry = entry.copyWith(
        aiAnalysis: analysis.insight,
        themes: analysis.themes,
        emotions: analysis.emotions,
        derivedMoodScore: analysis.moodScore,
      );
      
      await _journalRepository.updateJournalEntry(updatedEntry);
      
      emit(JournalEntryAnalyzed(
        entry: updatedEntry,
        analysis: analysis,
      ));
    } catch (e) {
      // On error, just load entries so user still sees their journal
      // The analysis failed but the entry was already saved
      final entries = await _journalRepository.getJournalEntries();
      final statistics = await _journalRepository.getStatistics();
      emit(JournalEntriesLoaded(entries: entries, statistics: statistics));
    }
  }
  
  Future<void> _onDeleteEntry(
    DeleteJournalEntry event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _journalRepository.deleteJournalEntry(event.entryId);
      emit(JournalEntryDeleted(entryId: event.entryId));
    } catch (e) {
      emit(JournalError(message: 'Failed to delete entry: $e'));
    }
  }
  
  Future<void> _onLoadStatistics(
    LoadJournalStatistics event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());
    
    try {
      final statistics = await _journalRepository.getStatistics();
      final recentThemes = await _journalRepository.getRecentThemes();
      
      emit(JournalStatisticsLoaded(
        statistics: statistics,
        recentThemes: recentThemes,
      ));
    } catch (e) {
      emit(JournalError(message: 'Failed to load statistics: $e'));
    }
  }
  
  Future<void> _onLoadRecentThemes(
    LoadRecentThemes event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final recentThemes = await _journalRepository.getRecentThemes();
      final statistics = await _journalRepository.getStatistics();
      
      emit(JournalStatisticsLoaded(
        statistics: statistics,
        recentThemes: recentThemes,
      ));
    } catch (e) {
      emit(JournalError(message: 'Failed to load themes: $e'));
    }
  }
  
  void _onUpdateContent(
    UpdateEntryContent event,
    Emitter<JournalState> emit,
  ) {
    if (state is JournalWritingState) {
      final currentState = state as JournalWritingState;
      final wordCount = event.content
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;
      
      emit(currentState.copyWith(
        currentContent: event.content,
        wordCount: wordCount,
      ));
    }
  }

  Future<void> _onSearchEntries(
    SearchJournalEntries event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());
    
    try {
      final entries = await _journalRepository.searchEntries(
        query: event.query,
        filterType: event.filterType,
        filterMoodTags: event.filterMoodTags,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(JournalSearchResults(
        entries: entries,
        query: event.query,
        filterType: event.filterType,
        filterMoodTags: event.filterMoodTags,
        totalResults: entries.length,
      ));
    } catch (e) {
      emit(JournalError(message: 'Failed to search entries: $e'));
    }
  }

  Future<void> _onUpdateEntry(
    UpdateJournalEntry event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final updatedEntry = await _journalRepository.updateEntryWithDetails(
        entryId: event.entryId,
        content: event.content,
        richTextDelta: event.richTextDelta,
        moodTags: event.moodTags,
      );
      
      emit(JournalEntryUpdated(entry: updatedEntry));
    } catch (e) {
      emit(JournalError(message: 'Failed to update entry: $e'));
    }
  }

  Future<void> _onClearFilters(
    ClearJournalFilters event,
    Emitter<JournalState> emit,
  ) async {
    add(const LoadJournalEntries());
  }
  
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
  
  String _getDefaultPrompt(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.free:
        return 'What\'s on your mind right now?';
      case JournalEntryType.prompted:
        return 'Describe a moment today when you felt present.';
      case JournalEntryType.gratitude:
        return 'What are three things you\'re grateful for today?';
      case JournalEntryType.reflection:
        return 'What\'s one thing you learned about yourself recently?';
      case JournalEntryType.goalSetting:
        return 'What\'s one small step you can take toward your goals?';
      case JournalEntryType.emotionExplorer:
        return 'What emotion are you experiencing most strongly right now?';
    }
  }
}
