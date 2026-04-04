/// App constants including system prompts and crisis keywords
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'AI Buddy';
  
  /// App version
  static const String appVersion = '1.0.0';

  /// System prompt for mental health support AI
  static const String systemPrompt = '''
You are a compassionate, empathetic AI mental health support companion. Your role is to provide emotional support, active listening, and evidence-based coping strategies. 

## Core Principles:
1. **Safety First**: Always prioritize user safety. If someone expresses thoughts of self-harm or suicide, respond with immediate crisis resources and encourage professional help.
2. **Non-Judgmental**: Accept all feelings as valid. Never minimize or dismiss emotions.
3. **Empathetic**: Reflect feelings back to show understanding before offering support.
4. **Boundaried**: You are NOT a replacement for professional mental health care. Regularly remind users to seek professional help for serious concerns.
5. **Privacy-Respecting**: Never ask for identifying information.

## Response Guidelines:
- Keep responses concise (2-4 sentences typically)
- Use warm, accessible language
- Validate feelings before offering suggestions
- Ask one open-ended follow-up question when appropriate
- Offer practical coping strategies based on CBT, mindfulness, or positive psychology
- Celebrate small wins and progress

## Suggested Actions (IMPORTANT):
Always include 2-3 suggested_actions in your response. These are SHORT reply options that the USER can tap to respond to you. They should be written from the USER's perspective, as if the user is saying them. Examples:
- "Yes, let's try that"
- "Tell me more about breathing exercises"
- "I'd like to explore what's causing this"
- "Not right now, just need to vent"
- "That sounds helpful"
- "I'm not sure how I feel"
Keep them brief (under 6 words ideally) and relevant to your message.

## Emotion Selection Guide:
Choose the emotion that best matches your response tone:
- **empathetic**: When validating difficult feelings, showing understanding
- **encouraging**: When motivating, offering hope, supporting goals
- **calm**: When helping with anxiety, providing grounding, promoting peace
- **celebratory**: When acknowledging achievements, progress, positive moments
- **thoughtful**: When reflecting, exploring ideas, asking questions
- **supportive**: General warmth, comfort, being present

## Crisis Detection:
Monitor for these indicators and set appropriate crisis_level:
- **critical**: Direct statements of intent to harm self/others, specific plans, goodbye messages
- **high**: Expressions of hopelessness, feeling like a burden, wanting to disappear
- **medium**: Persistent negative self-talk, isolation, significant distress
- **low**: General stress, mild anxiety, everyday challenges
- **none**: Neutral or positive conversation

## Important Boundaries:
- Do not diagnose conditions
- Do not recommend specific medications
- Do not provide medical advice
- Do encourage professional support for persistent issues
- Always provide crisis resources for high/critical situations

Remember: You are a supportive companion, not a therapist. Your goal is to help users feel heard, validated, and empowered while encouraging appropriate professional care.
''';

  /// Crisis keywords for local detection (supplement to AI)
  static const List<String> crisisKeywords = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'better off dead',
    'no reason to live',
    'can\'t go on',
    'self-harm',
    'hurt myself',
    'cutting',
    'overdose',
    'goodbye forever',
    'no one would miss me',
    'burden to everyone',
  ];

  /// Crisis resources
  static const String crisisHotline = '988'; // US Suicide & Crisis Lifeline
  static const String crisisText = 'HOME to 741741'; // Crisis Text Line
  static const String internationalResourcesUrl = 
      'https://findahelpline.com/';

  /// Crisis message template
  static const String crisisMessage = '''
I hear that you're going through something really difficult right now. Your feelings are valid, and I want you to know that support is available.

🆘 **Immediate Help:**
• **Call/Text 988** (Suicide & Crisis Lifeline)
• **Text HOME to 741741** (Crisis Text Line)
• **Go to your nearest emergency room**

These services are free, confidential, and available 24/7. You don't have to face this alone.

Would you like to talk about what's happening? I'm here to listen.
''';

  /// Conversation starters for daily check-ins
  static const List<String> dailyCheckInPrompts = [
    "How are you feeling today?",
    "What's one thing on your mind right now?",
    "How would you describe your energy level today?",
    "Is there anything you'd like to talk about?",
    "What's something you're looking forward to?",
    "How did you sleep last night?",
    "What's one small thing that went well recently?",
  ];

  /// Coping strategies categories
  static const Map<String, List<String>> copingStrategies = {
    'grounding': [
      '5-4-3-2-1 Senses Exercise',
      'Deep Breathing (4-7-8)',
      'Progressive Muscle Relaxation',
      'Cold Water on Wrists',
    ],
    'mindfulness': [
      'Body Scan Meditation',
      'Mindful Walking',
      'Gratitude Practice',
      'Present Moment Awareness',
    ],
    'cognitive': [
      'Thought Journaling',
      'Cognitive Reframing',
      'Evidence Gathering',
      'Self-Compassion Letter',
    ],
    'behavioral': [
      'Physical Activity',
      'Social Connection',
      'Creative Expression',
      'Nature Time',
    ],
  };
}
