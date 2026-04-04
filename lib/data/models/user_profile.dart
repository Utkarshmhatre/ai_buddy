import 'package:uuid/uuid.dart';

/// User profile with pseudonymous identity (privacy-first)
class UserProfile {
  final String id;
  final String displayName; // Pseudonymous name
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final UserPreferences preferences;
  final List<String>? supportTopics; // Topics user wants to discuss
  final Map<String, dynamic>? metadata;

  UserProfile({
    String? id,
    required this.displayName,
    DateTime? createdAt,
    this.lastActiveAt,
    UserPreferences? preferences,
    this.supportTopics,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        preferences = preferences ?? UserPreferences();

  /// Convert to JSON for encrypted storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'preferences': preferences.toJson(),
        'supportTopics': supportTopics,
        'metadata': metadata,
      };

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      supportTopics: (json['supportTopics'] as List<dynamic>?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    UserPreferences? preferences,
    List<String>? supportTopics,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      supportTopics: supportTopics ?? this.supportTopics,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// User preferences for AI companion behavior
class UserPreferences {
  final bool darkMode;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final bool dailyCheckInReminder;
  final String? checkInTime; // HH:mm format
  final AITone aiTone;
  final bool showEmotionGifs;
  final bool hapticFeedback;
  final double textScaleFactor;
  final bool reducedMotion;
  final bool highContrast;

  UserPreferences({
    this.darkMode = false,
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.dailyCheckInReminder = true,
    this.checkInTime = '09:00',
    this.aiTone = AITone.supportive,
    this.showEmotionGifs = true,
    this.hapticFeedback = true,
    this.textScaleFactor = 1.0,
    this.reducedMotion = false,
    this.highContrast = false,
  });

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'biometricEnabled': biometricEnabled,
        'notificationsEnabled': notificationsEnabled,
        'dailyCheckInReminder': dailyCheckInReminder,
        'checkInTime': checkInTime,
        'aiTone': aiTone.name,
        'showEmotionGifs': showEmotionGifs,
        'hapticFeedback': hapticFeedback,
        'textScaleFactor': textScaleFactor,
        'reducedMotion': reducedMotion,
        'highContrast': highContrast,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyCheckInReminder: json['dailyCheckInReminder'] as bool? ?? true,
      checkInTime: json['checkInTime'] as String? ?? '09:00',
      aiTone: AITone.values.firstWhere(
        (e) => e.name == json['aiTone'],
        orElse: () => AITone.supportive,
      ),
      showEmotionGifs: json['showEmotionGifs'] as bool? ?? true,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      highContrast: json['highContrast'] as bool? ?? false,
    );
  }

  UserPreferences copyWith({
    bool? darkMode,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? dailyCheckInReminder,
    String? checkInTime,
    AITone? aiTone,
    bool? showEmotionGifs,
    bool? hapticFeedback,
    double? textScaleFactor,
    bool? reducedMotion,
    bool? highContrast,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyCheckInReminder: dailyCheckInReminder ?? this.dailyCheckInReminder,
      checkInTime: checkInTime ?? this.checkInTime,
      aiTone: aiTone ?? this.aiTone,
      showEmotionGifs: showEmotionGifs ?? this.showEmotionGifs,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

/// AI tone preferences for personalization
enum AITone {
  gentle('Gentle & Nurturing'),
  supportive('Supportive & Warm'),
  motivational('Motivational & Energizing'),
  professional('Professional & Balanced'),
  casual('Casual & Friendly');

  final String label;
  const AITone(this.label);
}
