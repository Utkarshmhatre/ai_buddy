/// Emotion types for AI response GIF selection
/// Each emotion has 3 intensity levels with corresponding GIF assets
enum EmotionType {
  empathetic,
  encouraging,
  calm,
  celebratory,
  thoughtful,
  supportive,
}

/// Intensity levels for emotion GIFs
enum EmotionIntensity {
  low,
  medium,
  high,
}

/// Emotion class that maps to specific GIF assets
class Emotion {
  final EmotionType type;
  final EmotionIntensity intensity;

  const Emotion({
    required this.type,
    this.intensity = EmotionIntensity.medium,
  });

  /// Get the asset path for this emotion's GIF
  String get gifAssetPath {
    final typeName = type.name;
    final intensityName = intensity.name;
    return 'assets/gifs/$typeName/$intensityName.gif';
  }

  /// Get a placeholder asset path (for when GIF isn't available)
  String get placeholderAssetPath {
    return 'assets/gifs/${type.name}/placeholder.png';
  }

  /// Get the display name for this emotion
  String get displayName {
    switch (type) {
      case EmotionType.empathetic:
        return 'Understanding';
      case EmotionType.encouraging:
        return 'Encouraging';
      case EmotionType.calm:
        return 'Calming';
      case EmotionType.celebratory:
        return 'Celebrating';
      case EmotionType.thoughtful:
        return 'Thoughtful';
      case EmotionType.supportive:
        return 'Supportive';
    }
  }

  /// Create from JSON (for AI response parsing)
  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      type: EmotionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EmotionType.supportive,
      ),
      intensity: EmotionIntensity.values.firstWhere(
        (e) => e.name == json['intensity'],
        orElse: () => EmotionIntensity.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'intensity': intensity.name,
      };

  @override
  String toString() => 'Emotion($type, $intensity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Emotion &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          intensity == other.intensity;

  @override
  int get hashCode => type.hashCode ^ intensity.hashCode;
}

/// Extension to parse emotion from AI response string
extension EmotionParsing on String {
  EmotionType? toEmotionType() {
    final lowercased = toLowerCase();
    for (final type in EmotionType.values) {
      if (lowercased.contains(type.name)) {
        return type;
      }
    }
    return null;
  }

  EmotionIntensity? toEmotionIntensity() {
    final lowercased = toLowerCase();
    for (final intensity in EmotionIntensity.values) {
      if (lowercased.contains(intensity.name)) {
        return intensity;
      }
    }
    return null;
  }
}
