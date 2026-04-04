import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// Chat events for BLoC
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Send a new message
class SendMessage extends ChatEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Load a conversation
class LoadConversation extends ChatEvent {
  final String? conversationId;

  const LoadConversation({this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

/// Start a new conversation
class StartNewConversation extends ChatEvent {
  const StartNewConversation();
}

/// Clear all conversations
class ClearHistory extends ChatEvent {
  const ClearHistory();
}

/// Update crisis state
class CrisisDetected extends ChatEvent {
  final CrisisSeverity severity;

  const CrisisDetected(this.severity);

  @override
  List<Object?> get props => [severity];
}

/// Dismiss crisis alert
class DismissCrisisAlert extends ChatEvent {
  const DismissCrisisAlert();
}

/// Retry failed message
class RetryLastMessage extends ChatEvent {
  const RetryLastMessage();
}

/// Edit a message
class EditMessage extends ChatEvent {
  final String messageId;
  final String newContent;

  const EditMessage({required this.messageId, required this.newContent});

  @override
  List<Object?> get props => [messageId, newContent];
}

/// Delete a message
class DeleteMessage extends ChatEvent {
  final String messageId;

  const DeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Copy message to clipboard (handled in UI)
class CopyMessage extends ChatEvent {
  final String content;

  const CopyMessage({required this.content});

  @override
  List<Object?> get props => [content];
}

/// Stream AI response (for progressive text display)
class StreamAiResponse extends ChatEvent {
  final String message;

  const StreamAiResponse(this.message);

  @override
  List<Object?> get props => [message];
}

/// Update streaming response
class UpdateStreamingResponse extends ChatEvent {
  final String partialContent;

  const UpdateStreamingResponse(this.partialContent);

  @override
  List<Object?> get props => [partialContent];
}

/// Complete streaming response
class CompleteStreamingResponse extends ChatEvent {
  final String content;
  final AIResponse aiResponse;

  const CompleteStreamingResponse({
    required this.content,
    required this.aiResponse,
  });

  @override
  List<Object?> get props => [content, aiResponse];
}

