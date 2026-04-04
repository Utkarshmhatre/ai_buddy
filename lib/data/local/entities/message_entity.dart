import 'package:isar/isar.dart';

part 'message_entity.g.dart';

/// Isar collection for storing chat messages
@collection
class MessageEntity {
  Id id = Isar.autoIncrement;

  /// Unique message identifier
  @Index(unique: true)
  late String messageId;

  /// Foreign key to conversation
  @Index()
  late String conversationId;

  /// Message content (may be encrypted)
  late String content;

  /// Whether content is encrypted
  late bool isEncrypted;

  /// Sender type: 'user', 'ai', 'system'
  @Index()
  late String sender;

  /// When the message was created
  @Index()
  late DateTime timestamp;

  // AI Response fields (for AI messages)
  
  /// AI emotion type: empathetic, encouraging, calm, etc.
  String? emotionType;

  /// AI emotion intensity: low, medium, high
  String? emotionIntensity;

  /// Crisis level detected (0-5)
  int? crisisLevel;

  /// Suggested actions (serialized)
  String? suggestedActionsJson;

  /// Therapeutic technique used
  String? therapeuticTechnique;

  /// Constructor
  MessageEntity();

  /// Create from values
  factory MessageEntity.create({
    required String messageId,
    required String conversationId,
    required String content,
    required String sender,
    bool isEncrypted = false,
    String? emotionType,
    String? emotionIntensity,
    int? crisisLevel,
    List<String>? suggestedActions,
    String? therapeuticTechnique,
  }) {
    final entity = MessageEntity()
      ..messageId = messageId
      ..conversationId = conversationId
      ..content = content
      ..sender = sender
      ..isEncrypted = isEncrypted
      ..emotionType = emotionType
      ..emotionIntensity = emotionIntensity
      ..crisisLevel = crisisLevel
      ..suggestedActionsJson = suggestedActions?.join('|||')
      ..therapeuticTechnique = therapeuticTechnique
      ..timestamp = DateTime.now();
    return entity;
  }

  /// Get suggested actions as list
  List<String>? get suggestedActions {
    if (suggestedActionsJson == null || suggestedActionsJson!.isEmpty) return null;
    return suggestedActionsJson!.split('|||');
  }

  /// Set suggested actions from list
  set suggestedActions(List<String>? value) {
    suggestedActionsJson = value?.join('|||');
  }
}
