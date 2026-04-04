import 'package:uuid/uuid.dart';
import 'ai_response.dart';

/// Message sender type
enum MessageSender {
  user,
  ai,
  system,
}

/// Individual chat message
class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final AIResponse? aiResponse; // Only for AI messages with emotion data
  final bool isLoading;

  ChatMessage({
    String? id,
    required this.content,
    required this.sender,
    DateTime? timestamp,
    this.aiResponse,
    this.isLoading = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Create a user message
  factory ChatMessage.user(String content) {
    return ChatMessage(
      content: content,
      sender: MessageSender.user,
    );
  }

  /// Create an AI message with emotion data
  factory ChatMessage.ai(AIResponse response) {
    return ChatMessage(
      content: response.message,
      sender: MessageSender.ai,
      aiResponse: response,
    );
  }

  /// Create a loading placeholder message
  factory ChatMessage.loading() {
    return ChatMessage(
      content: '',
      sender: MessageSender.ai,
      isLoading: true,
    );
  }

  /// Create a system message (e.g., crisis resources)
  factory ChatMessage.system(String content) {
    return ChatMessage(
      content: content,
      sender: MessageSender.system,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'aiResponse': aiResponse?.toJson(),
        'isLoading': isLoading,
      };

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      aiResponse: json['aiResponse'] != null
          ? AIResponse.fromGeminiJson(json['aiResponse'] as Map<String, dynamic>)
          : null,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    AIResponse? aiResponse,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      aiResponse: aiResponse ?? this.aiResponse,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Conversation session containing multiple messages
class Conversation {
  final String id;
  final String? title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  Conversation({
    String? id,
    this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Generate a title from the first user message
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    
    final firstUserMessage = messages.firstWhere(
      (m) => m.sender == MessageSender.user,
      orElse: () => ChatMessage.user('New Conversation'),
    );
    
    final content = firstUserMessage.content;
    if (content.length <= 50) return content;
    return '${content.substring(0, 47)}...';
  }

  /// Add a message to the conversation
  Conversation addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Update the last message (useful for replacing loading state)
  Conversation updateLastMessage(ChatMessage message) {
    if (messages.isEmpty) return addMessage(message);
    
    final updatedMessages = [...messages];
    updatedMessages[updatedMessages.length - 1] = message;
    
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'metadata': metadata,
      };

  /// Create from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String?,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
