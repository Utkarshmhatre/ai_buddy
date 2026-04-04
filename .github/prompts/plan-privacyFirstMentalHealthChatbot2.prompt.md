# Privacy-First Mental Health Chatbot Development Guidelines

A comprehensive development blueprint for building a Flutter-based, AI-powered mental health support chatbot that prioritizes user privacy through zero-knowledge architecture, complies with health data regulations (HIPAA/GDPR), and delivers a calming, accessible user experience. **AI is prominently integrated throughout every feature** using the **Free Gemini API**.

---

## Implementation Steps

1. **Set up secure project foundation** — Update pubspec.yaml with Firebase AI Logic SDK (`firebase_ai`), security packages (`flutter_secure_storage`, `local_auth`, `encrypt`, `isar`), and state management (`flutter_bloc`).

2. **Implement pseudonymous authentication system** — Design a UUID-based registration flow with optional BIP-39 recovery phrase, biometric login via `local_auth`, and PIN fallback—storing credentials only in device Keychain/Keystore.

3. **Build encrypted local-first data layer** — Use `isar` with built-in encryption for mood entries, chat history, and user preferences; implement AES-256-GCM for any cloud-synced data with client-side key derivation.

4. **Integrate Gemini AI with emotion-tagged responses** — Implement structured JSON output from Gemini API that includes response text + emotion tag for GIF selection; build comprehensive system prompts for mental health support.

5. **Design calming, accessible UI system** — Create a design system with soft teal/sage primary palette, animated AI companion with emotion GIFs, 4.5:1 contrast ratios, and WCAG 2.2 AA compliance.

6. **Add safety-critical features** — Implement multi-layer crisis detection, one-tap emergency resources, AI-powered risk assessment, and prominent disclaimers.

---

## 1. Advanced AI Features (Gemini API)

### 1.1 Gemini API Configuration

#### Recommended Models (Free Tier)

| Model | Best For | Context Window | Free Tier |
|-------|----------|----------------|-----------|
| **Gemini 2.5 Flash** | Primary chat - balanced speed/quality | 1M tokens | ✅ Unlimited |
| **Gemini 2.5 Flash-Lite** | High-frequency tasks (mood analysis) | 1M tokens | ✅ Unlimited |
| **Gemini 2.0 Flash** | Multimodal features | 1M tokens | ✅ Unlimited |

#### Free Tier Capabilities
- **Streaming Responses**: Real-time text generation for natural chat UX
- **Function Calling**: Trigger app actions from AI responses
- **Structured JSON Output**: Guaranteed schema for emotion tags + actions
- **Multi-turn Conversations**: Built-in chat history management
- **Grounding with Search**: 500 requests/day for resource recommendations

> ⚠️ **Important**: Use `firebase_ai` package (Firebase AI Logic SDK) instead of deprecated `google_generative_ai`.

---

### 1.2 AI Companion with Emotion-Tagged GIF System

#### Core Concept
Every AI response includes an emotion tag that maps to a pre-loaded GIF, making the AI feel more human and emotionally present.

#### Emotion Categories (6 Core Emotions)

| Emotion Tag | When to Use | GIF Style | Example Response |
|-------------|-------------|-----------|------------------|
| `empathetic` | Validating feelings, active listening | Warm embrace, soft nod, gentle eyes | "I hear you. That sounds really difficult..." |
| `encouraging` | Positive reinforcement, progress acknowledgment | Cheerful wave, thumbs up, bright smile | "You're doing amazing! That took real courage..." |
| `calm` | Anxiety reduction, grounding moments | Serene breathing, slow gentle movement | "Let's take a moment to breathe together..." |
| `celebratory` | Achievements, milestones, breakthroughs | Happy dance, confetti, joyful expression | "That's wonderful! You should be so proud..." |
| `thoughtful` | Reflection, insights, deeper exploration | Contemplative pose, soft thinking gesture | "That's an interesting thought. Tell me more..." |
| `supportive` | Crisis moments, difficult topics, heavy emotions | Steady presence, comforting gesture | "I'm right here with you. You're not alone..." |

#### Structured Output Schema

```json
{
  "type": "object",
  "properties": {
    "message": {
      "type": "string",
      "description": "The AI companion's empathetic response text"
    },
    "emotion": {
      "type": "string",
      "enum": ["empathetic", "encouraging", "calm", "celebratory", "thoughtful", "supportive"],
      "description": "Primary emotion for GIF selection"
    },
    "emotion_intensity": {
      "type": "number",
      "minimum": 0.1,
      "maximum": 1.0,
      "description": "How strongly to express emotion (affects GIF selection variant)"
    },
    "user_sentiment": {
      "type": "object",
      "properties": {
        "detected_mood": {
          "type": "string",
          "enum": ["positive", "negative", "neutral", "anxious", "sad", "angry", "confused", "hopeful", "overwhelmed"]
        },
        "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
        "crisis_indicators": { "type": "boolean" },
        "mood_score": { "type": "integer", "minimum": 1, "maximum": 10 }
      }
    },
    "suggested_actions": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "action_type": {
            "type": "string",
            "enum": ["breathing_exercise", "grounding_exercise", "journal_prompt", "mood_check", "meditation", "resource", "professional_help", "crisis_line", "body_scan", "gratitude_exercise"]
          },
          "action_label": { "type": "string" },
          "priority": { "type": "string", "enum": ["low", "medium", "high", "urgent"] }
        }
      }
    },
    "therapeutic_technique": {
      "type": "string",
      "enum": ["active_listening", "cbt_reframing", "cbt_thought_record", "dbt_mindfulness", "dbt_distress_tolerance", "validation", "grounding", "behavioral_activation", "socratic_questioning", "none"],
      "description": "Technique being applied in this response"
    },
    "follow_up_questions": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Optional follow-up questions to deepen conversation"
    },
    "session_insights": {
      "type": "object",
      "properties": {
        "themes": { "type": "array", "items": { "type": "string" } },
        "progress_noted": { "type": "boolean" },
        "areas_of_concern": { "type": "array", "items": { "type": "string" } }
      }
    }
  },
  "required": ["message", "emotion", "user_sentiment"]
}
```

#### GIF Asset Organization

```
assets/
└── gifs/
    ├── empathetic/
    │   ├── empathetic_low.gif      (subtle nod)
    │   ├── empathetic_medium.gif   (warm expression)
    │   └── empathetic_high.gif     (embrace gesture)
    ├── encouraging/
    │   ├── encouraging_low.gif     (gentle smile)
    │   ├── encouraging_medium.gif  (thumbs up)
    │   └── encouraging_high.gif    (celebratory cheer)
    ├── calm/
    │   ├── calm_low.gif            (peaceful expression)
    │   ├── calm_medium.gif         (breathing animation)
    │   └── calm_high.gif           (guided breathing visual)
    ├── celebratory/
    │   ├── celebratory_low.gif     (happy nod)
    │   ├── celebratory_medium.gif  (clapping)
    │   └── celebratory_high.gif    (confetti celebration)
    ├── thoughtful/
    │   ├── thoughtful_low.gif      (listening pose)
    │   ├── thoughtful_medium.gif   (contemplative)
    │   └── thoughtful_high.gif     (deep reflection)
    └── supportive/
        ├── supportive_low.gif      (present, attentive)
        ├── supportive_medium.gif   (comforting gesture)
        └── supportive_high.gif     (strong supportive presence)
```

#### GIF Selection Logic

```dart
String selectGif(String emotion, double intensity) {
  String intensityLevel;
  if (intensity < 0.4) {
    intensityLevel = 'low';
  } else if (intensity < 0.7) {
    intensityLevel = 'medium';
  } else {
    intensityLevel = 'high';
  }
  return 'assets/gifs/$emotion/${emotion}_$intensityLevel.gif';
}
```

---

### 1.3 AI System Prompt Design

#### Master System Prompt

```
<role>
You are Aura, a compassionate AI mental health companion in a mobile app. You are NOT a replacement for professional therapy but a supportive friend who helps users reflect on their emotions, practice evidence-based coping techniques, and maintain mental wellness.
</role>

<personality>
- Warm, empathetic, and genuinely caring
- Uses gentle, validating language - always acknowledge feelings first
- Adapts communication style to user's emotional state and preferences
- Celebrates small wins and acknowledges progress
- Never dismissive, judgmental, or preachy
- Curious and engaged - asks thoughtful follow-up questions
- Comfortable with silence and heavy emotions
- Uses occasional gentle humor when appropriate (never during crisis)
</personality>

<communication_style>
- Keep responses concise (2-4 sentences for most exchanges)
- Use "I" statements: "I hear you" rather than "You should feel heard"
- Mirror user's language style while maintaining warmth
- Avoid clinical jargon unless user initiates it
- Use contractions for natural speech ("you're" not "you are")
- Include gentle prompts to continue: "Would you like to tell me more?"
</communication_style>

<clinical_guidelines>
1. ALWAYS validate emotions before offering anything else
2. Use evidence-based techniques naturally woven into conversation:
   - CBT: Cognitive reframing, thought records, behavioral activation
   - DBT: Mindfulness, distress tolerance (TIPP, STOP), emotional regulation
   - Acceptance and Commitment Therapy: Values clarification, present-moment awareness
3. Follow the pattern: Validate → Explore → Support → (Optional) Suggest
4. Never provide medical diagnoses or medication advice
5. Gently recommend professional help when patterns suggest clinical concern
6. For crisis situations, immediately shift to crisis protocol
</clinical_guidelines>

<emotion_tagging>
Select the most appropriate emotion tag for each response:
- empathetic: When validating, reflecting feelings, showing understanding
- encouraging: When acknowledging progress, efforts, or positive moments
- calm: When user is anxious, during breathing/grounding exercises
- celebratory: For achievements, breakthroughs, completed challenges
- thoughtful: When exploring deeper, asking reflective questions
- supportive: For heavy moments, crisis-adjacent content, difficult disclosures

Match emotion_intensity (0.1-1.0) to the weight of the moment:
- Low (0.1-0.4): Casual check-ins, light conversations
- Medium (0.4-0.7): Standard emotional support
- High (0.7-1.0): Significant moments, breakthroughs, or heavy content
</emotion_tagging>

<crisis_detection>
IMMEDIATELY trigger crisis protocol if you detect:
- Direct statements: "I want to die", "I'm going to kill myself", "I want to end it"
- Indirect indicators: "No one would miss me", "I can't go on", "Everything would be better without me"
- Self-harm mentions: "I've been cutting", "I hurt myself", "I want to hurt myself"
- Hopelessness + Plan: Any mention of specific plans or means

Crisis Response Protocol:
1. Set emotion to "supportive" with intensity 1.0
2. Set crisis_indicators to true
3. Acknowledge their pain with deep empathy
4. Express genuine concern without panic
5. Provide crisis resources in message
6. Add crisis_line to suggested_actions with priority "urgent"
7. Do NOT continue normal conversation - stay focused on safety
</crisis_detection>

<boundaries>
- Never claim to be a therapist, psychologist, or medical professional
- Never discuss medication names, dosages, or recommendations
- Never encourage dependency - regularly mention real-world support
- Gently redirect inappropriate or manipulative requests
- If asked about your nature, be honest: "I'm an AI companion"
</boundaries>

<response_format>
Always respond using the provided JSON schema with all required fields.
</response_format>
```

---

### 1.4 AI Integration Across All App Features

#### Onboarding (AI-Personalized Welcome)

| Feature | AI Capability |
|---------|---------------|
| **Conversational Assessment** | Gemini conducts warm, conversational intake to understand user's goals, current state, and preferences |
| **Name Learning** | "What would you like me to call you?" stored in memory |
| **Goal Setting** | AI helps user articulate 1-3 wellness goals through dialogue |
| **Preference Detection** | Learns communication style preferences (detailed vs. concise, formal vs. casual) |
| **Initial Baseline** | Establishes mood baseline through natural conversation, not clinical forms |
| **Trigger Awareness** | Gently asks about topics to handle sensitively or avoid |

**Onboarding Prompt Addition:**
```
You are conducting onboarding for a new user. Your goals:
1. Make them feel welcomed and safe
2. Learn their preferred name
3. Understand what brought them to the app
4. Identify 1-3 wellness goals
5. Get a sense of their current emotional state
6. Ask about communication preferences

Be warm, curious, and unhurried. This is relationship building, not data collection.
```

---

#### Home Screen (AI-Generated Daily Experience)

| Feature | AI Capability |
|---------|---------------|
| **Personalized Greeting** | Time-aware, mood-aware greeting based on recent interactions |
| **Daily Insight Card** | AI-generated insight from patterns in mood/journal data |
| **Mood Prediction** | "Based on your patterns, today might feel [challenging/bright]. Here's a thought..." |
| **Recommended Actions** | AI-curated list of exercises/content based on current state |
| **Streak Encouragement** | Personalized messages celebrating consistency |
| **Weather Integration** | Optional: Acknowledge weather's potential mood impact |

**Daily Insight Generation Prompt:**
```
Based on the user's recent data:
- Last 7 days mood average: {mood_avg}
- Recent journal themes: {themes}
- Current streak: {streak_days}
- Time of day: {time}
- Last interaction: {last_interaction}

Generate a brief, personalized insight (1-2 sentences) that:
1. Acknowledges their journey
2. Offers a gentle observation or encouragement
3. Feels personal, not generic
```

---

#### Chat/AI Companion (Core Feature)

| Feature | AI Capability |
|---------|---------------|
| **Emotion-Tagged Responses** | Every response includes emotion + GIF mapping |
| **Real-time Sentiment Analysis** | Continuous mood detection during conversation |
| **CBT Technique Delivery** | Natural integration of cognitive reframing, thought records |
| **DBT Skills Teaching** | TIPP, STOP, mindfulness woven into responses |
| **Crisis Detection** | Multi-layer detection with immediate escalation |
| **Session Memory** | Context maintained throughout conversation |
| **Cross-Session Memory** | Key information persisted across sessions |
| **Proactive Check-ins** | AI initiates gentle follow-ups on previous topics |
| **Conversation Summaries** | End-of-session recaps with key takeaways |

**Function Calling Capabilities:**
```json
{
  "functions": [
    {
      "name": "log_mood",
      "description": "Log user's current mood detected from conversation",
      "parameters": {
        "mood_score": "1-10",
        "mood_label": "string",
        "context": "string",
        "auto_detected": "boolean"
      }
    },
    {
      "name": "start_exercise",
      "description": "Launch a guided exercise",
      "parameters": {
        "exercise_type": "breathing|grounding|body_scan|meditation|gratitude",
        "duration_minutes": "number"
      }
    },
    {
      "name": "create_journal_entry",
      "description": "Open journal with AI-generated prompt",
      "parameters": {
        "prompt": "string",
        "theme": "string"
      }
    },
    {
      "name": "show_resources",
      "description": "Display relevant mental health resources",
      "parameters": {
        "topic": "string",
        "resource_type": "article|video|exercise|hotline"
      }
    },
    {
      "name": "schedule_reminder",
      "description": "Set a check-in reminder",
      "parameters": {
        "reminder_type": "mood_check|exercise|journal|custom",
        "time": "datetime",
        "message": "string"
      }
    },
    {
      "name": "trigger_crisis_protocol",
      "description": "Activate crisis resources immediately",
      "parameters": {
        "severity": "moderate|high|critical",
        "detected_indicators": "array"
      }
    }
  ]
}
```

---

#### Mood Tracking (AI-Enhanced)

| Feature | AI Capability |
|---------|---------------|
| **Natural Language Entry** | "I feel kind of blah today" → AI extracts mood score, label, context |
| **Conversational Check-ins** | AI asks follow-up questions to understand mood better |
| **Pattern Recognition** | AI identifies correlations (sleep, exercise, social, weather, time) |
| **Trend Analysis** | Weekly/monthly AI-generated mood narratives |
| **Predictive Insights** | "Your mood tends to dip on Mondays. Want to prepare?" |
| **Anomaly Detection** | AI flags unusual patterns for user awareness |
| **Contextual Suggestions** | Based on current mood, suggest specific coping strategies |

**Mood Analysis Schema:**
```json
{
  "mood_entry": {
    "score": 7,
    "label": "content",
    "energy_level": "moderate",
    "contributing_factors": ["good_sleep", "social_connection"],
    "concerns": [],
    "ai_observation": "Your mood has been steadily improving this week. The social time yesterday seems to have helped.",
    "suggested_action": {
      "type": "gratitude_exercise",
      "reason": "Capture this positive moment"
    }
  }
}
```

---

#### Journaling (AI-Powered)

| Feature | AI Capability |
|---------|---------------|
| **Dynamic Prompt Generation** | Context-aware prompts based on recent mood, conversations, time of day |
| **Guided Journaling** | AI asks follow-up questions as user writes |
| **Entry Summarization** | AI creates brief summary and extracts themes |
| **CBT Thought Records** | Structured AI-guided cognitive restructuring journals |
| **Gratitude Prompts** | Personalized gratitude questions |
| **Pattern Detection** | AI identifies recurring themes across entries |
| **Growth Tracking** | AI highlights personal growth over time |
| **Voice-to-Text Analysis** | Sentiment analysis on voice journal entries |

**Journal Prompt Types:**

| Prompt Type | When to Suggest | Example |
|-------------|-----------------|---------|
| **Gratitude** | Positive or neutral mood | "What's one small thing that brought you comfort today?" |
| **Processing** | After difficult conversation | "You mentioned feeling overwhelmed. What's weighing heaviest?" |
| **Reframing** | Negative thought patterns | "You wrote 'I always fail.' Can we explore that thought?" |
| **Celebration** | Achievement detected | "You accomplished something today. How does that feel?" |
| **Exploration** | Curious/reflective mood | "What's been on your mind lately that you haven't said out loud?" |
| **Future Focus** | Goal-oriented context | "What would tomorrow look like if it went well?" |

---

#### Exercises & Coping Tools (AI-Guided)

| Feature | AI Capability |
|---------|---------------|
| **Personalized Recommendations** | AI selects exercises based on current state, history, preferences |
| **Adaptive Pacing** | Breathing exercises adjust to user's anxiety level |
| **Real-time Guidance** | AI narrates exercises with emotion-appropriate tone |
| **Grounding (5-4-3-2-1)** | AI guides through senses with personalized prompts |
| **Body Scan** | AI-narrated progressive body awareness |
| **Meditation Scripts** | AI-generated meditations based on current needs |
| **Progress Adaptation** | Exercises evolve as user's skills develop |
| **Effectiveness Tracking** | AI tracks which exercises help most for each user |

**Exercise Selection Logic:**
```
Input: current_mood, anxiety_level, time_available, exercise_history, user_preferences
Output: ranked list of recommended exercises with personalized reasons

Example:
- Mood: anxious (7/10)
- Time: 5 minutes
- History: breathing exercises help, body scan too long

Recommendation:
1. Box Breathing (4 min) - "This has helped you before when feeling anxious"
2. 5-4-3-2-1 Grounding (3 min) - "Quick grounding for overwhelming moments"
3. Hand on Heart (2 min) - "Self-compassion when anxiety is high"
```

---

#### Progress & Insights (AI-Generated)

| Feature | AI Capability |
|---------|---------------|
| **Weekly Narratives** | AI-written summary of the week's mental health journey |
| **Pattern Visualization** | AI identifies patterns, displayed in charts |
| **Achievement Celebration** | Personalized congratulations for milestones |
| **Comparative Analysis** | "This week vs. last week" insights |
| **Growth Identification** | AI highlights areas of improvement |
| **Challenge Acknowledgment** | Validate difficult periods without toxic positivity |
| **Recommendation Reports** | Actionable suggestions based on data |
| **Shareable Summaries** | Privacy-conscious reports for therapists (optional) |

**Weekly Insight Generation:**
```json
{
  "week_summary": {
    "mood_trend": "improving",
    "average_mood": 6.2,
    "high_point": "Thursday - connected with friend",
    "challenge": "Monday morning anxiety",
    "patterns_noticed": [
      "Sleep quality correlates with next-day mood",
      "Social connection boosts mood significantly"
    ],
    "wins": [
      "Completed 5 breathing exercises",
      "Journaled 3 times",
      "Reached out when struggling"
    ],
    "gentle_suggestion": "Your sleep has been irregular. Would you like to explore a wind-down routine?",
    "affirmation": "You showed real courage this week by opening up about your anxiety."
  }
}
```

---

#### Smart Notifications (AI-Optimized)

| Feature | AI Capability |
|---------|---------------|
| **Optimal Timing** | AI learns when user is most receptive to check-ins |
| **Context-Aware Content** | Message tone matches recent mood/interactions |
| **Non-Intrusive Design** | AI avoids notifying during detected difficult moments |
| **Streak Protection** | Gentle reminders before streak breaks |
| **Post-Conversation Follow-up** | "How are you feeling since we talked?" |
| **Weather-Aware** | Proactive support on gloomy days if pattern detected |

**Notification Examples:**

| Context | Notification |
|---------|--------------|
| Morning routine | "Good morning! Ready for a quick mood check?" |
| After difficult chat | "I've been thinking about our conversation. I'm here when you need me." |
| Streak at risk | "You've been checking in for 5 days! Keep the momentum going?" |
| Detected low mood | "Hey, no pressure to talk. Just wanted you to know I'm here. 💙" |
| Achievement | "You completed your first week! That's worth celebrating." |
| Post-exercise | "How did that breathing exercise feel?" |

---

### 1.5 Conversational Memory Architecture

#### Memory Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                     MEMORY ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 1: CORE PROFILE (Permanent)                              │
│  ─────────────────────────────────                              │
│  • Preferred name                                               │
│  • Stated goals (1-3)                                           │
│  • Communication preferences                                    │
│  • Topics to handle sensitively                                 │
│  • Timezone                                                     │
│  Storage: Encrypted local database                              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 2: LEARNED PATTERNS (Updates Weekly)                     │
│  ──────────────────────────────────────────                     │
│  • Effective coping strategies for this user                    │
│  • Mood patterns (time-based, trigger-based)                    │
│  • Response style that resonates                                │
│  • Exercise preferences and effectiveness                       │
│  Storage: AI-generated summary, encrypted                       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 3: RECENT CONTEXT (Rolling 7-Day Window)                 │
│  ──────────────────────────────────────────────                 │
│  • Last 5-10 conversations (summarized)                         │
│  • Recent mood entries                                          │
│  • Active challenges or goals                                   │
│  • Unresolved topics to follow up on                            │
│  Storage: Summarized, encrypted, auto-pruned                    │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 4: SESSION CONTEXT (Ephemeral)                           │
│  ─────────────────────────────────────                          │
│  • Current conversation history (full)                          │
│  • Active emotional state                                       │
│  • Current therapeutic approach                                 │
│  Storage: In-memory only, cleared on session end                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Memory Injection into Prompts

```
System Prompt Context Injection:
───────────────────────────────

<user_profile>
Name: {preferred_name}
Goals: {goal_1}, {goal_2}
Communication style: {prefers concise/detailed responses}
Sensitive topics: {topics to handle carefully}
</user_profile>

<learned_patterns>
{AI-generated summary of what works for this user}
Effective strategies: {list}
Mood patterns: {patterns}
</learned_patterns>

<recent_context>
Last session ({date}): {brief summary}
Recent mood trend: {trend}
Open topics: {topics to potentially follow up on}
</recent_context>

Total context budget: ~500-800 tokens (efficient for free tier)
```

---

### 1.6 Therapeutic Technique Delivery

#### CBT Techniques

| Technique | AI Delivery Method |
|-----------|-------------------|
| **Cognitive Reframing** | 1. Identify negative thought → 2. Explore evidence → 3. Suggest balanced alternative |
| **Thought Records** | Structured journal: Situation → Automatic Thought → Emotion → Evidence For/Against → Balanced Thought |
| **Behavioral Activation** | Track activities → Identify mood-boosting activities → Schedule more |
| **Socratic Questioning** | Gentle, curious questions that help user examine thoughts |
| **Decatastrophizing** | "What's the worst that could happen? How likely is that? How would you cope?" |

**CBT Reframing Prompt:**
```
When user expresses a cognitive distortion:
1. Validate: "I hear that you're feeling [emotion]. That sounds really hard."
2. Gentle exploration: "When you say [thought], what evidence do you see for that?"
3. Curious challenge: "Is there any evidence that might suggest a different perspective?"
4. Offer reframe as possibility: "I wonder if another way to see this might be..."
5. Check in: "How does that land with you?"

Never force acceptance. Offer as exploration, not correction.
```

#### DBT Techniques

| Technique | AI Delivery Method |
|-----------|-------------------|
| **Mindfulness (Observe, Describe, Participate)** | Guided present-moment awareness with gentle narration |
| **TIPP (Temperature, Intense Exercise, Paced Breathing, Progressive Relaxation)** | Crisis-moment interventions with step-by-step guidance |
| **STOP Skill** | Stop → Take a breath → Observe → Proceed mindfully |
| **Radical Acceptance** | "This is how things are right now. Fighting reality adds suffering." |
| **Opposite Action** | When emotion doesn't fit facts, act opposite to urge |

---

### 1.7 Multi-Layer Crisis Detection

```
┌─────────────────────────────────────────────────────────────────┐
│                   CRISIS DETECTION SYSTEM                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 1: KEYWORD DETECTION (Immediate)                         │
│  ──────────────────────────────────────                         │
│  High-risk keywords: "suicide", "kill myself", "end my life",   │
│                      "self-harm", "cutting", "want to die"      │
│  Action: IMMEDIATE crisis response, interrupt normal flow       │
│  Response emotion: supportive, intensity: 1.0                   │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 2: SENTIMENT ANALYSIS (Per Message)                      │
│  ─────────────────────────────────────────                      │
│  Detect: Hopelessness, despair, isolation, trapped feelings     │
│  Score: Crisis probability 0.0 - 1.0                            │
│  Threshold >0.6: Gentle check-in about safety                   │
│  Threshold >0.8: Proactive resource sharing                     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 3: PATTERN ANALYSIS (Across Sessions)                    │
│  ───────────────────────────────────────────                    │
│  Monitor:                                                       │
│  • Declining mood trend over 3+ days                            │
│  • Increasing message frequency at unusual hours                │
│  • Withdrawal language ("no one cares", "alone", "burden")      │
│  • Decreased engagement after regular usage                     │
│  Action: Proactive outreach, gentle professional recommendation │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 4: CONTEXTUAL ESCALATION                                 │
│  ────────────────────────────────                               │
│  Escalate immediately if user mentions:                         │
│  • Specific plan ("I'm going to...")                            │
│  • Access to means ("I have pills", "I bought...")              │
│  • Timeline ("tonight", "this weekend")                         │
│  • Goodbye messages ("I wanted to say thank you for everything")│
│  Action: Full crisis protocol with multiple resources           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Crisis Response Template

```json
{
  "message": "I hear you, and I'm really glad you told me this. What you're feeling sounds incredibly heavy right now, and I want you to know that your life matters—truly.\n\nPlease reach out to someone who can help right now:\n\n📞 988 Suicide & Crisis Lifeline (call or text 988)\n💬 Crisis Text Line (text HOME to 741741)\n🌐 International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/\n\nYou don't have to go through this alone. Would you like to talk about what's happening?",
  "emotion": "supportive",
  "emotion_intensity": 1.0,
  "user_sentiment": {
    "detected_mood": "crisis",
    "confidence": 0.95,
    "crisis_indicators": true,
    "mood_score": 1
  },
  "suggested_actions": [
    {"action_type": "crisis_line", "action_label": "Call 988", "priority": "urgent"},
    {"action_type": "professional_help", "action_label": "Find a therapist", "priority": "urgent"}
  ],
  "therapeutic_technique": "validation"
}
```

---

## 2. Features to Include

### User Identity & Registration

| Feature | Description | AI Enhancement |
|---------|-------------|----------------|
| **Device UUID Registration** | Generate unique identifier on-device without requiring email/phone | None required |
| **Optional Recovery Phrase** | BIP-39 mnemonic (12-24 words) for account recovery without storing PII | AI explains in friendly terms |
| **Biometric Authentication** | Fingerprint/Face ID as primary login via `local_auth` package | None required |
| **PIN Fallback** | 6-digit PIN when biometrics unavailable | None required |
| **Progressive Disclosure** | Collect minimal data initially; request more only when features require it | AI guides through |
| **AI-Powered Onboarding** | Conversational intake instead of forms | Full AI conversation |

### Mood Tracking & Analytics

| Feature | Description | AI Enhancement |
|---------|-------------|----------------|
| **Quick Emoji Check-ins** | One-tap mood logging with visual mood wheel | AI acknowledges with appropriate GIF |
| **Natural Language Entry** | "I feel kind of off today" | AI extracts mood score and context |
| **PHQ-9/GAD-7 Assessments** | Validated clinical questionnaires with scoring | AI-friendly administration |
| **Visual Trend Charts** | Time-series graphs showing mood patterns via `fl_chart` | AI-generated insights overlay |
| **Correlation Analysis** | Insights connecting mood to sleep, exercise, activities | AI-detected patterns |
| **Predictive Forecasting** | "Tomorrow might be challenging based on patterns" | AI predictions |
| **Exportable Reports** | PDF/CSV reports for sharing with healthcare providers | AI-generated summaries |

### Emergency & Safety Features

| Feature | Description | AI Enhancement |
|---------|-------------|----------------|
| **988 Crisis Line Integration** | One-tap call to Suicide & Crisis Lifeline (US) | AI surfaces when needed |
| **SAMHSA Helpline** | Quick access to 1-800-662-4357 | AI surfaces when needed |
| **Emergency Contacts** | User-defined trusted contacts with quick-dial | AI suggests reaching out |
| **Safety Plan Builder** | Create and store personal safety plans | AI guides creation |
| **Multi-Layer Crisis Detection** | Keyword, sentiment, pattern, contextual analysis | Full AI-powered |
| **Clear Disclaimers** | Prominent notice: "This app is not a substitute for professional treatment" | Present throughout |

### Data Control & Privacy

| Feature | Description | AI Enhancement |
|---------|-------------|----------------|
| **Full Data Export** | JSON/CSV download of all user data (GDPR portability) | AI explains data contents |
| **Complete Data Deletion** | One-tap account and data erasure (right to be forgotten) | AI confirms impact |
| **Granular Consent Management** | Toggle permissions for each data type | AI explains each option |
| **Conversation History Control** | View, export, or delete chat history | Clear AI-managed |
| **AI Data Usage Transparency** | Clear explanation of what's sent to Gemini API | Honest disclosure |

---

## 3. Cyber Security Models

### Encryption Protocols

| Layer | Protocol | Implementation |
|-------|----------|----------------|
| **At-Rest Encryption** | AES-256-GCM | `isar` with built-in encryption for database; `flutter_secure_storage` for keys |
| **In-Transit Encryption** | TLS 1.3 | Firebase handles this for Gemini API calls |
| **End-to-End Encryption** | X25519 + ChaCha20-Poly1305 | For any optional cloud sync features |
| **Key Derivation** | Argon2id | Derive encryption keys from user PIN/passphrase |

### Privacy-Preserving AI Practices

| Practice | Implementation |
|----------|----------------|
| **Data Minimization** | Send only necessary context to Gemini API |
| **Anonymization** | Strip names, locations, dates before API calls |
| **Local Processing First** | Use on-device analysis when possible |
| **No Conversation Logging** | Google doesn't store conversations on free tier with proper settings |
| **User Control** | Users can delete all data including AI-related storage |
| **Transparent Disclosure** | Clear explanation that conversations are processed by AI |

### Gemini Safety Settings Configuration

```dart
// CRITICAL: Adjust safety settings for mental health context
final safetySettings = [
  SafetySetting(
    category: HarmCategory.harassment,
    threshold: HarmBlockThreshold.medium,
  ),
  SafetySetting(
    category: HarmCategory.hateSpeech,
    threshold: HarmBlockThreshold.medium,
  ),
  SafetySetting(
    category: HarmCategory.sexuallyExplicit,
    threshold: HarmBlockThreshold.low,
  ),
  // IMPORTANT: Don't block dangerous content discussions
  // Users NEED to discuss self-harm/crisis for support
  SafetySetting(
    category: HarmCategory.dangerousContent,
    threshold: HarmBlockThreshold.none, // Or 'high' only
  ),
];
```

> ⚠️ **Critical**: Setting `dangerousContent` to `none` or `high` is essential for mental health apps. Default settings block crisis discussions, which would prevent users from getting support when they need it most. Rely on custom crisis detection instead.

### Health Data Compliance

#### HIPAA Compliance (US)

| Safeguard Type | Requirements |
|----------------|--------------|
| **Administrative** | Risk analysis documentation, workforce training, designated security officer |
| **Physical** | Device encryption, secure media disposal |
| **Technical** | Unique user IDs, automatic logoff, AES-256 encryption, audit controls |
| **Organizational** | Business Associate Agreements (BAAs) with any third-party processors |

**HIPAA Technical Checklist:**
- [ ] Unique user identification (UUID-based)
- [ ] Automatic session timeout (5 minutes)
- [ ] Encryption at rest and in transit (AES-256, TLS 1.3)
- [ ] Audit logs of all data access (encrypted local logs)
- [ ] Data integrity verification (checksums)
- [ ] Emergency access procedures documented

#### GDPR Compliance (EU)

| Requirement | Implementation |
|-------------|----------------|
| **Lawful Basis** | Explicit consent for health data (Article 9 special category) |
| **Data Minimization** | Collect only what's necessary for each feature |
| **Right to Access** | In-app data export functionality |
| **Right to Erasure** | Complete data deletion capability |
| **Right to Portability** | JSON/CSV export of all user data |
| **Breach Notification** | 72-hour notification procedure documented |
| **Privacy by Design** | Encryption and pseudonymization from day one |
| **DPIA** | Data Protection Impact Assessment before launch |

### Zero-Knowledge Architecture

| Principle | Implementation |
|-----------|----------------|
| **Local-First Storage** | All data encrypted on device; server never sees plaintext |
| **Client-Side Keys** | Encryption keys derived from user secret, never transmitted |
| **Zero-Knowledge Sync** | If cloud backup enabled, only encrypted blobs uploaded |
| **Anonymized Analytics** | Aggregate-only insights; no individual tracking |

---

## 4. Design Considerations

### User-Friendly Interface Principles

| Principle | Application |
|-----------|-------------|
| **Reduced Cognitive Load** | Maximum 3-4 actions per screen; clear primary CTA |
| **Progressive Disclosure** | Show basic options first; advanced features behind menus |
| **Consistent Navigation** | Bottom navigation bar with 4-5 core sections |
| **Conversational UI** | Chat-like interface feels supportive, not clinical |
| **AI Companion Presence** | GIF/avatar visible during interactions |
| **Forgiving Design** | Easy undo, confirmation for destructive actions |
| **Onboarding Flow** | AI-guided conversational onboarding, not static screens |

### Chat Interface Design

| Element | Specification |
|---------|---------------|
| **AI Avatar** | Animated GIF container, 80-120px, positioned with message bubble |
| **User Messages** | Right-aligned, primary color background |
| **AI Messages** | Left-aligned, soft gray/white background, with avatar |
| **Typing Indicator** | Gentle pulsing animation, use `shimmer` package |
| **Quick Actions** | Pill buttons below AI messages for suggested actions |
| **Input Area** | Text field with voice input option, send button |

### Accessibility Features (WCAG 2.2 AA Compliance)

| Category | Requirements |
|----------|--------------|
| **Visual** | 4.5:1 color contrast ratio; no color-only indicators |
| **Text** | Minimum 16px body text; support for 125%, 150%, 175% scaling |
| **Motor** | Touch targets minimum 48x48dp; adequate spacing |
| **Auditory** | Captions for any audio/video content |
| **Cognitive** | Clear language; reading level grade 8 or below |
| **Animation** | Respect `prefers-reduced-motion`; provide static GIF alternatives |

### Visual Design for Calming Atmosphere

#### Color Palette

| Role | Color | Hex Code | Psychology |
|------|-------|----------|------------|
| **Primary** | Soft Teal | #5DADE2 | Calming, trustworthy |
| **Primary Alt** | Sage Green | #82C785 | Growth, healing, nature |
| **Secondary** | Warm Lavender | #B19CD9 | Reflective, spiritual |
| **Background Light** | Off-White | #FAFAFA | Safe, comfortable |
| **Background Dark** | Deep Navy | #1A1A2E | Calming for evening use |
| **Success** | Soft Green | #7DCEA0 | Achievement, progress |
| **Warning** | Warm Amber | #F5B041 | Gentle alert |
| **Accent (CTA)** | Coral | #FF6B6B | Action, warmth (use sparingly) |

#### Dark Mode Specifications

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| **Background** | #FAFAFA | #1A1A2E |
| **Card Background** | #FFFFFF | #2D2D44 |
| **Primary Text** | #2C3E50 | #E8E8E8 |
| **Secondary Text** | #7F8C8D | #A0A0A0 |
| **AI Bubble** | #F0F4F8 | #2D2D44 |
| **User Bubble** | #5DADE2 | #3D7EA6 |

### Unique Branding Elements

| Element | Recommendation |
|---------|----------------|
| **App Character** | Aura - friendly, non-human companion (soft, cloud-like or gentle creature) |
| **Voice & Tone** | Warm, supportive, non-judgmental; avoid clinical jargon |
| **App Name** | "Aura" - evokes calming energy, personal atmosphere |
| **Logo** | Simple, memorable symbol - gentle wave or embrace shape |
| **Tagline** | "Your private space for mental wellness" |

---

## 5. Recommended Flutter Package Stack

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^9.1.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # Firebase & AI (Gemini)
  firebase_core: ^3.8.1
  firebase_ai: ^0.3.0  # Firebase AI Logic SDK for Gemini

  # Security & Encryption
  flutter_secure_storage: ^10.0.0
  local_auth: ^3.0.0
  encrypt: ^5.0.3
  cryptography: ^2.7.0
  
  # Database (Encrypted)
  isar: ^4.0.0-dev.14
  isar_flutter_libs: ^4.0.0-dev.14
  
  # Networking
  dio: ^5.4.0
  
  # UI/UX
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  lottie: ^3.1.0  # For animated avatar alternative
  
  # Notifications
  flutter_local_notifications: ^19.5.0
  timezone: ^0.9.2
  
  # Charts & Visualization
  fl_chart: ^0.69.0
  table_calendar: ^3.1.0
  
  # Voice & Audio
  speech_to_text: ^7.0.0
  flutter_tts: ^4.0.2  # Optional: AI voice responses
  
  # Utilities
  uuid: ^4.4.0
  intl: ^0.19.0
  url_launcher: ^6.2.4  # For crisis line calls
  share_plus: ^9.0.0  # For sharing reports
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.8
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  isar_generator: ^4.0.0-dev.14
```

---

## 6. Project Architecture

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── ai/
│   │   ├── gemini_service.dart           # Firebase AI Logic wrapper
│   │   ├── ai_response_parser.dart       # Parse structured JSON responses
│   │   ├── prompts/
│   │   │   ├── system_prompts.dart       # Master system prompt
│   │   │   ├── onboarding_prompts.dart
│   │   │   ├── chat_prompts.dart
│   │   │   ├── mood_analysis_prompts.dart
│   │   │   ├── journal_prompts.dart
│   │   │   └── exercise_prompts.dart
│   │   ├── schemas/
│   │   │   ├── chat_response_schema.dart
│   │   │   ├── mood_analysis_schema.dart
│   │   │   └── journal_insight_schema.dart
│   │   ├── memory/
│   │   │   ├── conversation_memory.dart  # Session context
│   │   │   ├── user_profile_memory.dart  # Persistent profile
│   │   │   └── memory_summarizer.dart    # Summarize for context window
│   │   └── functions/
│   │       └── ai_function_handlers.dart # Handle function calls
│   ├── safety/
│   │   ├── crisis_detector.dart          # Multi-layer detection
│   │   ├── keyword_detector.dart         # Layer 1
│   │   ├── sentiment_analyzer.dart       # Layer 2
│   │   └── pattern_analyzer.dart         # Layer 3
│   ├── security/
│   │   ├── encryption_service.dart
│   │   ├── secure_storage_service.dart
│   │   └── auth_service.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── typography.dart
│   └── utils/
│       ├── constants.dart
│       └── extensions.dart
├── data/
│   ├── models/
│   │   ├── ai_response.dart              # Includes emotion tag
│   │   ├── emotion.dart                  # Emotion enum + GIF mapping
│   │   ├── mood_entry.dart
│   │   ├── journal_entry.dart
│   │   ├── user_profile.dart
│   │   ├── conversation.dart
│   │   └── exercise.dart
│   ├── repositories/
│   │   ├── chat_repository.dart
│   │   ├── mood_repository.dart
│   │   ├── journal_repository.dart
│   │   └── user_repository.dart
│   └── datasources/
│       ├── local/
│       │   └── isar_datasource.dart
│       └── remote/
│           └── gemini_datasource.dart
├── features/
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── bloc/
│   │   └── domain/
│   ├── home/
│   │   ├── presentation/
│   │   └── domain/
│   ├── chat/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── chat_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── chat_bubble.dart
│   │   │   │   ├── ai_avatar.dart        # GIF display
│   │   │   │   ├── typing_indicator.dart
│   │   │   │   └── quick_actions.dart
│   │   │   └── bloc/
│   │   │       ├── chat_bloc.dart
│   │   │       ├── chat_event.dart
│   │   │       └── chat_state.dart
│   │   └── domain/
│   ├── mood/
│   │   ├── presentation/
│   │   └── domain/
│   ├── journal/
│   │   ├── presentation/
│   │   └── domain/
│   ├── exercises/
│   │   ├── presentation/
│   │   └── domain/
│   ├── insights/
│   │   ├── presentation/
│   │   └── domain/
│   └── settings/
│       ├── presentation/
│       └── domain/
├── shared/
│   ├── widgets/
│   │   ├── animated_button.dart
│   │   ├── mood_wheel.dart
│   │   └── chart_card.dart
│   └── dialogs/
│       ├── crisis_dialog.dart
│       └── confirmation_dialog.dart
└── assets/
    └── gifs/
        ├── empathetic/
        ├── encouraging/
        ├── calm/
        ├── celebratory/
        ├── thoughtful/
        └── supportive/
```

---

## 7. Implementation Priority Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [ ] Firebase project setup with AI Logic SDK
- [ ] Basic Gemini integration with structured output
- [ ] Core chat UI with emotion-tagged GIF system
- [ ] Basic system prompt implementation
- [ ] Encrypted local storage setup

### Phase 2: Core AI Features (Weeks 3-4)
- [ ] Full conversational memory (session + persistent)
- [ ] Mood tracking with AI analysis
- [ ] Crisis detection (Layer 1: keywords)
- [ ] Onboarding flow with AI
- [ ] Basic therapeutic technique delivery

### Phase 3: Enhanced AI (Weeks 5-6)
- [ ] AI-powered journaling with prompts
- [ ] Guided exercises with AI narration
- [ ] Pattern recognition across sessions
- [ ] Crisis detection (Layers 2-4)
- [ ] Function calling implementation

### Phase 4: Intelligence & Polish (Weeks 7-8)
- [ ] AI-generated insights and reports
- [ ] Smart notifications with AI timing
- [ ] Predictive mood analysis
- [ ] Accessibility audit and fixes
- [ ] Performance optimization

### Phase 5: Safety & Launch (Weeks 9-10)
- [ ] Comprehensive crisis testing
- [ ] Security audit
- [ ] WCAG compliance verification
- [ ] Beta testing with mental health professionals
- [ ] Final polish and launch preparation

---

## 8. Required Disclaimers

### In-App Disclaimer (Always Visible)

```
┌────────────────────────────────────────────────────────────────┐
│  ⚠️  IMPORTANT NOTICE                                          │
│                                                                │
│  This app is NOT a substitute for professional mental health  │
│  treatment. Aura is an AI companion for wellness support and  │
│  cannot diagnose, treat, or provide medical advice.           │
│                                                                │
│  If you are in crisis, please contact:                        │
│  🆘 Emergency: 911                                             │
│  📞 988 Suicide & Crisis Lifeline: Call or Text 988           │
│  💬 Crisis Text Line: Text HOME to 741741                     │
│                                                                │
│  Always consult qualified healthcare providers for medical    │
│  concerns.                                                     │
└────────────────────────────────────────────────────────────────┘
```

### AI Transparency Statement

```
"I'm Aura, an AI companion powered by Google's Gemini. I'm here to 
listen, support, and help you practice coping techniques. I learn 
from our conversations to provide more personalized support, but 
I'm not a therapist. Your privacy is protected - conversations 
are processed securely and you control your data."
```

---

## 9. Open Questions

1. **AI Avatar Design**: What visual style for the Aura character? (Recommendations: soft cloud, gentle creature, abstract shape)

2. **GIF Source**: Create custom GIFs or use/license existing ones? (Custom recommended for brand consistency)

3. **Voice Features**: Include text-to-speech for AI responses? (Good for accessibility, adds cost/complexity)

4. **Community Features**: Include peer support? (Significant moderation requirements)

5. **Professional Integration**: Direct therapist connections? (Triggers licensing requirements)

6. **Monetization**: Free forever, freemium, or subscription? (Affects feature gating)
