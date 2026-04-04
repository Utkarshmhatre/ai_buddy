import 'package:isar/isar.dart';

part 'conversation_entity.g.dart';

/// Isar collection for storing conversations
@collection
class ConversationEntity {
  Id id = Isar.autoIncrement;

  /// Unique conversation identifier
  @Index(unique: true)
  late String conversationId;

  /// Conversation title (optional)
  String? title;

  /// When the conversation was created
  @Index()
  late DateTime createdAt;

  /// When the conversation was last updated
  @Index()
  late DateTime updatedAt;

  /// Whether this is the active conversation
  @Index()
  late bool isActive;

  /// User's preferred name (for personalization)
  String? userName;

  /// Detected mood trend across the conversation
  String? moodTrend;

  /// Topics discussed (serialized JSON array)
  String? topicsJson;

  /// Constructor
  ConversationEntity();

  /// Create from domain model values
  factory ConversationEntity.create({
    required String conversationId,
    String? title,
    String? userName,
    String? moodTrend,
    List<String>? topics,
  }) {
    final entity = ConversationEntity()
      ..conversationId = conversationId
      ..title = title
      ..userName = userName
      ..moodTrend = moodTrend
      ..topicsJson = topics?.join('|||')
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isActive = true;
    return entity;
  }

  /// Get topics as list
  List<String> get topics {
    if (topicsJson == null || topicsJson!.isEmpty) return [];
    return topicsJson!.split('|||');
  }

  /// Set topics from list
  set topics(List<String> value) {
    topicsJson = value.join('|||');
  }
}
