import 'package:uuid/uuid.dart';

import '../../core/security/database_service.dart';
import '../../core/security/encryption_service.dart';
import '../local/entities/conversation_entity.dart';
import '../local/entities/message_entity.dart';
import '../models/models.dart';

/// Repository for managing chat conversations and messages
class ChatRepository {
  DatabaseService? _databaseService;
  final Uuid _uuid = const Uuid();
  bool _initialized = false;

  ChatRepository();

  /// Initialize with database service
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    try {
      final encryptionService = EncryptionService();
      await encryptionService.initialize();
      _databaseService = await DatabaseService.getInstance(
        encryptionService: encryptionService,
      );
      _initialized = true;
    } catch (e) {
      // Database not available - will use in-memory fallback
      _initialized = false;
    }
  }

  // ==================== Conversation Operations ====================

  /// Create a new conversation
  Future<Conversation> createConversation({String? title}) async {
    await _ensureInitialized();
    
    final conversationId = _uuid.v4();
    
    if (_databaseService != null) {
      final entity = await _databaseService!.createConversation(
        conversationId: conversationId,
        title: title,
      );
      
      return _conversationFromEntity(entity, []);
    }
    
    // Fallback to in-memory conversation
    return Conversation(id: conversationId, title: title);
  }

  /// Get active conversation or create new one
  Future<Conversation> getOrCreateActiveConversation() async {
    await _ensureInitialized();
    
    if (_databaseService == null) {
      return Conversation();
    }
    
    final entity = await _databaseService!.getActiveConversation();
    
    if (entity != null) {
      final messages = await _getMessagesForConversation(entity.conversationId);
      return _conversationFromEntity(entity, messages);
    }
    
    return createConversation();
  }

  /// Get conversation by ID with messages
  Future<Conversation?> getConversation(String conversationId) async {
    await _ensureInitialized();
    
    if (_databaseService == null) return null;
    
    final entity = await _databaseService!.getConversation(conversationId);
    if (entity == null) return null;
    
    final messages = await _getMessagesForConversation(conversationId);
    return _conversationFromEntity(entity, messages);
  }

  /// Get all conversations (without messages for list display)
  Future<List<Conversation>> getAllConversations() async {
    await _ensureInitialized();
    
    if (_databaseService == null) return [];
    
    final entities = await _databaseService!.getAllConversations();
    
    return Future.wait(entities.map((entity) async {
      // Get last message for preview
      final messages = await _databaseService!.getMessages(
        entity.conversationId,
        limit: 1,
      );
      return _conversationFromEntity(
        entity,
        messages.isNotEmpty 
            ? [_messageFromEntity(messages.first)] 
            : [],
      );
    }));
  }

  /// Update conversation metadata
  Future<void> updateConversation(Conversation conversation) async {
    await _ensureInitialized();
    
    if (_databaseService == null) return;
    
    final entity = await _databaseService!.getConversation(conversation.id);
    if (entity == null) return;
    
    entity.title = conversation.title;
    
    await _databaseService!.updateConversation(entity);
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    await _ensureInitialized();
    
    if (_databaseService == null) return;
    
    await _databaseService!.deleteConversation(conversationId);
  }

  // ==================== Message Operations ====================

  /// Save a message to conversation
  Future<ChatMessage> saveMessage({
    required String conversationId,
    required String content,
    required MessageSender sender,
    AIResponse? aiResponse,
  }) async {
    await _ensureInitialized();
    
    final messageId = _uuid.v4();
    
    if (_databaseService != null) {
      await _databaseService!.saveMessage(
        messageId: messageId,
        conversationId: conversationId,
        content: content,
        sender: sender.name,
        encryptContent: true,
        emotionType: aiResponse?.emotion.type.name,
        emotionIntensity: aiResponse?.emotion.intensity.name,
        crisisLevel: aiResponse?.crisisSeverity.index,
        suggestedActions: aiResponse?.suggestedActions,
      );
      
      // Update conversation's updatedAt
      final conversation = await _databaseService!.getConversation(conversationId);
      if (conversation != null) {
        await _databaseService!.updateConversation(conversation);
      }
    }
    
    return ChatMessage(
      id: messageId,
      content: content,
      sender: sender,
      timestamp: DateTime.now(),
      aiResponse: aiResponse,
    );
  }

  /// Get messages for a conversation
  Future<List<ChatMessage>> _getMessagesForConversation(
    String conversationId, {
    int? limit,
  }) async {
    if (_databaseService == null) return [];
    
    final entities = await _databaseService!.getMessages(
      conversationId,
      limit: limit,
    );
    
    return entities.map(_messageFromEntity).toList();
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _ensureInitialized();
    
    if (_databaseService == null) return;
    
    await _databaseService!.deleteMessage(messageId);
  }

  /// Clear all messages and conversations
  Future<void> clearAllMessages() async {
    await _ensureInitialized();
    
    if (_databaseService == null) return;
    
    await _databaseService!.clearAllConversations();
  }

  // ==================== Conversion Helpers ====================

  Conversation _conversationFromEntity(
    ConversationEntity entity,
    List<ChatMessage> messages,
  ) {
    return Conversation(
      id: entity.conversationId,
      messages: messages,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      title: entity.title,
    );
  }

  ChatMessage _messageFromEntity(MessageEntity entity) {
    // Decrypt content if database service available
    final content = _databaseService != null 
        ? _databaseService!.getDecryptedContent(entity)
        : entity.content;
    
    // Reconstruct AIResponse if present
    AIResponse? aiResponse;
    if (entity.emotionType != null) {
      aiResponse = AIResponse(
        message: content,
        emotion: Emotion(
          type: EmotionType.values.firstWhere(
            (e) => e.name == entity.emotionType,
            orElse: () => EmotionType.empathetic,
          ),
          intensity: EmotionIntensity.values.firstWhere(
            (e) => e.name == entity.emotionIntensity,
            orElse: () => EmotionIntensity.medium,
          ),
        ),
        crisisSeverity: CrisisSeverity.values[entity.crisisLevel ?? 0],
        suggestedActions: entity.suggestedActions,
      );
    }
    
    return ChatMessage(
      id: entity.messageId,
      content: content,
      sender: MessageSender.values.firstWhere(
        (s) => s.name == entity.sender,
        orElse: () => MessageSender.user,
      ),
      timestamp: entity.timestamp,
      aiResponse: aiResponse,
    );
  }
}
