import '../crisis_detection_service.dart';
import '../../../data/models/models.dart';

/// Crisis detection test suite
/// Run these tests to validate crisis detection accuracy
class CrisisDetectionTests {
  final CrisisDetectionService _service = CrisisDetectionService.instance;

  /// Run all tests and return results
  CrisisTestResults runAllTests() {
    final results = CrisisTestResults();
    
    // Critical level tests
    results.addResults('Critical - Direct Statements', _testCriticalDirect());
    results.addResults('Critical - Farewell Language', _testCriticalFarewell());
    results.addResults('Critical - Harm to Others', _testCriticalHarmOthers());
    results.addResults('Critical - Method + Intent', _testCriticalMethodIntent());
    
    // High level tests
    results.addResults('High - Passive Ideation', _testHighPassive());
    results.addResults('High - Self-Harm', _testHighSelfHarm());
    
    // Medium level tests
    results.addResults('Medium - Hopelessness', _testMediumHopelessness());
    results.addResults('Medium - Trauma', _testMediumTrauma());
    
    // Low level tests
    results.addResults('Low - Distress', _testLowDistress());
    
    // None level tests (should NOT trigger)
    results.addResults('None - Safe Messages', _testNoneSafe());
    
    // Edge case tests
    results.addResults('Edge Cases', _testEdgeCases());
    
    // False positive tests
    results.addResults('False Positive Prevention', _testFalsePositives());
    
    return results;
  }

  List<CrisisTestCase> _testCriticalDirect() {
    return [
      _test('I\'m going to kill myself tonight', CrisisSeverity.critical),
      _test('I want to end my life', CrisisSeverity.critical),
      _test('I\'ve decided to commit suicide', CrisisSeverity.critical),
      _test('Planning to take my own life', CrisisSeverity.critical),
      _test('Gonna kill myself when I get home', CrisisSeverity.critical),
      _test('I will hang myself', CrisisSeverity.critical),
      _test('Going to jump off the bridge', CrisisSeverity.critical),
    ];
  }

  List<CrisisTestCase> _testCriticalFarewell() {
    return [
      _test('Goodbye forever everyone', CrisisSeverity.critical),
      _test('This is my final goodbye', CrisisSeverity.critical),
      _test('I\'m writing my note to everyone', CrisisSeverity.critical),
      _test('Giving away all my things, won\'t need them', CrisisSeverity.critical),
      _test('You won\'t see me again after today', CrisisSeverity.critical),
      _test('Saying my goodbyes to everyone I love', CrisisSeverity.critical),
    ];
  }

  List<CrisisTestCase> _testCriticalHarmOthers() {
    return [
      _test('I want to hurt someone badly', CrisisSeverity.critical),
      _test('Having thoughts of killing them', CrisisSeverity.critical),
      _test('I\'m having violent thoughts about my coworker', CrisisSeverity.critical),
    ];
  }

  List<CrisisTestCase> _testCriticalMethodIntent() {
    return [
      _test('I have pills saved up and I\'m ready to use them', CrisisSeverity.critical),
      _test('I bought a rope, I know what I\'m going to do', CrisisSeverity.critical),
      _test('I\'ve been thinking about the bridge, I can\'t go on', CrisisSeverity.critical),
    ];
  }

  List<CrisisTestCase> _testHighPassive() {
    return [
      _test('I wish I wasn\'t alive anymore', CrisisSeverity.high),
      _test('Everyone would be better off without me', CrisisSeverity.high),
      _test('I hope I don\'t wake up tomorrow', CrisisSeverity.high),
      _test('I\'m so tired of living like this', CrisisSeverity.high),
      _test('There\'s no point in living anymore', CrisisSeverity.high),
      _test('I can\'t do this anymore, what\'s the point', CrisisSeverity.high),
      _test('No one would miss me if I was gone', CrisisSeverity.high),
      _test('I\'m just a burden to everyone around me', CrisisSeverity.high),
    ];
  }

  List<CrisisTestCase> _testHighSelfHarm() {
    return [
      _test('I\'ve been cutting myself again', CrisisSeverity.high),
      _test('I hurt myself last night', CrisisSeverity.high),
      _test('I want to harm myself', CrisisSeverity.high),
      _test('Thinking about overdosing on my meds', CrisisSeverity.high),
      _test('I\'ve been burning myself to cope', CrisisSeverity.high),
    ];
  }

  List<CrisisTestCase> _testMediumHopelessness() {
    return [
      _test('I feel completely hopeless about everything', CrisisSeverity.medium),
      _test('Nothing will ever change, I\'m stuck', CrisisSeverity.medium),
      _test('I hate myself so much', CrisisSeverity.medium),
      _test('I\'m completely worthless', CrisisSeverity.medium),
      _test('I don\'t deserve to be happy', CrisisSeverity.medium),
      _test('No one understands me, I\'m all alone', CrisisSeverity.medium),
    ];
  }

  List<CrisisTestCase> _testMediumTrauma() {
    return [
      _test('My mom just died yesterday', CrisisSeverity.medium),
      _test('I just found out I was cheated on', CrisisSeverity.medium),
      _test('I lost my job and I\'m going to be homeless', CrisisSeverity.medium),
      _test('I was assaulted last week', CrisisSeverity.medium),
    ];
  }

  List<CrisisTestCase> _testLowDistress() {
    return [
      _test('I\'m having a panic attack right now', CrisisSeverity.low),
      _test('I feel like I\'m falling apart', CrisisSeverity.low),
      _test('I can\'t stop crying, I\'m a mess', CrisisSeverity.low),
      _test('I feel so numb inside', CrisisSeverity.low),
    ];
  }

  List<CrisisTestCase> _testNoneSafe() {
    return [
      _test('I had a great day at work today!', CrisisSeverity.none),
      _test('Feeling a bit stressed about my exam', CrisisSeverity.none),
      _test('I\'m worried about my presentation', CrisisSeverity.none),
      _test('Had an argument with my friend, feeling sad', CrisisSeverity.none),
      _test('The weather is nice today', CrisisSeverity.none),
      _test('I\'m feeling grateful for my family', CrisisSeverity.none),
      _test('Just finished a good workout', CrisisSeverity.none),
    ];
  }

  List<CrisisTestCase> _testEdgeCases() {
    return [
      // Multiple indicators should escalate
      _test('I feel hopeless and like a burden, I can\'t go on', 
            CrisisSeverity.high, 'Multiple indicators'),
      // Indirect but concerning
      _test('I\'ve made peace with everything, saying my last goodbyes', 
            CrisisSeverity.critical, 'Indirect farewell'),
      // Trauma + hopelessness = high
      _test('I just lost my job and I feel like there\'s no way out', 
            CrisisSeverity.high, 'Trauma + hopelessness'),
      // Very long message with buried crisis content
      _test('Today was okay I guess. Work was fine. But honestly I\'ve been thinking about it a lot and I just wish I wasn\'t alive anymore. Anyway, how are you?',
            CrisisSeverity.high, 'Buried crisis content'),
    ];
  }

  List<CrisisTestCase> _testFalsePositives() {
    return [
      // Should NOT trigger crisis
      _test('I\'m killing it at work lately!', CrisisSeverity.none, 'Idiom - killing it'),
      _test('This movie is to die for', CrisisSeverity.none, 'Idiom - to die for'),
      _test('I\'m dead tired after that workout', CrisisSeverity.none, 'Idiom - dead tired'),
      _test('That joke killed me haha', CrisisSeverity.none, 'Idiom - killed me'),
      _test('I\'m cutting back on sugar', CrisisSeverity.none, 'Cutting - dietary'),
      _test('My friend is going through a breakup', CrisisSeverity.none, 'Third person'),
      _test('I read about suicide prevention today', CrisisSeverity.low, 'Educational context'),
      _test('The bridge in my city is beautiful', CrisisSeverity.none, 'Bridge - neutral'),
      _test('I need to take my pills for my headache', CrisisSeverity.none, 'Pills - medical'),
    ];
  }

  CrisisTestCase _test(String input, CrisisSeverity expected, [String? note]) {
    final assessment = _service.assessText(input);
    final passed = assessment.severity == expected || 
                   (expected != CrisisSeverity.none && 
                    assessment.severity.index >= expected.index);
    
    return CrisisTestCase(
      input: input,
      expectedSeverity: expected,
      actualSeverity: assessment.severity,
      passed: passed,
      detectedPatterns: assessment.detectedPatterns.map((p) => p.matchedText).toList(),
      note: note,
    );
  }
}

/// Individual test case result
class CrisisTestCase {
  final String input;
  final CrisisSeverity expectedSeverity;
  final CrisisSeverity actualSeverity;
  final bool passed;
  final List<String> detectedPatterns;
  final String? note;

  CrisisTestCase({
    required this.input,
    required this.expectedSeverity,
    required this.actualSeverity,
    required this.passed,
    required this.detectedPatterns,
    this.note,
  });
}

/// Aggregated test results
class CrisisTestResults {
  final Map<String, List<CrisisTestCase>> _categories = {};
  
  void addResults(String category, List<CrisisTestCase> tests) {
    _categories[category] = tests;
  }
  
  int get totalTests => _categories.values.fold(0, (sum, list) => sum + list.length);
  
  int get passedTests => _categories.values
      .fold(0, (sum, list) => sum + list.where((t) => t.passed).length);
  
  int get failedTests => totalTests - passedTests;
  
  double get passRate => totalTests > 0 ? passedTests / totalTests * 100 : 0;
  
  List<CrisisTestCase> get failedCases => _categories.values
      .expand((list) => list)
      .where((t) => !t.passed)
      .toList();
  
  Map<String, List<CrisisTestCase>> get byCategory => _categories;
  
  String getSummary() {
    final buffer = StringBuffer();
    buffer.writeln('╔════════════════════════════════════════════════════╗');
    buffer.writeln('║         CRISIS DETECTION TEST RESULTS              ║');
    buffer.writeln('╠════════════════════════════════════════════════════╣');
    buffer.writeln('║ Total Tests: $totalTests');
    buffer.writeln('║ Passed: $passedTests');
    buffer.writeln('║ Failed: $failedTests');
    buffer.writeln('║ Pass Rate: ${passRate.toStringAsFixed(1)}%');
    buffer.writeln('╠════════════════════════════════════════════════════╣');
    
    for (final entry in _categories.entries) {
      final categoryPassed = entry.value.where((t) => t.passed).length;
      final categoryTotal = entry.value.length;
      final status = categoryPassed == categoryTotal ? '✓' : '✗';
      buffer.writeln('║ $status ${entry.key}: $categoryPassed/$categoryTotal');
    }
    
    if (failedCases.isNotEmpty) {
      buffer.writeln('╠════════════════════════════════════════════════════╣');
      buffer.writeln('║ FAILED CASES:');
      for (final failed in failedCases) {
        buffer.writeln('║ • "${failed.input.substring(0, failed.input.length.clamp(0, 40))}..."');
        buffer.writeln('║   Expected: ${failed.expectedSeverity}, Got: ${failed.actualSeverity}');
      }
    }
    
    buffer.writeln('╚════════════════════════════════════════════════════╝');
    return buffer.toString();
  }
}
