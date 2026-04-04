import 'package:uuid/uuid.dart';
import 'emotion.dart';

/// Crisis severity levels for safety features
enum CrisisSeverity {
  none,
  low,      // Monitoring needed
  medium,   // Gentle intervention
  high,     // Show resources
  critical, // Immediate resources + contact prompt
}

/// AI Response model with emotion tagging for GIF display
class AIResponse {
  final String id;
  final String message;
  final Emotion emotion;
  final CrisisSeverity crisisSeverity;
  final List<String>? suggestedActions;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  AIResponse({
    String? id,
    required this.message,
    required this.emotion,
    this.crisisSeverity = CrisisSeverity.none,
    this.suggestedActions,
    this.metadata,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Factory constructor to parse structured JSON from Gemini API
  factory AIResponse.fromGeminiJson(Map<String, dynamic> json) {
    // Parse emotion from structured response
    final emotionJson = json['emotion'] as Map<String, dynamic>? ??
        {'type': 'supportive', 'intensity': 'medium'};
    
    // Parse crisis severity
    final crisisLevel = json['crisis_level'] as String? ?? 'none';
    final crisisSeverity = CrisisSeverity.values.firstWhere(
      (e) => e.name == crisisLevel,
      orElse: () => CrisisSeverity.none,
    );

    // Parse suggested actions
    final actionsRaw = json['suggested_actions'];
    List<String>? suggestedActions;
    if (actionsRaw != null) {
      if (actionsRaw is List) {
        suggestedActions = actionsRaw.cast<String>();
      }
    }

    return AIResponse(
      message: json['message'] as String? ?? '',
      emotion: Emotion.fromJson(emotionJson),
      crisisSeverity: crisisSeverity,
      suggestedActions: suggestedActions,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'emotion': emotion.toJson(),
        'crisis_level': crisisSeverity.name,
        'suggested_actions': suggestedActions,
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Create a copy with modified fields
  AIResponse copyWith({
    String? id,
    String? message,
    Emotion? emotion,
    CrisisSeverity? crisisSeverity,
    List<String>? suggestedActions,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return AIResponse(
      id: id ?? this.id,
      message: message ?? this.message,
      emotion: emotion ?? this.emotion,
      crisisSeverity: crisisSeverity ?? this.crisisSeverity,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Check if this response requires crisis intervention UI
  bool get requiresCrisisIntervention =>
      crisisSeverity == CrisisSeverity.high ||
      crisisSeverity == CrisisSeverity.critical;

  @override
  String toString() => 'AIResponse(id: $id, emotion: $emotion, crisis: $crisisSeverity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
