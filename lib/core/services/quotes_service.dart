import 'dart:math';

/// Service providing rotating motivational quotes
class QuotesService {
  static final QuotesService _instance = QuotesService._internal();
  factory QuotesService() => _instance;
  QuotesService._internal();

  final Random _random = Random();
  String? _todaysQuote;
  DateTime? _quoteDate;

  /// Get the quote for today (same quote throughout the day)
  String getTodaysQuote() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Return cached quote if still today
    if (_quoteDate == today && _todaysQuote != null) {
      return _todaysQuote!;
    }

    // Select a new quote for today
    final index = _getDailyIndex(today);
    _todaysQuote = _quotes[index % _quotes.length];
    _quoteDate = today;

    return _todaysQuote!;
  }

  /// Get a random quote
  String getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  /// Get quote by category
  String getQuoteByCategory(QuoteCategory category) {
    final categoryQuotes = _categorizedQuotes[category] ?? _quotes;
    return categoryQuotes[_random.nextInt(categoryQuotes.length)];
  }

  /// Get a deterministic index based on the date
  int _getDailyIndex(DateTime date) {
    return date.year * 1000 + date.month * 31 + date.day;
  }

  /// Main collection of motivational quotes
  static const List<String> _quotes = [
    // Self-care & wellness
    "Taking care of yourself is not selfish, it's essential.",
    "Your mental health is a priority. Your happiness is essential.",
    "You don't have to be positive all the time. It's okay to feel sad, angry, or frustrated.",
    "Be gentle with yourself; you're doing the best you can.",
    "Rest is not a reward for hard work. It's a necessity.",
    
    // Growth & resilience
    "Every day is a new beginning. Take a deep breath and start again.",
    "Progress, not perfection, is what we should be asking of ourselves.",
    "You are stronger than you think, braver than you believe.",
    "The only way out is through.",
    "Healing is not linear. Be patient with yourself.",
    
    // Mindfulness & presence
    "This moment is all we have. Make it meaningful.",
    "Breathe. You are exactly where you need to be.",
    "In the middle of difficulty lies opportunity.",
    "The present moment is filled with joy and happiness. If you are attentive, you will see it.",
    "Peace comes from within. Do not seek it without.",
    
    // Courage & action
    "Courage doesn't always roar. Sometimes it's the quiet voice at the end of the day saying, 'I will try again tomorrow.'",
    "Start where you are. Use what you have. Do what you can.",
    "The journey of a thousand miles begins with a single step.",
    "You don't have to see the whole staircase, just take the first step.",
    "What lies behind us and what lies before us are tiny matters compared to what lies within us.",
    
    // Self-worth & acceptance
    "You are worthy of love and belonging, just as you are.",
    "Your value doesn't decrease based on someone's inability to see your worth.",
    "You are enough, exactly as you are in this moment.",
    "Talk to yourself like you would talk to someone you love.",
    "You are not a drop in the ocean. You are the entire ocean in a drop.",
    
    // Hope & optimism
    "Even the darkest night will end and the sun will rise.",
    "Hope is being able to see that there is light despite all of the darkness.",
    "Every storm runs out of rain.",
    "After the rain comes the rainbow.",
    "There is always something to be grateful for.",
    
    // Strength in vulnerability
    "Vulnerability is not weakness; it's our most accurate measure of courage.",
    "It's okay to ask for help. Strength includes knowing when you need support.",
    "Your feelings are valid. Your struggles are real. Your growth is happening.",
    "You don't have to carry everything alone.",
    "Sharing your story might be the thing someone else needs to hear.",
    
    // Daily motivation
    "Today is a good day to have a good day.",
    "You've survived 100% of your worst days. You're doing great.",
    "Small steps every day lead to big changes over time.",
    "Believe you can and you're halfway there.",
    "Your potential is endless. Go do what you were created to do.",
    
    // Emotional wellness
    "It's okay to not be okay. What matters is that you keep going.",
    "Your emotions are messengers, not your identity.",
    "Feeling everything is better than feeling nothing.",
    "Allow yourself to feel, then allow yourself to heal.",
    "Sometimes the bravest thing you can do is just get through the day.",
    
    // Inner peace
    "Don't let yesterday take up too much of today.",
    "Worrying doesn't take away tomorrow's troubles, it takes away today's peace.",
    "You can't control everything. Sometimes you just need to relax and have faith.",
    "Let go of what you can't change. Focus on what you can.",
    "Inner peace begins the moment you choose not to allow another person or event to control your emotions.",
  ];

  /// Quotes organized by category
  static const Map<QuoteCategory, List<String>> _categorizedQuotes = {
    QuoteCategory.morning: [
      "Today is a good day to have a good day.",
      "Every day is a new beginning. Take a deep breath and start again.",
      "Your potential is endless. Go do what you were created to do.",
      "This morning, let gratitude be your guide.",
      "Wake up with determination. Go to bed with satisfaction.",
    ],
    QuoteCategory.evening: [
      "Rest is not a reward for hard work. It's a necessity.",
      "You did enough today. Now rest.",
      "Tonight, let go of what didn't go right today.",
      "Sleep peacefully knowing you did your best.",
      "Tomorrow is another chance to grow.",
    ],
    QuoteCategory.stressed: [
      "Breathe. You are exactly where you need to be.",
      "This too shall pass.",
      "You don't have to have it all figured out.",
      "Take it one moment at a time.",
      "You are stronger than this moment.",
    ],
    QuoteCategory.sad: [
      "It's okay to not be okay.",
      "Your feelings are valid.",
      "Even the darkest night will end and the sun will rise.",
      "You are not alone in this.",
      "Healing is happening, even when you can't see it.",
    ],
    QuoteCategory.motivated: [
      "You've got this!",
      "Today is your day to shine.",
      "Your energy creates your reality.",
      "Keep going. You're closer than you think.",
      "Success is the sum of small efforts repeated daily.",
    ],
  };
}

/// Categories for quotes
enum QuoteCategory {
  morning,
  evening,
  stressed,
  sad,
  motivated,
}

/// Extension to get time-appropriate quotes
extension QuotesServiceExtension on QuotesService {
  /// Get a quote appropriate for the current time of day
  String getTimeAppropriateQuote() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return getQuoteByCategory(QuoteCategory.morning);
    } else if (hour >= 20 || hour < 5) {
      return getQuoteByCategory(QuoteCategory.evening);
    } else {
      return getTodaysQuote();
    }
  }
}
