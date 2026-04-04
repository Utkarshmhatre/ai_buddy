import 'package:isar/isar.dart';

part 'user_profile_entity.g.dart';

/// Isar collection for storing user profile (pseudonymous)
@collection
class UserProfileEntity {
  Id id = Isar.autoIncrement;

  /// Device-generated UUID (pseudonymous identity)
  @Index(unique: true)
  late String deviceId;

  /// User's preferred name (optional, for personalization)
  String? preferredName;

  /// Communication preference: 'concise', 'detailed', 'balanced'
  late String communicationStyle;

  /// Goals (serialized)
  String? goalsJson;

  /// Topics to handle sensitively (serialized)
  String? sensitiveTopicsJson;

  /// Timezone
  String? timezone;

  /// When the profile was created
  late DateTime createdAt;

  /// When the profile was last updated
  late DateTime updatedAt;

  /// Has completed onboarding
  late bool onboardingComplete;

  /// Preferred theme: 'light', 'dark', 'system'
  late String themePreference;

  /// Whether to show emotion GIFs
  late bool showEmotionGifs;

  /// Whether notifications are enabled
  late bool notificationsEnabled;

  /// Current streak (days)
  late int currentStreak;

  /// Longest streak (days)
  late int longestStreak;

  /// Last active date
  DateTime? lastActiveDate;

  /// Constructor
  UserProfileEntity();

  /// Create new profile
  factory UserProfileEntity.create({
    required String deviceId,
    String? preferredName,
  }) {
    final now = DateTime.now();
    final entity = UserProfileEntity()
      ..deviceId = deviceId
      ..preferredName = preferredName
      ..communicationStyle = 'balanced'
      ..goalsJson = null
      ..sensitiveTopicsJson = null
      ..timezone = DateTime.now().timeZoneName
      ..createdAt = now
      ..updatedAt = now
      ..onboardingComplete = false
      ..themePreference = 'system'
      ..showEmotionGifs = true
      ..notificationsEnabled = false
      ..currentStreak = 0
      ..longestStreak = 0
      ..lastActiveDate = now;
    return entity;
  }

  /// Get goals as list
  List<String> get goals {
    if (goalsJson == null || goalsJson!.isEmpty) return [];
    return goalsJson!.split('|||');
  }

  /// Set goals from list
  set goals(List<String> value) {
    goalsJson = value.join('|||');
  }

  /// Get sensitive topics as list
  List<String> get sensitiveTopics {
    if (sensitiveTopicsJson == null || sensitiveTopicsJson!.isEmpty) return [];
    return sensitiveTopicsJson!.split('|||');
  }

  /// Set sensitive topics from list
  set sensitiveTopics(List<String> value) {
    sensitiveTopicsJson = value.join('|||');
  }
}
