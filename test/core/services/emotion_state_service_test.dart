import 'package:ai_buddy/core/services/emotion_state_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmotionStateService', () {
    final service = EmotionStateService.instance;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isStale returns true when timestamp is older than 6 hours', () async {
      SharedPreferences.setMockInitialValues({
        'aura_last_emotion': 'calm',
        'aura_last_intensity': 0.6,
        'aura_last_timestamp': DateTime.now()
            .subtract(const Duration(hours: 7))
            .millisecondsSinceEpoch,
      });

      expect(await service.isStale(), isTrue);
    });

    test('isStale returns false for fresh timestamp', () async {
      SharedPreferences.setMockInitialValues({
        'aura_last_emotion': 'empathetic',
        'aura_last_intensity': 0.8,
        'aura_last_timestamp': DateTime.now()
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch,
      });

      expect(await service.isStale(), isFalse);
    });

    test('update persists emotion and intensity', () async {
      await service.update('thoughtful', 0.7);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('aura_last_emotion'), 'thoughtful');
      expect(prefs.getDouble('aura_last_intensity'), 0.7);
      expect(prefs.getInt('aura_last_timestamp'), isNotNull);
    });

    test('currentEmotion returns default after stale', () async {
      SharedPreferences.setMockInitialValues({
        'aura_last_emotion': 'celebratory',
        'aura_last_intensity': 0.9,
        'aura_last_timestamp': DateTime.now()
            .subtract(const Duration(hours: 8))
            .millisecondsSinceEpoch,
      });

      expect(
        await service.currentEmotion(),
        EmotionStateService.defaultEmotion,
      );
    });
  });
}
