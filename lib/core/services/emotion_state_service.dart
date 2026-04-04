import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists and streams the latest AI aura emotion state.
class EmotionStateService {
  EmotionStateService._();

  static final EmotionStateService instance = EmotionStateService._();

  static const String _emotionKey = 'aura_last_emotion';
  static const String _intensityKey = 'aura_last_intensity';
  static const String _timestampKey = 'aura_last_timestamp';

  static const String defaultEmotion = 'supportive';
  static const double defaultIntensity = 0.3;
  static const Duration _staleAfter = Duration(hours: 6);

  final StreamController<({String emotion, double intensity})> _controller =
      StreamController<({String emotion, double intensity})>.broadcast();

  /// Emits whenever [update] persists a new emotion state.
  Stream<({String emotion, double intensity})> watch() => _controller.stream;

  /// Returns true if stored emotion is older than 6 hours or missing.
  Future<bool> isStale() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampMillis = prefs.getInt(_timestampKey);

    if (timestampMillis == null) {
      return true;
    }

    final lastTimestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    return DateTime.now().difference(lastTimestamp) > _staleAfter;
  }

  /// Returns the current emotion, defaulting when stale.
  Future<String> currentEmotion() async {
    if (await isStale()) {
      return defaultEmotion;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emotionKey) ?? defaultEmotion;
  }

  /// Returns the current intensity, defaulting when stale.
  Future<double> currentIntensity() async {
    if (await isStale()) {
      return defaultIntensity;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedIntensity = prefs.getDouble(_intensityKey) ?? defaultIntensity;
    return _normalizeIntensity(storedIntensity);
  }

  /// Persists latest emotion and updates timestamp.
  Future<void> update(String emotion, double intensity) async {
    final safeEmotion = emotion.trim().isEmpty
        ? defaultEmotion
        : emotion.trim();
    final safeIntensity = _normalizeIntensity(intensity);
    final nowMillis = DateTime.now().millisecondsSinceEpoch;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emotionKey, safeEmotion);
    await prefs.setDouble(_intensityKey, safeIntensity);
    await prefs.setInt(_timestampKey, nowMillis);

    _controller.add((emotion: safeEmotion, intensity: safeIntensity));
  }

  /// Resets persisted emotion to default and emits if data is stale.
  Future<void> checkAndResetIfStale() async {
    if (await isStale()) {
      await update(defaultEmotion, defaultIntensity);
    }
  }

  double _normalizeIntensity(double intensity) {
    if (!intensity.isFinite) {
      return defaultIntensity;
    }

    if (intensity < 0) {
      return 0;
    }

    if (intensity > 1) {
      return 1;
    }

    return intensity;
  }
}
