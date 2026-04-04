import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// Chat states for BLoC
enum ChatStatus {
  initial,
  loading,
  loaded,
  sending,
  streaming,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final Conversation? conversation;
  final String? error;
  final CrisisSeverity? activeCrisis;
  final bool showCrisisAlert;
  final String? lastFailedMessage;
  final String? streamingContent;
  final String? editingMessageId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.error,
    this.activeCrisis,
    this.showCrisisAlert = false,
    this.lastFailedMessage,
    this.streamingContent,
    this.editingMessageId,
  });

  /// Helper getters
  List<ChatMessage> get messages => conversation?.messages ?? [];
  bool get isLoading => status == ChatStatus.loading;
  bool get isSending => status == ChatStatus.sending;
  bool get isStreaming => status == ChatStatus.streaming;
  bool get hasError => status == ChatStatus.error;
  bool get isEmpty => messages.isEmpty;
  bool get hasCrisis => 
      activeCrisis != null && 
      (activeCrisis == CrisisSeverity.high || 
       activeCrisis == CrisisSeverity.critical);

  ChatState copyWith({
    ChatStatus? status,
    Conversation? conversation,
    String? error,
    CrisisSeverity? activeCrisis,
    bool? showCrisisAlert,
    String? lastFailedMessage,
    String? streamingContent,
    String? editingMessageId,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      error: error,
      activeCrisis: activeCrisis ?? this.activeCrisis,
      showCrisisAlert: showCrisisAlert ?? this.showCrisisAlert,
      lastFailedMessage: lastFailedMessage ?? this.lastFailedMessage,
      streamingContent: streamingContent ?? this.streamingContent,
      editingMessageId: editingMessageId ?? this.editingMessageId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        conversation,
        error,
        activeCrisis,
        showCrisisAlert,
        lastFailedMessage,
        streamingContent,
        editingMessageId,
      ];
}
