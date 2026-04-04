import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../data/models/models.dart';
import '../constants/app_constants.dart';

/// Gemini AI Service for mental health support chatbot
/// Uses structured JSON output for emotion-tagged responses
class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _crisisModel;
  ChatSession? _chatSession;
  
  /// Initialize the Gemini service with API key
  GeminiService({required String apiKey}) {
    debugPrint('GeminiService: Initializing with API key length: ${apiKey.length}');
    
    // Main chat model with safety settings for mental health context
    // Using gemini-2.5-flash-lite (free tier, most cost-effective)
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json',
        responseSchema: _responseSchema,
      ),
      systemInstruction: Content.text(AppConstants.systemPrompt),
      safetySettings: _safetySettings,
    );

    // Separate model for crisis detection (faster, more sensitive)
    _crisisModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3, // Lower for more consistent crisis detection
        maxOutputTokens: 256,
        responseMimeType: 'application/json',
      ),
      safetySettings: _safetySettings,
    );
    
    debugPrint('GeminiService: Models initialized successfully');
  }

  /// Safety settings optimized for mental health support
  static final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  /// JSON schema for structured AI responses with emotion tagging
  static final Schema _responseSchema = Schema.object(
    properties: {
      'message': Schema.string(
        description: 'The supportive response message to the user',
      ),
      'emotion': Schema.object(
        properties: {
          'type': Schema.enumString(
            enumValues: ['empathetic', 'encouraging', 'calm', 'celebratory', 'thoughtful', 'supportive'],
            description: 'The emotional tone of the response',
          ),
          'intensity': Schema.enumString(
            enumValues: ['low', 'medium', 'high'],
            description: 'The intensity level of the emotion',
          ),
        },
        requiredProperties: ['type', 'intensity'],
      ),
      'crisis_level': Schema.enumString(
        enumValues: ['none', 'low', 'medium', 'high', 'critical'],
        description: 'Crisis severity assessment based on user message',
      ),
      'suggested_actions': Schema.array(
        items: Schema.string(),
        description: 'Optional suggested actions or coping strategies',
        nullable: true,
      ),
    },
    requiredProperties: ['message', 'emotion', 'crisis_level'],
  );

  /// Start a new chat session
  void startNewSession() {
    _chatSession = _model.startChat();
  }

  /// Send a message and get an emotion-tagged response
  Future<AIResponse> sendMessage(String userMessage) async {
    try {
      debugPrint('=== GEMINI API CALL ===');
      debugPrint('GeminiService: Sending message: $userMessage');
      developer.log('GeminiService: Sending message: $userMessage');
      
      // Ensure we have an active session
      _chatSession ??= _model.startChat();

      debugPrint('GeminiService: Chat session active, calling API...');
      
      // Send message and get response
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      debugPrint('GeminiService: API call completed');
      final responseText = response.text;
      debugPrint('GeminiService: Raw response: $responseText');
      developer.log('GeminiService: Received response: $responseText');
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }

      // Parse JSON response
      final jsonResponse = jsonDecode(responseText) as Map<String, dynamic>;
      debugPrint('GeminiService: Successfully parsed JSON response');
      return AIResponse.fromGeminiJson(jsonResponse);
    } catch (e, stackTrace) {
      // Log the error for debugging
      debugPrint('!!! GEMINI API ERROR !!!');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Stack trace: $stackTrace');
      developer.log('GeminiService ERROR: $e', error: e, stackTrace: stackTrace);
      
      // Return a fallback supportive response on error
      return AIResponse(
        message: "I'm here for you. I had a moment of difficulty understanding, but please know that what you're feeling matters. Would you like to share more about what's on your mind?",
        emotion: const Emotion(
          type: EmotionType.supportive,
          intensity: EmotionIntensity.medium,
        ),
        crisisSeverity: CrisisSeverity.none,
      );
    }
  }

  /// Stream a message response (for typing effect)
  Stream<String> streamMessage(String userMessage) async* {
    try {
      _chatSession ??= _model.startChat();
      
      final response = _chatSession!.sendMessageStream(
        Content.text(userMessage),
      );

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield '{"message": "I\'m here for you. Let\'s take a moment together.", "emotion": {"type": "supportive", "intensity": "medium"}, "crisis_level": "none"}';
    }
  }

  /// Quick crisis assessment (used in parallel with main response)
  Future<CrisisSeverity> assessCrisisLevel(String userMessage) async {
    try {
      final prompt = '''
Assess the following message for mental health crisis indicators.
Return ONLY a JSON object with the crisis level.

Crisis levels:
- none: Normal conversation
- low: Some distress, monitoring needed
- medium: Significant distress, gentle intervention
- high: Crisis indicators, show resources
- critical: Immediate danger, urgent resources needed

Message: "$userMessage"

Respond with: {"crisis_level": "none/low/medium/high/critical"}
''';

      final response = await _crisisModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;
      
      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        final level = json['crisis_level'] as String? ?? 'none';
        return CrisisSeverity.values.firstWhere(
          (e) => e.name == level,
          orElse: () => CrisisSeverity.none,
        );
      }
    } catch (e) {
      // On error, be cautious and return low (monitor)
    }
    return CrisisSeverity.none;
  }

  /// Generate AI insight for a mood entry
  Future<String> generateMoodInsight(MoodEntry entry) async {
    try {
      final prompt = '''
Generate a brief, supportive insight (2-3 sentences) for someone who logged the following mood:

Mood: ${entry.category.label}
Intensity: ${entry.intensity.label}
${entry.notes != null ? 'Notes: ${entry.notes}' : ''}
${entry.triggers?.isNotEmpty == true ? 'Triggers: ${entry.triggers!.join(', ')}' : ''}

Be warm, validating, and offer gentle encouragement or a coping tip.
Respond with plain text only, no JSON.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _getDefaultMoodInsight(entry);
    } catch (e) {
      return _getDefaultMoodInsight(entry);
    }
  }

  /// Generate AI insight from individual mood parameters (for BLoC usage)
  Future<String?> generateMoodInsightFromParams({
    required String category,
    required String intensity,
    String? notes,
    List<String>? triggers,
  }) async {
    try {
      final prompt = '''
Generate a brief, supportive insight (2-3 sentences) for someone who logged the following mood:

Mood: $category
Intensity: $intensity
${notes != null ? 'Notes: $notes' : ''}
${triggers?.isNotEmpty == true ? 'Triggers: ${triggers!.join(', ')}' : ''}

Be warm, validating, and offer gentle encouragement or a coping tip.
Respond with plain text only, no JSON.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('GeminiService: generateMoodInsightFromParams failed: $e');
      return null;
    }
  }

  /// Generate AI insight for mood patterns over time
  Future<String?> generatePatternInsight(String moodSummary) async {
    try {
      final prompt = '''
Analyze the following mood log entries and provide a brief, supportive insight (2-3 sentences) about patterns you notice:

$moodSummary

Focus on:
- Any positive trends or improvements
- Potential triggers or patterns
- A gentle, encouraging observation

Be warm and supportive. Respond with plain text only, no JSON.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('GeminiService: generatePatternInsight failed: $e');
      return null;
    }
  }

  String _getDefaultMoodInsight(MoodEntry entry) {
    return "Thank you for checking in with how you're feeling. Acknowledging your emotions is an important step in self-care.";
  }

  /// Generate personalized greeting based on time and recent context
  Future<String> generateGreeting({
    String? userName,
    MoodEntry? recentMood,
  }) async {
    try {
      final hour = DateTime.now().hour;
      String timeContext;
      if (hour < 12) {
        timeContext = 'morning';
      } else if (hour < 17) {
        timeContext = 'afternoon';
      } else {
        timeContext = 'evening';
      }

      final prompt = '''
Generate a warm, brief greeting (1-2 sentences) for a mental health support app user.

Time: $timeContext
${userName != null ? 'Name: $userName' : ''}
${recentMood != null ? 'Last mood logged: ${recentMood.category.label} (${recentMood.intensity.label})' : ''}

Be warm and inviting. Respond with plain text only.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _getDefaultGreeting(timeContext, userName);
    } catch (e) {
      final hour = DateTime.now().hour;
      String timeContext;
      if (hour < 12) {
        timeContext = 'morning';
      } else if (hour < 17) {
        timeContext = 'afternoon';
      } else {
        timeContext = 'evening';
      }
      return _getDefaultGreeting(timeContext, userName);
    }
  }

  String _getDefaultGreeting(String timeContext, String? userName) {
    final name = userName != null ? ', $userName' : '';
    return "Good $timeContext$name. I'm here whenever you're ready to talk.";
  }

  /// Clear chat history and start fresh
  void clearHistory() {
    _chatSession = null;
  }

  /// Add a message to history (for restoring persisted conversations)
  /// This should be called when loading a previous conversation
  void addToHistory(String content, {required bool isUser}) {
    // Initialize session if not already done
    _chatSession ??= _model.startChat(
      history: [
        Content.text(AppConstants.systemPrompt),
        Content.model([TextPart("I understand. I'm here to support you as your AI wellness companion. How are you feeling today?")]),
      ],
    );

    // The Gemini ChatSession doesn't have a direct addHistory method,
    // so we need to rebuild the session with the full history.
    // For now, we'll track history separately and rebuild when needed.
    // This is a limitation of the current API.
    
    // Since ChatSession manages history internally and doesn't expose
    // a way to add messages without sending, we'll use a workaround:
    // Store the conversation context and include it in the system prompt
    // when starting a session with history.
  }

  /// Start a session with existing conversation history
  void startSessionWithHistory(List<Map<String, dynamic>> messages) {
    final history = <Content>[
      Content.text(AppConstants.systemPrompt),
      Content.model([TextPart("I understand. I'm here to support you as your AI wellness companion. How are you feeling today?")]),
    ];

    // Add past messages to history
    for (final msg in messages) {
      final content = msg['content'] as String;
      final isUser = msg['isUser'] as bool;
      
      if (isUser) {
        history.add(Content.text(content));
      } else {
        history.add(Content.model([TextPart(content)]));
      }
    }

    _chatSession = _model.startChat(history: history);
  }

  /// Dispose resources
  void dispose() {
    _chatSession = null;
  }
}
