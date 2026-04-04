import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/safety/crisis_detection_service.dart';
import '../../../core/services/emotion_state_service.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// Chat BLoC for managing conversation state with persistence
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiService _geminiService;
  final EnhancedGeminiService? _enhancedService;
  final ChatRepository? _chatRepository;

  ChatBloc({
    required GeminiService geminiService,
    EnhancedGeminiService? enhancedService,
    ChatRepository? chatRepository,
  }) : _geminiService = geminiService,
       _enhancedService = enhancedService,
       _chatRepository = chatRepository,
       super(const ChatState()) {
    on<LoadConversation>(_onLoadConversation);
    on<StartNewConversation>(_onStartNewConversation);
    on<SendMessage>(_onSendMessage);
    on<ClearHistory>(_onClearHistory);
    on<CrisisDetected>(_onCrisisDetected);
    on<DismissCrisisAlert>(_onDismissCrisisAlert);
    on<RetryLastMessage>(_onRetryLastMessage);
    on<EditMessage>(_onEditMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<StreamAiResponse>(_onStreamAiResponse);
    on<UpdateStreamingResponse>(_onUpdateStreamingResponse);
    on<CompleteStreamingResponse>(_onCompleteStreamingResponse);
  }

  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      Conversation conversation;

      if (_chatRepository != null) {
        // Load from persistent storage
        conversation = await _chatRepository.getOrCreateActiveConversation();

        // Restore conversation history in Gemini service
        if (conversation.messages.isNotEmpty) {
          final historyMessages = conversation.messages
              .where((m) => m.sender != MessageSender.system)
              .map(
                (m) => {
                  'content': m.sender == MessageSender.user
                      ? m.content
                      : (m.aiResponse?.message ?? m.content),
                  'isUser': m.sender == MessageSender.user,
                },
              )
              .toList();
          _geminiService.startSessionWithHistory(historyMessages);
        } else {
          _geminiService.startNewSession();
        }
      } else {
        // In-memory only
        conversation = Conversation();
        _geminiService.startNewSession();
      }

      emit(
        state.copyWith(status: ChatStatus.loaded, conversation: conversation),
      );
    } catch (e) {
      // Fallback to empty conversation
      _geminiService.startNewSession();
      emit(
        state.copyWith(status: ChatStatus.loaded, conversation: Conversation()),
      );
    }
  }

  Future<void> _onStartNewConversation(
    StartNewConversation event,
    Emitter<ChatState> emit,
  ) async {
    _geminiService.clearHistory();
    _geminiService.startNewSession();

    Conversation newConversation;

    if (_chatRepository != null) {
      // Create new persisted conversation
      newConversation = await _chatRepository.createConversation();
    } else {
      newConversation = Conversation();
    }

    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        conversation: newConversation,
        activeCrisis: null,
        showCrisisAlert: false,
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    final userMessage = ChatMessage.user(event.message);
    final conversation = state.conversation ?? Conversation();

    // Add user message and loading indicator
    var updatedConversation = conversation
        .addMessage(userMessage)
        .addMessage(ChatMessage.loading());

    emit(
      state.copyWith(
        status: ChatStatus.sending,
        conversation: updatedConversation,
        lastFailedMessage: event.message,
      ),
    );

    // Persist user message
    if (_chatRepository != null) {
      await _chatRepository.saveMessage(
        conversationId: conversation.id,
        content: event.message,
        sender: MessageSender.user,
      );
    }

    try {
      // Enhanced local crisis detection (Layer 1) - now with comprehensive patterns
      final localCrisisLevel = _getLocalCrisisSeverity(event.message);

      // Get AI response
      final aiResponse = await _geminiService.sendMessage(event.message);

      // Use higher crisis level between local check and AI assessment
      var crisisLevel = aiResponse.crisisSeverity;
      if (localCrisisLevel.index > crisisLevel.index) {
        crisisLevel = localCrisisLevel;
      }

      // Perform multi-layer crisis assessment (Layers 2-4) if any concern detected
      if (crisisLevel != CrisisSeverity.none) {
        crisisLevel = await _performMultiLayerCrisisAssessment(
          event.message,
          crisisLevel,
        );
      }

      // Create AI message with emotion data
      final aiMessage = ChatMessage.ai(
        aiResponse.copyWith(crisisSeverity: crisisLevel),
      );

      await _updateEmotionState(aiResponse);

      // Persist AI message
      if (_chatRepository != null) {
        await _chatRepository.saveMessage(
          conversationId: conversation.id,
          content: aiResponse.message,
          sender: MessageSender.ai,
          aiResponse: aiResponse.copyWith(crisisSeverity: crisisLevel),
        );
      }

      // Replace loading message with actual response
      updatedConversation = updatedConversation.updateLastMessage(aiMessage);

      // Add crisis message if needed
      if (crisisLevel == CrisisSeverity.high ||
          crisisLevel == CrisisSeverity.critical) {
        updatedConversation = updatedConversation.addMessage(
          ChatMessage.system(AppConstants.crisisMessage),
        );
      }

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          conversation: updatedConversation,
          activeCrisis: crisisLevel,
          showCrisisAlert:
              crisisLevel == CrisisSeverity.high ||
              crisisLevel == CrisisSeverity.critical,
          lastFailedMessage: null,
        ),
      );
    } catch (e) {
      // Remove loading message and show error
      final messagesWithoutLoading = updatedConversation.messages
          .where((m) => !m.isLoading)
          .toList();

      emit(
        state.copyWith(
          status: ChatStatus.error,
          conversation: updatedConversation.copyWith(
            messages: messagesWithoutLoading,
          ),
          error: 'Failed to send message. Please try again.',
        ),
      );
    }
  }

  /// Get crisis severity from local detection
  CrisisSeverity _getLocalCrisisSeverity(String message) {
    final assessment = CrisisDetectionService.instance.assessText(message);
    return assessment.severity;
  }

  /// Perform multi-layer crisis assessment (Layers 2-4)
  /// Returns enhanced crisis severity based on deeper analysis
  Future<CrisisSeverity> _performMultiLayerCrisisAssessment(
    String message,
    CrisisSeverity basicLevel,
  ) async {
    if (_enhancedService == null) return basicLevel;

    // Only perform deep analysis if there's any concern
    if (basicLevel == CrisisSeverity.none) return basicLevel;

    try {
      // Perform multi-layer assessment (recentMessages passed as named parameter)
      final assessment = await _enhancedService.assessCrisisMultiLayer(message);

      // Map overall risk to CrisisSeverity
      CrisisSeverity enhancedLevel;
      switch (assessment.overallRisk) {
        case 'critical':
          enhancedLevel = CrisisSeverity.critical;
          break;
        case 'high':
          enhancedLevel = CrisisSeverity.high;
          break;
        case 'moderate':
          enhancedLevel = CrisisSeverity.medium;
          break;
        case 'low':
          enhancedLevel = CrisisSeverity.low;
          break;
        default:
          enhancedLevel = CrisisSeverity.none;
      }

      // Return the higher of the two assessments
      return enhancedLevel.index > basicLevel.index
          ? enhancedLevel
          : basicLevel;
    } catch (e) {
      // If deep analysis fails, fall back to basic level
      print('Multi-layer crisis assessment failed: $e');
      return basicLevel;
    }
  }

  Future<void> _onClearHistory(
    ClearHistory event,
    Emitter<ChatState> emit,
  ) async {
    _geminiService.clearHistory();
    emit(const ChatState(status: ChatStatus.initial));
  }

  void _onCrisisDetected(CrisisDetected event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        activeCrisis: event.severity,
        showCrisisAlert:
            event.severity == CrisisSeverity.high ||
            event.severity == CrisisSeverity.critical,
      ),
    );
  }

  void _onDismissCrisisAlert(
    DismissCrisisAlert event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(showCrisisAlert: false));
  }

  Future<void> _onRetryLastMessage(
    RetryLastMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state.lastFailedMessage != null) {
      add(SendMessage(state.lastFailedMessage!));
    }
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<ChatState> emit,
  ) async {
    final conversation = state.conversation;
    if (conversation == null) return;

    // Find and update the message
    final updatedMessages = conversation.messages.map((m) {
      if (m.id == event.messageId && m.sender == MessageSender.user) {
        return ChatMessage(
          id: m.id,
          content: event.newContent,
          sender: MessageSender.user,
          timestamp: m.timestamp,
          isLoading: false,
        );
      }
      return m;
    }).toList();

    // Find the index of the edited message
    final editedIndex = updatedMessages.indexWhere(
      (m) => m.id == event.messageId,
    );

    // Remove all messages after the edited one (including AI responses)
    final truncatedMessages = editedIndex >= 0
        ? updatedMessages.sublist(0, editedIndex + 1)
        : updatedMessages;

    emit(
      state.copyWith(
        conversation: conversation.copyWith(messages: truncatedMessages),
        editingMessageId: null,
      ),
    );

    // Re-send to get new AI response
    add(SendMessage(event.newContent));
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    final conversation = state.conversation;
    if (conversation == null) return;

    // Find the message index
    final messageIndex = conversation.messages.indexWhere(
      (m) => m.id == event.messageId,
    );

    if (messageIndex < 0) return;

    final message = conversation.messages[messageIndex];
    List<ChatMessage> updatedMessages;

    if (message.sender == MessageSender.user) {
      // If deleting a user message, also delete the following AI response
      updatedMessages = [...conversation.messages];
      updatedMessages.removeAt(messageIndex);

      // Check if the next message is from AI and remove it too
      if (messageIndex < updatedMessages.length &&
          updatedMessages[messageIndex].sender == MessageSender.ai) {
        updatedMessages.removeAt(messageIndex);
      }
    } else {
      // Just remove the single message
      updatedMessages = conversation.messages
          .where((m) => m.id != event.messageId)
          .toList();
    }

    // Persist deletion if repository available
    if (_chatRepository != null) {
      await _chatRepository.deleteMessage(event.messageId);
    }

    emit(
      state.copyWith(
        conversation: conversation.copyWith(messages: updatedMessages),
      ),
    );
  }

  Future<void> _onStreamAiResponse(
    StreamAiResponse event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    final userMessage = ChatMessage.user(event.message);
    final conversation = state.conversation ?? Conversation();

    // Add user message
    var updatedConversation = conversation.addMessage(userMessage);

    emit(
      state.copyWith(
        status: ChatStatus.streaming,
        conversation: updatedConversation,
        streamingContent: '',
        lastFailedMessage: event.message,
      ),
    );

    // Persist user message
    if (_chatRepository != null) {
      await _chatRepository.saveMessage(
        conversationId: conversation.id,
        content: event.message,
        sender: MessageSender.user,
      );
    }

    try {
      // Use streaming API if available
      final response = await _geminiService.sendMessage(event.message);

      // Complete the streaming
      add(
        CompleteStreamingResponse(
          content: response.message,
          aiResponse: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          streamingContent: null,
          error: 'Failed to get response. Please try again.',
        ),
      );
    }
  }

  void _onUpdateStreamingResponse(
    UpdateStreamingResponse event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(streamingContent: event.partialContent));
  }

  Future<void> _onCompleteStreamingResponse(
    CompleteStreamingResponse event,
    Emitter<ChatState> emit,
  ) async {
    final conversation = state.conversation;
    if (conversation == null) return;

    // Create AI message with emotion data
    final aiMessage = ChatMessage.ai(event.aiResponse);

    // Add AI message to conversation
    final updatedConversation = conversation.addMessage(aiMessage);

    // Persist AI message
    if (_chatRepository != null) {
      await _chatRepository.saveMessage(
        conversationId: conversation.id,
        content: event.content,
        sender: MessageSender.ai,
        aiResponse: event.aiResponse,
      );
    }

    // Check for crisis
    final crisisLevel = event.aiResponse.crisisSeverity;
    var finalConversation = updatedConversation;

    await _updateEmotionState(event.aiResponse);

    if (crisisLevel == CrisisSeverity.high ||
        crisisLevel == CrisisSeverity.critical) {
      finalConversation = updatedConversation.addMessage(
        ChatMessage.system(AppConstants.crisisMessage),
      );
    }

    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        conversation: finalConversation,
        streamingContent: null,
        activeCrisis: crisisLevel,
        showCrisisAlert:
            crisisLevel == CrisisSeverity.high ||
            crisisLevel == CrisisSeverity.critical,
        lastFailedMessage: null,
      ),
    );
  }

  Future<void> _updateEmotionState(AIResponse response) async {
    try {
      await EmotionStateService.instance.update(
        response.emotion.type.name,
        _emotionIntensityToValue(response.emotion.intensity),
      );
    } catch (e) {
      debugPrint('Failed to persist aura emotion: $e');
    }
  }

  double _emotionIntensityToValue(EmotionIntensity intensity) {
    switch (intensity) {
      case EmotionIntensity.low:
        return 0.3;
      case EmotionIntensity.medium:
        return 0.6;
      case EmotionIntensity.high:
        return 0.9;
    }
  }

  @override
  Future<void> close() {
    _geminiService.dispose();
    return super.close();
  }
}
