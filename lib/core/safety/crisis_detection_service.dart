import '../../data/models/models.dart';

/// Comprehensive crisis detection service for mental health safety
/// Uses multi-layer detection with extensive keyword patterns and contextual analysis
class CrisisDetectionService {
  CrisisDetectionService._();
  static final CrisisDetectionService instance = CrisisDetectionService._();

  // ============== CRISIS KEYWORD CATEGORIES ==============
  
  /// Direct suicidal statements - CRITICAL level
  static const List<String> directSuicidalStatements = [
    'kill myself',
    'end my life',
    'take my own life',
    'commit suicide',
    'want to die',
    'going to kill myself',
    'planning to kill myself',
    'i will kill myself',
    'i\'m going to kill myself',
    'gonna kill myself',
    'going to end it',
    'ending it all',
    'end it all',
    'suicide',
    'suicidal',
    'hang myself',
    'shoot myself',
    'slit my wrists',
    'jump off',
    'step in front of',
  ];

  /// Passive suicidal ideation - HIGH level
  static const List<String> passiveSuicidalIdeation = [
    'wish i was dead',
    'wish i wasn\'t alive',
    'wish i wasn\'t here',
    'wish i could disappear',
    'better off dead',
    'everyone would be better off without me',
    'world would be better without me',
    'they\'d be happier if i was gone',
    'no one would miss me',
    'no one would care if i died',
    'no one would notice if i was gone',
    'wouldn\'t mind if i didn\'t wake up',
    'hope i don\'t wake up',
    'don\'t want to wake up',
    'tired of being alive',
    'tired of living',
    'tired of existing',
    'don\'t want to exist',
    'want to stop existing',
    'can\'t do this anymore',
    'can\'t take it anymore',
    'can\'t go on',
    'can\'t keep going',
    'can\'t continue',
    'no point in living',
    'no reason to live',
    'nothing to live for',
    'life isn\'t worth it',
    'life isn\'t worth living',
    'what\'s the point of living',
    'what\'s the point anymore',
  ];

  /// Self-harm indicators - HIGH level
  static const List<String> selfHarmIndicators = [
    'hurt myself',
    'hurting myself',
    'harm myself',
    'harming myself',
    'self-harm',
    'self harm',
    'selfharm',
    'cutting',
    'cut myself',
    'burn myself',
    'burning myself',
    'hit myself',
    'punish myself',
    'starving myself',
    'purging',
    'overdose',
    'take all my pills',
    'take all the pills',
    'scratch myself',
    'pulling my hair',
  ];

  /// Method-specific terms - CRITICAL level (indicates planning)
  static const List<String> methodSpecificTerms = [
    'pills',
    'medication',
    'knife',
    'razor',
    'gun',
    'rope',
    'noose',
    'bridge',
    'tall building',
    'train tracks',
    'railway',
    'carbon monoxide',
    'poison',
    'bleach',
    'hanging',
    'drowning',
    'suffocation',
  ];

  /// Farewell/goodbye language - CRITICAL level
  static const List<String> farewellLanguage = [
    'goodbye forever',
    'goodbye world',
    'final goodbye',
    'this is goodbye',
    'won\'t be here much longer',
    'won\'t be around much longer',
    'you won\'t see me again',
    'this is the last time',
    'giving away my things',
    'writing my note',
    'wrote a note',
    'letter to everyone',
    'telling people goodbye',
    'saying my goodbyes',
    'last message',
    'final message',
  ];

  /// Hopelessness indicators - MEDIUM to HIGH level
  static const List<String> hopelessnessIndicators = [
    'no hope',
    'hopeless',
    'nothing will change',
    'never get better',
    'always be this way',
    'no way out',
    'trapped',
    'no escape',
    'stuck forever',
    'pointless',
    'meaningless',
    'empty inside',
    'completely alone',
    'no one understands',
    'no one cares',
    'nobody cares',
    'all alone',
    'totally alone',
    'abandoned',
    'worthless',
    'useless',
    'failure',
    'complete failure',
    'burden',
    'i\'m a burden',
    'burden to everyone',
    'burden to my family',
    'they\'d be better off',
    'dragging everyone down',
    'ruining everything',
    'ruin everyone\'s life',
    'hate myself',
    'disgusted with myself',
    'can\'t stand myself',
    'don\'t deserve to live',
    'don\'t deserve happiness',
    'don\'t deserve anything',
    'i deserve to suffer',
    'i deserve this pain',
  ];

  /// Distress and severe emotional pain - MEDIUM level
  static const List<String> severeDistressIndicators = [
    'can\'t breathe',
    'suffocating',
    'drowning in',
    'unbearable pain',
    'unbearable',
    'excruciating',
    'agony',
    'torture',
    'hell',
    'living hell',
    'nightmare',
    'can\'t stop crying',
    'crying for hours',
    'breakdown',
    'breaking down',
    'falling apart',
    'completely broken',
    'shattered',
    'devastated',
    'destroyed',
    'numb',
    'feel nothing',
    'don\'t feel anything',
    'lost all feeling',
    'disconnected',
    'dissociating',
    'not real',
    'nothing feels real',
    'going crazy',
    'losing my mind',
    'out of control',
    'panic',
    'panicking',
    'anxiety attack',
    'panic attack',
    'can\'t function',
    'can\'t cope',
    'not coping',
  ];

  /// Harm to others indicators - CRITICAL level
  static const List<String> harmToOthersIndicators = [
    'hurt someone',
    'kill someone',
    'want to hurt',
    'want to kill',
    'murder',
    'violent thoughts',
    'thoughts of violence',
    'homicidal',
    'harm others',
    'hurt them',
    'make them pay',
    'revenge',
    'get back at',
  ];

  /// Recent loss or trauma - contextual HIGH risk
  static const List<String> recentTraumaIndicators = [
    'just found out',
    'just lost',
    'just died',
    'passed away',
    'death in family',
    'funeral',
    'divorce',
    'breakup',
    'cheated on',
    'fired',
    'lost my job',
    'kicked out',
    'homeless',
    'abused',
    'assaulted',
    'raped',
    'molested',
    'attacked',
    'accident',
    'diagnosed with',
    'terminal',
    'cancer',
  ];

  // ============== CRISIS DETECTION METHODS ==============

  /// Perform comprehensive crisis assessment on text
  CrisisAssessment assessText(String text) {
    final lowerText = text.toLowerCase();
    final detectedPatterns = <CrisisPattern>[];
    var maxSeverity = CrisisSeverity.none;

    // Check each category
    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: directSuicidalStatements,
      category: 'direct_suicidal',
      severity: CrisisSeverity.critical,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: farewellLanguage,
      category: 'farewell',
      severity: CrisisSeverity.critical,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: harmToOthersIndicators,
      category: 'harm_to_others',
      severity: CrisisSeverity.critical,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    // Method terms bump severity if other indicators present
    final hasMethodTerms = _checkPatternsPresent(lowerText, methodSpecificTerms);
    if (hasMethodTerms && detectedPatterns.isNotEmpty) {
      maxSeverity = CrisisSeverity.critical;
      _addPattern(detectedPatterns, 'method_mentioned', CrisisSeverity.critical, 
          methodSpecificTerms.firstWhere((p) => lowerText.contains(p), orElse: () => ''));
    }

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: passiveSuicidalIdeation,
      category: 'passive_suicidal',
      severity: CrisisSeverity.high,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: selfHarmIndicators,
      category: 'self_harm',
      severity: CrisisSeverity.high,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: recentTraumaIndicators,
      category: 'recent_trauma',
      severity: CrisisSeverity.medium,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    // Upgrade trauma to high if combined with hopelessness
    if (detectedPatterns.any((p) => p.category == 'recent_trauma')) {
      final hasHopelessness = _checkPatternsPresent(lowerText, hopelessnessIndicators);
      if (hasHopelessness && maxSeverity.index < CrisisSeverity.high.index) {
        maxSeverity = CrisisSeverity.high;
      }
    }

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: hopelessnessIndicators,
      category: 'hopelessness',
      severity: CrisisSeverity.medium,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    maxSeverity = _checkPatterns(
      lowerText: lowerText,
      patterns: severeDistressIndicators,
      category: 'severe_distress',
      severity: CrisisSeverity.low,
      currentMax: maxSeverity,
      detectedPatterns: detectedPatterns,
    );

    // Multiple pattern categories increase severity
    final uniqueCategories = detectedPatterns.map((p) => p.category).toSet();
    if (uniqueCategories.length >= 3 && maxSeverity.index < CrisisSeverity.high.index) {
      maxSeverity = CrisisSeverity.high;
    }

    return CrisisAssessment(
      severity: maxSeverity,
      detectedPatterns: detectedPatterns,
      requiresImmediateResources: maxSeverity == CrisisSeverity.critical || 
                                   maxSeverity == CrisisSeverity.high,
      timestamp: DateTime.now(),
    );
  }

  CrisisSeverity _checkPatterns({
    required String lowerText,
    required List<String> patterns,
    required String category,
    required CrisisSeverity severity,
    required CrisisSeverity currentMax,
    required List<CrisisPattern> detectedPatterns,
  }) {
    for (final pattern in patterns) {
      if (lowerText.contains(pattern)) {
        _addPattern(detectedPatterns, category, severity, pattern);
        if (severity.index > currentMax.index) {
          return severity;
        }
      }
    }
    return currentMax;
  }

  bool _checkPatternsPresent(String lowerText, List<String> patterns) {
    return patterns.any((pattern) => lowerText.contains(pattern));
  }

  void _addPattern(List<CrisisPattern> patterns, String category, 
      CrisisSeverity severity, String matchedText) {
    patterns.add(CrisisPattern(
      category: category,
      severity: severity,
      matchedText: matchedText,
    ));
  }

  /// Check if text contains any crisis indicators (quick check)
  bool containsCrisisIndicators(String text) {
    final lowerText = text.toLowerCase();
    return directSuicidalStatements.any((p) => lowerText.contains(p)) ||
           passiveSuicidalIdeation.any((p) => lowerText.contains(p)) ||
           selfHarmIndicators.any((p) => lowerText.contains(p)) ||
           farewellLanguage.any((p) => lowerText.contains(p)) ||
           harmToOthersIndicators.any((p) => lowerText.contains(p));
  }

  /// Get appropriate crisis resources based on severity
  CrisisResources getResources(CrisisSeverity severity) {
    switch (severity) {
      case CrisisSeverity.critical:
      case CrisisSeverity.high:
        return CrisisResources.immediate;
      case CrisisSeverity.medium:
        return CrisisResources.supportive;
      case CrisisSeverity.low:
        return CrisisResources.general;
      case CrisisSeverity.none:
        return CrisisResources.none;
    }
  }
}

/// Crisis pattern match details
class CrisisPattern {
  final String category;
  final CrisisSeverity severity;
  final String matchedText;

  const CrisisPattern({
    required this.category,
    required this.severity,
    required this.matchedText,
  });
}

/// Complete crisis assessment result
class CrisisAssessment {
  final CrisisSeverity severity;
  final List<CrisisPattern> detectedPatterns;
  final bool requiresImmediateResources;
  final DateTime timestamp;

  const CrisisAssessment({
    required this.severity,
    required this.detectedPatterns,
    required this.requiresImmediateResources,
    required this.timestamp,
  });

  bool get hasCrisisIndicators => detectedPatterns.isNotEmpty;
  
  List<String> get categories => 
      detectedPatterns.map((p) => p.category).toSet().toList();
}

/// Crisis resource levels
enum CrisisResources {
  none,
  general,    // Self-help resources
  supportive, // Warm line, support groups
  immediate,  // 988, Crisis Text Line
}

/// Crisis resources provider
class CrisisResourcesProvider {
  CrisisResourcesProvider._();

  // ============== US RESOURCES (Default) ==============
  static const String usLifeline = '988';
  static const String usTextLine = 'HOME to 741741';
  static const String usVeterans = '988 then press 1';
  static const String usLGBTQ = '1-866-488-7386'; // Trevor Project
  static const String usTransLifeline = '877-565-8860';
  static const String usDomesticViolence = '1-800-799-7233';
  static const String usChildAbuse = '1-800-422-4453';
  static const String usSAMHSA = '1-800-662-4357';
  
  // ============== INTERNATIONAL RESOURCES ==============
  static const String internationalUrl = 'https://findahelpline.com/';
  static const String iaspUrl = 'https://www.iasp.info/resources/Crisis_Centres/';
  
  // ============== COUNTRY-SPECIFIC HOTLINES ==============
  static const Map<String, Map<String, String>> countryResources = {
    'US': {
      'main': '988',
      'text': 'HOME to 741741',
      'name': 'Suicide & Crisis Lifeline',
    },
    'UK': {
      'main': '116 123',
      'text': 'SHOUT to 85258',
      'name': 'Samaritans',
    },
    'CA': {
      'main': '1-833-456-4566',
      'text': '45645',
      'name': 'Crisis Services Canada',
    },
    'AU': {
      'main': '13 11 14',
      'text': '0477 13 11 14',
      'name': 'Lifeline Australia',
    },
    'IN': {
      'main': '9820466726',
      'name': 'iCall',
    },
    'NZ': {
      'main': '1737',
      'name': 'Need to Talk?',
    },
    'IE': {
      'main': '116 123',
      'name': 'Samaritans Ireland',
    },
    'DE': {
      'main': '0800 111 0 111',
      'name': 'Telefonseelsorge',
    },
    'FR': {
      'main': '01 45 39 40 00',
      'name': 'Suicide Écoute',
    },
    'JP': {
      'main': '0570-064-556',
      'name': 'TELL Lifeline',
    },
    'PH': {
      'main': '028969191',
      'name': 'Natasha Goulbourn Foundation',
    },
    'SG': {
      'main': '1800-221-4444',
      'name': 'Samaritans of Singapore',
    },
  };

  /// Get crisis message for severity level
  static String getCrisisMessage(CrisisSeverity severity, {String? countryCode}) {
    final resources = countryCode != null ? 
        countryResources[countryCode] ?? countryResources['US']! :
        countryResources['US']!;

    switch (severity) {
      case CrisisSeverity.critical:
      case CrisisSeverity.high:
        return '''
I hear that you're going through something really difficult right now. Your feelings are valid, and you deserve support.

🆘 **Please reach out now:**
• **Call/Text ${resources['main']}** (${resources['name']})
${resources['text'] != null ? '• **Text ${resources['text']}**' : ''}
• **Go to your nearest emergency room**

These services are free, confidential, and available 24/7. You don't have to face this alone.

🌍 International resources: findahelpline.com

I'm here to listen, but please also connect with a trained crisis counselor who can provide immediate support.
''';
      case CrisisSeverity.medium:
        return '''
I can hear that you're struggling, and I want you to know that what you're feeling matters.

💙 **Support is available:**
• **${resources['name']}: ${resources['main']}** - Available 24/7
• **findahelpline.com** - Find local support worldwide

Would you like to talk about what's happening? I'm here to listen.
''';
      case CrisisSeverity.low:
      case CrisisSeverity.none:
        return '';
    }
  }

  /// Get formatted resources card data
  static List<CrisisResourceCard> getResourceCards({String? countryCode}) {
    final country = countryCode ?? 'US';
    final resources = countryResources[country] ?? countryResources['US']!;
    
    return [
      CrisisResourceCard(
        title: resources['name']!,
        phone: resources['main']!,
        description: '24/7 Crisis Support',
        isEmergency: true,
      ),
      if (resources['text'] != null)
        CrisisResourceCard(
          title: 'Crisis Text Line',
          phone: resources['text']!,
          description: 'Text-based support',
          isText: true,
        ),
      CrisisResourceCard(
        title: 'Find Help Worldwide',
        url: internationalUrl,
        description: 'International crisis lines',
        isWeb: true,
      ),
    ];
  }
}

/// Resource card data
class CrisisResourceCard {
  final String title;
  final String? phone;
  final String? url;
  final String description;
  final bool isEmergency;
  final bool isText;
  final bool isWeb;

  const CrisisResourceCard({
    required this.title,
    this.phone,
    this.url,
    required this.description,
    this.isEmergency = false,
    this.isText = false,
    this.isWeb = false,
  });
}
