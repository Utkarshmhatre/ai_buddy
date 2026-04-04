import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../data/models/journal_entry.dart';
import '../../data/models/mood_entry.dart';
import '../demo/demo_data_service.dart';

/// Enhanced AI service for Phase 3 features:
/// - AI-powered journaling with prompts
/// - Pattern recognition
/// - Advanced crisis detection (Layers 2-4)
/// - Function calling
class EnhancedGeminiService {
  late final GenerativeModel _journalModel;
  late final GenerativeModel _analysisModel;
  late final GenerativeModel _crisisModel;
  late final GenerativeModel _functionModel;
  
  final String _apiKey;

  EnhancedGeminiService({required String apiKey}) : _apiKey = apiKey {
    _initializeModels();
  }

  void _initializeModels() {
    // Journal prompt generation model
    _journalModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8, // Creative for prompts
        topP: 0.95,
        maxOutputTokens: 512,
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.text(_journalSystemPrompt),
    );

    // Analysis and pattern recognition model
    _analysisModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4, // Balanced for analysis
        topP: 0.9,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json',
        responseSchema: _analysisSchema,
      ),
      systemInstruction: Content.text(_analysisSystemPrompt),
    );

    // Enhanced crisis detection model (Layers 2-4)
    _crisisModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2, // Low for consistent crisis assessment
        maxOutputTokens: 512,
        responseMimeType: 'application/json',
        responseSchema: _crisisSchema,
      ),
      systemInstruction: Content.text(_crisisSystemPrompt),
    );

    // Function calling model
    _functionModel = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 256,
      ),
      tools: [_buildFunctionDeclarations()],
    );
  }

  // ==================== System Prompts ====================

  static const String _journalSystemPrompt = '''
You are a compassionate journaling companion for a mental health app.
Your role is to generate thoughtful, therapeutic journal prompts that:
- Encourage self-reflection and emotional awareness
- Are trauma-informed and safe for all users
- Vary in depth - some light, some deeper exploration
- Connect to the user's current emotional state when provided
- Are never triggering or potentially harmful

Always respond with JSON in the specified format.
''';

  static const String _analysisSystemPrompt = '''
You are an AI therapist assistant analyzing journal entries for a mental health app.
Your role is to:
- Identify emotional themes and patterns
- Provide supportive, non-judgmental insights
- Recognize potential areas for growth
- Never diagnose or provide medical advice
- Be encouraging and validate the user's experiences

Analyze thoughtfully but remain warm and supportive.
Always respond with JSON in the specified format.
''';

  static const String _crisisSystemPrompt = '''
You are a mental health crisis detection system. Your job is to carefully analyze text for signs of distress.

CRISIS DETECTION LAYERS:

Layer 2 - Sentiment Analysis:
- Overall emotional tone (positive/negative/neutral)
- Intensity of negative emotions
- Hopelessness indicators
- Despair language patterns

Layer 3 - Contextual Understanding:
- Implied meanings beyond literal words
- Cultural and contextual nuances
- Sarcasm or minimization of serious feelings
- Time-related urgency ("can't take it anymore", "done with everything")

Layer 4 - Behavioral Patterns:
- Sudden mood shifts
- Social withdrawal language
- Giving away/saying goodbye language
- Past attempts or ideation references
- Self-harm indicators

Be sensitive but thorough. False positives are better than missed crises.
Always respond with JSON in the specified format.
''';

  // ==================== Schemas ====================

  static final Schema _analysisSchema = Schema.object(
    properties: {
      'summary': Schema.string(
        description: 'A brief, empathetic summary of the journal entry',
      ),
      'themes': Schema.array(
        items: Schema.string(),
        description: 'Main themes identified (e.g., self-worth, relationships, anxiety)',
      ),
      'emotions': Schema.array(
        items: Schema.string(),
        description: 'Emotions detected in the entry',
      ),
      'moodScore': Schema.integer(
        description: 'Overall mood score from 1 (very negative) to 10 (very positive)',
      ),
      'insight': Schema.string(
        description: 'A supportive, therapeutic insight or reflection',
      ),
      'suggestedActions': Schema.array(
        items: Schema.string(),
        description: 'Gentle suggestions for self-care or next steps',
        nullable: true,
      ),
      'growthAreas': Schema.array(
        items: Schema.string(),
        description: 'Potential areas for personal growth identified',
        nullable: true,
      ),
    },
    requiredProperties: ['summary', 'themes', 'emotions', 'moodScore', 'insight'],
  );

  static final Schema _crisisSchema = Schema.object(
    properties: {
      'overallRisk': Schema.enumString(
        enumValues: ['none', 'low', 'moderate', 'high', 'critical'],
        description: 'Overall crisis risk level',
      ),
      'layer2_sentiment': Schema.object(
        properties: {
          'tone': Schema.enumString(enumValues: ['positive', 'neutral', 'negative', 'severely_negative']),
          'hopelessnessLevel': Schema.integer(description: '0-10 scale'),
          'emotionalIntensity': Schema.integer(description: '0-10 scale'),
        },
      ),
      'layer3_context': Schema.object(
        properties: {
          'impliedDistress': Schema.boolean(),
          'urgencyDetected': Schema.boolean(),
          'minimizingSerious': Schema.boolean(),
          'contextualConcerns': Schema.array(items: Schema.string(), nullable: true),
        },
      ),
      'layer4_behavioral': Schema.object(
        properties: {
          'withdrawalLanguage': Schema.boolean(),
          'farewellLanguage': Schema.boolean(),
          'pastAttemptsReferenced': Schema.boolean(),
          'selfHarmIndicators': Schema.boolean(),
          'suddenMoodShift': Schema.boolean(),
        },
      ),
      'confidenceScore': Schema.number(
        description: 'Confidence in assessment 0.0-1.0',
      ),
      'recommendedAction': Schema.enumString(
        enumValues: ['continue_conversation', 'gentle_check_in', 'show_resources', 'urgent_resources', 'crisis_intervention'],
        description: 'Recommended response action',
      ),
      'reasoning': Schema.string(
        description: 'Brief explanation of the assessment',
      ),
    },
    requiredProperties: ['overallRisk', 'confidenceScore', 'recommendedAction', 'reasoning'],
  );

  // ==================== Function Calling ====================

  Tool _buildFunctionDeclarations() {
    return Tool(functionDeclarations: [
      FunctionDeclaration(
        'log_mood',
        'Log or update the user\'s current mood',
        Schema.object(
          properties: {
            'category': Schema.enumString(
              enumValues: MoodCategory.values.map((e) => e.name).toList(),
              description: 'The mood category',
            ),
            'intensity': Schema.enumString(
              enumValues: MoodIntensity.values.map((e) => e.name).toList(),
              description: 'The intensity level',
            ),
            'notes': Schema.string(description: 'Optional notes about the mood', nullable: true),
          },
          requiredProperties: ['category', 'intensity'],
        ),
      ),
      FunctionDeclaration(
        'suggest_exercise',
        'Suggest a therapeutic exercise based on current state',
        Schema.object(
          properties: {
            'exerciseType': Schema.enumString(
              enumValues: ['breathing', 'grounding', 'journaling', 'meditation', 'movement'],
              description: 'Type of exercise to suggest',
            ),
            'reason': Schema.string(description: 'Why this exercise would help'),
            'duration': Schema.integer(description: 'Suggested duration in minutes'),
          },
          requiredProperties: ['exerciseType', 'reason'],
        ),
      ),
      FunctionDeclaration(
        'show_crisis_resources',
        'Display crisis resources and helpline information',
        Schema.object(
          properties: {
            'urgency': Schema.enumString(
              enumValues: ['informational', 'supportive', 'urgent', 'emergency'],
              description: 'Urgency level for resources',
            ),
            'specificResources': Schema.array(
              items: Schema.string(),
              description: 'Specific resources to highlight',
              nullable: true,
            ),
          },
          requiredProperties: ['urgency'],
        ),
      ),
      FunctionDeclaration(
        'create_journal_prompt',
        'Generate a personalized journal prompt for the user',
        Schema.object(
          properties: {
            'promptType': Schema.enumString(
              enumValues: JournalEntryType.values.map((e) => e.name).toList(),
              description: 'Type of journal prompt',
            ),
            'theme': Schema.string(description: 'Theme or focus for the prompt', nullable: true),
          },
          requiredProperties: ['promptType'],
        ),
      ),
      FunctionDeclaration(
        'get_mood_summary',
        'Retrieve and summarize recent mood history',
        Schema.object(
          properties: {
            'periodDays': Schema.integer(description: 'Number of days to summarize'),
            'includePatterns': Schema.boolean(description: 'Whether to include pattern analysis'),
          },
          requiredProperties: ['periodDays'],
        ),
      ),
    ]);
  }

  // ==================== Journaling Methods ====================

  /// Generate a personalized journal prompt based on context
  Future<JournalPrompt> generateJournalPrompt({
    required JournalEntryType type,
    MoodEntry? currentMood,
    List<String>? recentThemes,
    String? timeOfDay,
  }) async {
    try {
      final contextParts = <String>[];
      if (currentMood != null) {
        contextParts.add('Current mood: ${currentMood.category.label} (${currentMood.intensity.label})');
      }
      if (recentThemes?.isNotEmpty == true) {
        contextParts.add('Recent journal themes: ${recentThemes!.join(', ')}');
      }
      if (timeOfDay != null) {
        contextParts.add('Time of day: $timeOfDay');
      }

      final prompt = '''
Generate a thoughtful ${type.label.toLowerCase()} journal prompt.
${contextParts.isNotEmpty ? '\nContext:\n${contextParts.join('\n')}' : ''}

Requirements:
- Be warm and inviting
- Encourage self-reflection
- Match the ${type.label} style
- Be appropriate for any emotional state

Respond with JSON:
{
  "prompt": "Your generated prompt here",
  "category": "self-discovery|coping|growth|gratitude|reflection"
}
''';

      final response = await _journalModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return JournalPrompt(
          prompt: json['prompt'] as String,
          type: type,
          category: json['category'] as String?,
        );
      }
    } catch (e) {
      debugPrint('EnhancedGeminiService: generateJournalPrompt failed: $e');
    }

    // Fallback prompts
    return JournalPrompt(
      prompt: _getDefaultPrompt(type),
      type: type,
      category: 'general',
    );
  }

  /// Analyze a journal entry for themes, emotions, and insights
  Future<JournalAnalysis> analyzeJournalEntry(JournalEntry entry) async {
    try {
      final prompt = '''
Analyze this journal entry thoughtfully:

Entry Type: ${entry.type.label}
${entry.prompt != null ? 'Prompt Used: ${entry.prompt}' : ''}

---
${entry.content}
---

Provide a supportive analysis focusing on emotional themes, insights, and gentle suggestions.
''';

      final response = await _analysisModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return JournalAnalysis(
          entryId: entry.id,
          summary: json['summary'] as String? ?? '',
          themes: (json['themes'] as List<dynamic>?)?.cast<String>() ?? [],
          emotions: (json['emotions'] as List<dynamic>?)?.cast<String>() ?? [],
          moodScore: json['moodScore'] as int? ?? 5,
          insight: json['insight'] as String?,
          suggestedActions: (json['suggestedActions'] as List<dynamic>?)?.cast<String>(),
        );
      }
    } catch (e) {
      debugPrint('EnhancedGeminiService: analyzeJournalEntry failed: $e');
    }

    return JournalAnalysis(
      entryId: entry.id,
      summary: 'Thank you for taking time to journal today.',
      themes: [],
      emotions: [],
      moodScore: 5,
      insight: 'Journaling is a wonderful practice for self-reflection.',
    );
  }

  // ==================== Pattern Recognition ====================

  /// Analyze patterns across multiple mood entries and journal entries
  Future<PatternAnalysis> analyzePatterns({
    required List<MoodEntry> moodEntries,
    List<JournalEntry>? journalEntries,
    int periodDays = 30,
  }) async {
    // Check if demo mode is enabled - return demo patterns without API call
    final isDemoMode = await DemoDataService.isDemoModeEnabled();
    if (isDemoMode) {
      return PatternAnalysis.demo();
    }
    
    try {
      // Build summary of data
      final moodSummary = moodEntries.map((e) => 
        '${e.timestamp.toString().substring(0, 10)}: ${e.category.label} (${e.intensity.label})'
        '${e.triggers?.isNotEmpty == true ? ' - Triggers: ${e.triggers!.join(', ')}' : ''}'
      ).join('\n');

      final journalSummary = journalEntries?.map((e) =>
        '${e.createdAt.toString().substring(0, 10)}: ${e.themes?.join(', ') ?? 'No themes'} - Mood: ${e.derivedMoodScore ?? 'Unknown'}'
      ).join('\n');

      final prompt = '''
Analyze these mood and journal patterns from the past $periodDays days:

MOOD ENTRIES:
$moodSummary

${journalSummary != null ? 'JOURNAL ENTRIES:\n$journalSummary' : ''}

Identify:
1. Overall mood trends (improving, stable, declining)
2. Common triggers or patterns
3. Time-based patterns (day of week, time of day)
4. Emotional themes that recur
5. Strengths and coping strategies used
6. Areas for potential growth

Respond with JSON:
{
  "overallTrend": "improving|stable|declining|fluctuating",
  "trendDescription": "Brief description of the trend",
  "commonTriggers": ["trigger1", "trigger2"],
  "positivePatterns": ["pattern1", "pattern2"],
  "concerningPatterns": ["pattern1"],
  "timePatterns": {
    "bestDays": ["Monday", "Tuesday"],
    "challengingDays": ["Sunday"],
    "bestTimeOfDay": "morning|afternoon|evening"
  },
  "recurringThemes": ["theme1", "theme2"],
  "strengths": ["strength1"],
  "growthOpportunities": ["opportunity1"],
  "personalizedInsight": "A warm, personalized insight based on the patterns"
}
''';

      final response = await _analysisModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return PatternAnalysis.fromJson(json);
      }
    } catch (e) {
      debugPrint('EnhancedGeminiService: analyzePatterns failed: $e');
    }

    return PatternAnalysis.empty();
  }

  // ==================== Enhanced Crisis Detection ====================

  /// Perform multi-layer crisis assessment (Layers 2-4)
  Future<CrisisAssessment> assessCrisisMultiLayer(String text, {
    List<String>? recentMessages,
    MoodEntry? currentMood,
  }) async {
    try {
      final contextParts = <String>[];
      if (recentMessages?.isNotEmpty == true) {
        contextParts.add('Recent conversation context:\n${recentMessages!.take(5).join('\n')}');
      }
      if (currentMood != null) {
        contextParts.add('Current logged mood: ${currentMood.category.label} (${currentMood.intensity.label})');
      }

      final prompt = '''
Perform a thorough crisis assessment on this message:

"$text"

${contextParts.isNotEmpty ? '\nAdditional Context:\n${contextParts.join('\n\n')}' : ''}

Apply all crisis detection layers (sentiment, context, behavioral) and provide a comprehensive assessment.
''';

      final response = await _crisisModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return CrisisAssessment.fromJson(json);
      }
    } catch (e) {
      debugPrint('EnhancedGeminiService: assessCrisisMultiLayer failed: $e');
    }

    // Default to cautious assessment on error
    return CrisisAssessment.cautious();
  }

  // ==================== Function Calling ====================

  /// Process a message with function calling support
  Future<FunctionCallResult> processWithFunctions(String userMessage, {
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    try {
      final history = conversationHistory?.map((msg) {
        final isUser = msg['isUser'] as bool;
        final content = msg['content'] as String;
        return isUser ? Content.text(content) : Content.model([TextPart(content)]);
      }).toList() ?? [];

      final chat = _functionModel.startChat(history: history);
      final response = await chat.sendMessage(Content.text(userMessage));

      // Check for function calls
      final functionCalls = response.functionCalls.toList();
      if (functionCalls.isNotEmpty) {
        final results = <FunctionCallData>[];
        for (final call in functionCalls) {
          results.add(FunctionCallData(
            name: call.name,
            arguments: call.args,
          ));
        }
        return FunctionCallResult(
          hasFunctionCalls: true,
          functionCalls: results,
          textResponse: response.text,
        );
      }

      return FunctionCallResult(
        hasFunctionCalls: false,
        textResponse: response.text ?? "I'm here to help.",
      );
    } catch (e) {
      debugPrint('EnhancedGeminiService: processWithFunctions failed: $e');
      return FunctionCallResult(
        hasFunctionCalls: false,
        textResponse: "I'm here for you. How can I help?",
      );
    }
  }

  // ==================== Exercise Narration ====================

  /// Generate personalized narration for guided exercises
  Future<ExerciseNarration> generateExerciseNarration({
    required String exerciseType, // breathing, grounding, meditation
    MoodEntry? currentMood,
    String? userPreference,
  }) async {
    try {
      final moodContext = currentMood != null
          ? 'User is feeling ${currentMood.category.label} (${currentMood.intensity.label})'
          : 'No current mood logged';

      final prompt = '''
Generate a personalized guided narration for a $exerciseType exercise.

Context: $moodContext
${userPreference != null ? 'User preference: $userPreference' : ''}

Create a calming, supportive script with:
1. A warm introduction (2-3 sentences)
2. Step-by-step instructions (appropriate pacing for $exerciseType)
3. Encouraging check-ins between steps
4. A gentle closing (2-3 sentences)

Respond with JSON:
{
  "title": "Exercise title",
  "introduction": "Introduction text",
  "steps": [
    {"instruction": "Step instruction", "duration": seconds, "cue": "timing cue like 'breathe in'"}
  ],
  "checkIn": "Mid-exercise check-in prompt",
  "closing": "Closing text",
  "totalDuration": total_seconds
}
''';

      final response = await _journalModel.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        final json = jsonDecode(responseText) as Map<String, dynamic>;
        return ExerciseNarration.fromJson(json, exerciseType);
      }
    } catch (e) {
      debugPrint('EnhancedGeminiService: generateExerciseNarration failed: $e');
    }

    return ExerciseNarration.default_(exerciseType);
  }

  // ==================== Helper Methods ====================

  String _getDefaultPrompt(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.free:
        return 'What\'s on your mind right now? There\'s no wrong way to start—just let your thoughts flow.';
      case JournalEntryType.prompted:
        return 'Describe a moment today when you felt at peace, even if only briefly.';
      case JournalEntryType.gratitude:
        return 'What are three things you\'re grateful for today, big or small?';
      case JournalEntryType.reflection:
        return 'Looking back on your week, what\'s one thing you learned about yourself?';
      case JournalEntryType.goalSetting:
        return 'What\'s one small step you could take this week toward something important to you?';
      case JournalEntryType.emotionExplorer:
        return 'If your current emotion had a color and shape, what would it look like?';
    }
  }
}

// ==================== Supporting Classes ====================

/// Result of pattern analysis
class PatternAnalysis {
  final String overallTrend;
  final String trendDescription;
  final List<String> commonTriggers;
  final List<String> positivePatterns;
  final List<String> concerningPatterns;
  final Map<String, dynamic>? timePatterns;
  final List<String> recurringThemes;
  final List<String> strengths;
  final List<String> growthOpportunities;
  final String personalizedInsight;

  PatternAnalysis({
    required this.overallTrend,
    required this.trendDescription,
    required this.commonTriggers,
    required this.positivePatterns,
    required this.concerningPatterns,
    this.timePatterns,
    required this.recurringThemes,
    required this.strengths,
    required this.growthOpportunities,
    required this.personalizedInsight,
  });

  factory PatternAnalysis.fromJson(Map<String, dynamic> json) {
    return PatternAnalysis(
      overallTrend: json['overallTrend'] as String? ?? 'stable',
      trendDescription: json['trendDescription'] as String? ?? '',
      commonTriggers: (json['commonTriggers'] as List<dynamic>?)?.cast<String>() ?? [],
      positivePatterns: (json['positivePatterns'] as List<dynamic>?)?.cast<String>() ?? [],
      concerningPatterns: (json['concerningPatterns'] as List<dynamic>?)?.cast<String>() ?? [],
      timePatterns: json['timePatterns'] as Map<String, dynamic>?,
      recurringThemes: (json['recurringThemes'] as List<dynamic>?)?.cast<String>() ?? [],
      strengths: (json['strengths'] as List<dynamic>?)?.cast<String>() ?? [],
      growthOpportunities: (json['growthOpportunities'] as List<dynamic>?)?.cast<String>() ?? [],
      personalizedInsight: json['personalizedInsight'] as String? ?? 'Keep exploring your patterns.',
    );
  }

  factory PatternAnalysis.empty() {
    return PatternAnalysis(
      overallTrend: 'insufficient_data',
      trendDescription: 'Not enough data to identify patterns yet.',
      commonTriggers: [],
      positivePatterns: [],
      concerningPatterns: [],
      recurringThemes: [],
      strengths: [],
      growthOpportunities: [],
      personalizedInsight: 'Continue tracking to discover your patterns.',
    );
  }
  
  /// Demo pattern analysis for presentation purposes
  factory PatternAnalysis.demo() {
    return PatternAnalysis(
      overallTrend: 'improving',
      trendDescription: 'Your mood has been steadily improving over the past two weeks, with notable increases in gratitude and calm moments.',
      commonTriggers: [
        'Morning meditation sessions',
        'Social connections with friends',
        'Nature walks',
        'Quality sleep',
        'Work deadlines (stress trigger)',
      ],
      positivePatterns: [
        'Consistent morning self-care routine',
        'Regular use of breathing exercises',
        'Journaling helps process difficult emotions',
        'Reaching out to friends when feeling down',
      ],
      concerningPatterns: [
        'Stress levels increase mid-week',
        'Occasional anxiety around deadlines',
      ],
      timePatterns: {
        'bestDays': ['Saturday', 'Monday', 'Thursday'],
        'challengingDays': ['Wednesday'],
        'bestTimeOfDay': 'morning',
      },
      recurringThemes: [
        'Gratitude',
        'Self-care',
        'Work-life balance',
        'Personal growth',
        'Connection',
      ],
      strengths: [
        'Strong self-awareness',
        'Proactive coping strategies',
        'Willingness to seek support',
        'Consistent tracking habits',
      ],
      growthOpportunities: [
        'Try a midweek relaxation routine',
        'Practice deadline anxiety management',
        'Explore evening wind-down activities',
      ],
      personalizedInsight: "You're making wonderful progress! Your commitment to morning meditation and reaching out to friends shows strong self-care instincts. The pattern suggests that front-loading your week with positive activities helps maintain momentum. Consider adding a brief midweek check-in to catch stress before it builds.",
    );
  }
}

/// Multi-layer crisis assessment result
class CrisisAssessment {
  final String overallRisk;
  final Map<String, dynamic>? layer2Sentiment;
  final Map<String, dynamic>? layer3Context;
  final Map<String, dynamic>? layer4Behavioral;
  final double confidenceScore;
  final String recommendedAction;
  final String reasoning;

  CrisisAssessment({
    required this.overallRisk,
    this.layer2Sentiment,
    this.layer3Context,
    this.layer4Behavioral,
    required this.confidenceScore,
    required this.recommendedAction,
    required this.reasoning,
  });

  factory CrisisAssessment.fromJson(Map<String, dynamic> json) {
    return CrisisAssessment(
      overallRisk: json['overallRisk'] as String? ?? 'none',
      layer2Sentiment: json['layer2_sentiment'] as Map<String, dynamic>?,
      layer3Context: json['layer3_context'] as Map<String, dynamic>?,
      layer4Behavioral: json['layer4_behavioral'] as Map<String, dynamic>?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.5,
      recommendedAction: json['recommendedAction'] as String? ?? 'continue_conversation',
      reasoning: json['reasoning'] as String? ?? '',
    );
  }

  factory CrisisAssessment.cautious() {
    return CrisisAssessment(
      overallRisk: 'low',
      confidenceScore: 0.5,
      recommendedAction: 'gentle_check_in',
      reasoning: 'Unable to fully assess; proceeding with caution.',
    );
  }

  bool get requiresIntervention => 
      overallRisk == 'high' || overallRisk == 'critical';

  bool get showResources => 
      overallRisk == 'moderate' || overallRisk == 'high' || overallRisk == 'critical';
}

/// Function call result
class FunctionCallResult {
  final bool hasFunctionCalls;
  final List<FunctionCallData>? functionCalls;
  final String? textResponse;

  FunctionCallResult({
    required this.hasFunctionCalls,
    this.functionCalls,
    this.textResponse,
  });
}

/// Individual function call data
class FunctionCallData {
  final String name;
  final Map<String, Object?> arguments;

  FunctionCallData({
    required this.name,
    required this.arguments,
  });
}

/// Exercise narration content
class ExerciseNarration {
  final String title;
  final String exerciseType;
  final String introduction;
  final List<ExerciseStep> steps;
  final String checkIn;
  final String closing;
  final int totalDurationSeconds;

  ExerciseNarration({
    required this.title,
    required this.exerciseType,
    required this.introduction,
    required this.steps,
    required this.checkIn,
    required this.closing,
    required this.totalDurationSeconds,
  });

  factory ExerciseNarration.fromJson(Map<String, dynamic> json, String exerciseType) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return ExerciseNarration(
      title: json['title'] as String? ?? 'Guided Exercise',
      exerciseType: exerciseType,
      introduction: json['introduction'] as String? ?? 'Let\'s begin.',
      steps: stepsJson.map((s) => ExerciseStep.fromJson(s as Map<String, dynamic>)).toList(),
      checkIn: json['checkIn'] as String? ?? 'How are you feeling?',
      closing: json['closing'] as String? ?? 'Well done.',
      totalDurationSeconds: json['totalDuration'] as int? ?? 60,
    );
  }

  factory ExerciseNarration.default_(String exerciseType) {
    if (exerciseType == 'breathing') {
      return ExerciseNarration(
        title: '4-7-8 Breathing',
        exerciseType: exerciseType,
        introduction: 'Let\'s take a moment to calm your nervous system with deep breathing.',
        steps: [
          ExerciseStep(instruction: 'Breathe in slowly through your nose', duration: 4, cue: 'Inhale'),
          ExerciseStep(instruction: 'Hold your breath gently', duration: 7, cue: 'Hold'),
          ExerciseStep(instruction: 'Exhale slowly through your mouth', duration: 8, cue: 'Exhale'),
        ],
        checkIn: 'Notice how you\'re feeling.',
        closing: 'Wonderful work. Take this calm with you.',
        totalDurationSeconds: 120,
      );
    }
    return ExerciseNarration(
      title: 'Guided Exercise',
      exerciseType: exerciseType,
      introduction: 'Let\'s take a mindful moment together.',
      steps: [
        ExerciseStep(instruction: 'Find a comfortable position', duration: 5, cue: 'Settle'),
        ExerciseStep(instruction: 'Take a deep breath', duration: 5, cue: 'Breathe'),
      ],
      checkIn: 'How are you feeling?',
      closing: 'Thank you for taking this time for yourself.',
      totalDurationSeconds: 60,
    );
  }
}

/// Individual step in an exercise
class ExerciseStep {
  final String instruction;
  final int duration;
  final String cue;
  final String? guidance;
  final String? encouragement;

  ExerciseStep({
    required this.instruction,
    required this.duration,
    required this.cue,
    this.guidance,
    this.encouragement,
  });

  factory ExerciseStep.fromJson(Map<String, dynamic> json) {
    return ExerciseStep(
      instruction: json['instruction'] as String? ?? '',
      duration: json['duration'] as int? ?? 5,
      cue: json['cue'] as String? ?? '',
      guidance: json['guidance'] as String?,
      encouragement: json['encouragement'] as String?,
    );
  }
}
