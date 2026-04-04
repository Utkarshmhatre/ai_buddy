import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/journal_repository.dart';

/// Demo data service for presentation purposes
/// Populates the app with realistic dummy data
class DemoDataService {
  static const String _demoModeKey = 'demo_mode_enabled';
  static const String _demoDataLoadedKey = 'demo_data_loaded';

  final ChatRepository? _chatRepository;
  final MoodRepository? _moodRepository;
  final JournalRepository? _journalRepository;

  DemoDataService({
    ChatRepository? chatRepository,
    MoodRepository? moodRepository,
    JournalRepository? journalRepository,
  })  : _chatRepository = chatRepository,
        _moodRepository = moodRepository,
        _journalRepository = journalRepository;

  /// Check if demo mode is enabled
  static Future<bool> isDemoModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_demoModeKey) ?? false;
  }

  /// Enable demo mode and load demo data
  Future<void> enableDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, true);
    
    // Check if demo data was already loaded
    final alreadyLoaded = prefs.getBool(_demoDataLoadedKey) ?? false;
    if (!alreadyLoaded) {
      await loadDemoData();
      await prefs.setBool(_demoDataLoadedKey, true);
    }
  }

  /// Disable demo mode
  static Future<void> disableDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, false);
  }

  /// Load all demo data
  Future<void> loadDemoData() async {
    await _loadDemoMoodEntries();
    await _loadDemoJournalEntries();
    await _loadDemoChatMessages();
    debugPrint('✅ Demo data loaded successfully');
  }

  /// Clear all demo data
  Future<void> clearDemoData() async {
    await _chatRepository?.clearAllMessages();
    await _moodRepository?.clearAllMoodEntries();
    await _journalRepository?.clearAllJournalEntries();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoDataLoadedKey, false);
    await prefs.setBool(_demoModeKey, false);
    debugPrint('✅ Demo data cleared');
  }

  // ============== MOOD ENTRIES ==============

  Future<void> _loadDemoMoodEntries() async {
    if (_moodRepository == null) return;

    final demoMoods = [
      // Variety of moods with notes
      (MoodCategory.grateful, MoodIntensity.high, 'Had a productive morning meditation session. Feeling centered.'),
      (MoodCategory.calm, MoodIntensity.neutral, 'Work was busy but manageable. Took breaks when needed.'),
      (MoodCategory.stressed, MoodIntensity.high, 'Feeling a bit overwhelmed. Need to practice self-care.'),
      (MoodCategory.happy, MoodIntensity.high, 'Great walk in nature today. Really helped clear my mind.'),
      (MoodCategory.calm, MoodIntensity.neutral, 'Average day. Nothing special but not bad either.'),
      (MoodCategory.energetic, MoodIntensity.veryHigh, 'Celebrated a small win at work! Feeling accomplished.'),
      (MoodCategory.calm, MoodIntensity.low, 'Rainy day, stayed cozy inside with a book.'),
      (MoodCategory.happy, MoodIntensity.high, 'Good sleep last night made a big difference!'),
      (MoodCategory.anxious, MoodIntensity.high, 'Anxious about upcoming deadline.'),
      (MoodCategory.loved, MoodIntensity.high, 'Coffee with a friend lifted my spirits.'),
      (MoodCategory.calm, MoodIntensity.neutral, 'Routine day. Trying to maintain balance.'),
      (MoodCategory.hopeful, MoodIntensity.veryHigh, 'Breakthrough in therapy session. Feeling hopeful!'),
      (MoodCategory.calm, MoodIntensity.neutral, 'Started the new breathing exercises.'),
      (MoodCategory.loved, MoodIntensity.high, 'Family video call put a smile on my face.'),
    ];

    for (final mood in demoMoods) {
      await _moodRepository.saveMoodEntry(
        category: mood.$1,
        intensity: mood.$2,
        notes: mood.$3,
      );
      // Small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // ============== JOURNAL ENTRIES ==============

  Future<void> _loadDemoJournalEntries() async {
    if (_journalRepository == null) return;

    final demoJournals = [
      // Journal entry 1: Gratitude
      (
        'What are you grateful for today?',
        '''Today I woke up feeling grateful for the small things. The sun was streaming through my window, and I took a moment to appreciate the warmth.

I've been practicing the gratitude exercises from the app, and I can feel a shift in my perspective. Instead of focusing on what's wrong, I'm starting to notice what's right.

Things I'm grateful for today:
1. A good night's sleep
2. My morning coffee ritual
3. The supportive message from a friend

I want to remember this feeling when the harder days come.''',
        JournalEntryType.gratitude,
        ['gratitude', 'morning', 'reflection'],
        ['grateful', 'peaceful'],
      ),
      // Journal entry 2: Processing
      (
        null,
        '''I had a challenging conversation today that left me feeling unsettled. Writing this out to process...

What happened: A disagreement with a coworker about a project direction.

How I felt: Frustrated, misunderstood, a bit defensive.

What I learned: I tend to take criticism personally, even when it's constructive. This is something I want to work on.

Next time, I'll try to:
- Take a breath before responding
- Ask clarifying questions
- Remember that disagreements aren't personal attacks

It's okay to feel upset. What matters is how I move forward.''',
        JournalEntryType.free,
        ['processing', 'work', 'growth'],
        ['frustrated', 'reflective'],
      ),
      // Journal entry 3: Good day
      (
        'Describe a moment that made you smile today',
        '''Some days are worth documenting just because they were good.

Today was simple but fulfilling:
- Morning yoga session
- Productive work from the café
- Spontaneous lunch with an old friend
- Evening walk in the park

I noticed I didn't check my phone constantly. I was present.

This is what I want more of. Not grand adventures, but small moments of genuine connection and peace.

Note to future self: You CAN have good days. Remember this one.''',
        JournalEntryType.reflection,
        ['good day', 'mindfulness', 'gratitude'],
        ['happy', 'content'],
      ),
      // Journal entry 4: Weekly check-in
      (
        'Weekly reflection: How are you doing overall?',
        '''Time for my weekly self-assessment.

Physical health: 7/10
- Exercised 3 times this week
- Sleep has been irregular
- Eating mostly well, some stress snacking

Mental health: 6/10
- Some anxious moments but managed them
- Used breathing exercises twice
- Talked to AI Buddy when feeling overwhelmed

Social connections: 8/10
- Called mom
- Coffee with Sarah
- Team lunch at work

Goals for next week:
1. Consistent sleep schedule
2. One more workout session
3. Less screen time before bed

Overall, I'm making progress. Not perfect, but progress.''',
        JournalEntryType.reflection,
        ['weekly review', 'goals', 'self-care'],
        ['balanced', 'hopeful'],
      ),
      // Journal entry 5: Coping toolkit
      (
        null,
        '''Creating my personal anxiety toolkit based on what I've learned:

Quick relief (1-5 minutes):
- Box breathing (4-4-4-4)
- 5-4-3-2-1 grounding exercise
- Cold water on wrists
- Step outside for fresh air

Medium relief (15-30 minutes):
- Walk around the block
- Talk to AI Buddy
- Listen to calm playlist
- Do a quick journal entry

Deep work (30+ minutes):
- Full breathing session in the app
- Call a friend
- Exercise
- Take a bath

Keeping this list here so I can reference it when my mind goes blank during anxious moments.''',
        JournalEntryType.free,
        ['anxiety', 'toolkit', 'coping'],
        ['prepared', 'proactive'],
      ),
      // Journal entry 6: Starting journey
      (
        'What brings you here today?',
        '''Day 1 with AI Buddy.

I've been hesitant to try a mental health app, but here I am. A friend recommended it, and I figured it couldn't hurt.

What I hope to get from this:
- A safe space to express my thoughts
- Tools to manage daily stress
- Better understanding of my mood patterns
- Gentle accountability for self-care

I'm not in crisis - just want to be more intentional about my mental wellness. Prevention over intervention, right?

Here goes nothing. Let's see where this journey takes me.''',
        JournalEntryType.reflection,
        ['new beginning', 'hope', 'intentions'],
        ['curious', 'hopeful'],
      ),
    ];

    for (final journal in demoJournals) {
      await _journalRepository.saveJournalEntry(
        prompt: journal.$1,
        content: journal.$2,
        type: journal.$3,
        themes: journal.$4,
        emotions: journal.$5,
      );
      // Small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // ============== CHAT MESSAGES ==============

  Future<void> _loadDemoChatMessages() async {
    if (_chatRepository == null) return;

    final conversationId = 'demo_conversation_1';

    // Demo conversation 1: Initial greeting
    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "Hi, I've been feeling stressed lately and could use someone to talk to.",
      sender: MessageSender.user,
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "I hear you, and I'm glad you reached out. Stress can be really overwhelming, especially when it builds up over time. Would you like to tell me more about what's been causing this stress? Sometimes just expressing it can help lighten the load.",
      sender: MessageSender.ai,
      aiResponse: AIResponse(
        message: "I hear you, and I'm glad you reached out. Stress can be really overwhelming, especially when it builds up over time. Would you like to tell me more about what's been causing this stress? Sometimes just expressing it can help lighten the load.",
        emotion: Emotion(
          type: EmotionType.empathetic,
          intensity: EmotionIntensity.medium,
        ),
        suggestedActions: [
          "Work has been overwhelming",
          "I'm dealing with personal issues",
          "I just feel anxious in general",
        ],
        crisisSeverity: CrisisSeverity.none,
      ),
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "Work has been really demanding. I feel like I can never catch up.",
      sender: MessageSender.user,
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "That constant feeling of playing catch-up can be exhausting. It's like running on a treadmill that keeps speeding up. You're not alone in feeling this way - many people experience work-related stress.\n\nLet's try something: What's one small thing you could let go of or delegate today? Sometimes we take on more than necessary because we feel we 'should.'",
      sender: MessageSender.ai,
      aiResponse: AIResponse(
        message: "That constant feeling of playing catch-up can be exhausting. It's like running on a treadmill that keeps speeding up. You're not alone in feeling this way - many people experience work-related stress.\n\nLet's try something: What's one small thing you could let go of or delegate today? Sometimes we take on more than necessary because we feel we 'should.'",
        emotion: Emotion(
          type: EmotionType.supportive,
          intensity: EmotionIntensity.medium,
        ),
        suggestedActions: [
          "Try a breathing exercise",
          "Help me set boundaries",
          "I need work-life balance tips",
        ],
        crisisSeverity: CrisisSeverity.none,
      ),
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "I'd like to try a breathing exercise",
      sender: MessageSender.user,
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "Great choice! Breathing exercises are wonderful for calming the nervous system. Let me guide you through a simple one:\n\n**Box Breathing (4-4-4-4)**\n\n1. **Inhale** slowly for 4 seconds\n2. **Hold** your breath for 4 seconds\n3. **Exhale** slowly for 4 seconds\n4. **Hold** empty for 4 seconds\n\nRepeat this 4 times. You can also use the Breathing Exercise feature in the app for a guided visual experience!\n\nHow did that feel?",
      sender: MessageSender.ai,
      aiResponse: AIResponse(
        message: "Great choice! Breathing exercises are wonderful for calming the nervous system. Let me guide you through a simple one:\n\n**Box Breathing (4-4-4-4)**\n\n1. **Inhale** slowly for 4 seconds\n2. **Hold** your breath for 4 seconds\n3. **Exhale** slowly for 4 seconds\n4. **Hold** empty for 4 seconds\n\nRepeat this 4 times. You can also use the Breathing Exercise feature in the app for a guided visual experience!\n\nHow did that feel?",
        emotion: Emotion(
          type: EmotionType.calm,
          intensity: EmotionIntensity.low,
        ),
        suggestedActions: [
          "I feel a bit calmer now",
          "Can we try another technique?",
          "Open breathing exercises",
        ],
        crisisSeverity: CrisisSeverity.none,
      ),
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "That actually helped! I feel a bit calmer.",
      sender: MessageSender.user,
    );

    await _chatRepository.saveMessage(
      conversationId: conversationId,
      content: "I'm so glad to hear that! 🎉 It's wonderful that you took a moment for yourself. These small pauses can make a big difference throughout the day.\n\nRemember, you can come back to this breathing technique anytime you feel stressed - in meetings, before difficult conversations, or just when you need a reset.\n\nWould you like to explore more coping strategies, or is there anything else on your mind?",
      sender: MessageSender.ai,
      aiResponse: AIResponse(
        message: "I'm so glad to hear that! 🎉 It's wonderful that you took a moment for yourself. These small pauses can make a big difference throughout the day.\n\nRemember, you can come back to this breathing technique anytime you feel stressed - in meetings, before difficult conversations, or just when you need a reset.\n\nWould you like to explore more coping strategies, or is there anything else on your mind?",
        emotion: Emotion(
          type: EmotionType.celebratory,
          intensity: EmotionIntensity.medium,
        ),
        suggestedActions: [
          "Show me more coping strategies",
          "Help me create a daily routine",
          "I'll check back tomorrow",
        ],
        crisisSeverity: CrisisSeverity.none,
      ),
    );
  }
}
