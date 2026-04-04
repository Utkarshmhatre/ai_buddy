import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/services/report_generation_service.dart';
import '../../../core/services/predictive_mood_service.dart';
import '../../../data/repositories/mood_repository.dart';
import '../../../data/repositories/journal_repository.dart';

/// Reports screen for viewing AI-generated insights and reports
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  WeeklyReport? _weeklyReport;
  MonthlyReport? _monthlyReport;
  MoodPrediction? _moodPrediction;
  WeeklyForecast? _weeklyForecast;
  
  bool _isLoadingWeekly = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingPrediction = false;

  ReportGenerationService? _reportService;
  PredictiveMoodService? _predictiveService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeServices();
  }

  void _initializeServices() {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isNotEmpty) {
      _reportService = ReportGenerationService(apiKey: apiKey);
      _predictiveService = PredictiveMoodService(apiKey: apiKey);
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadWeeklyReport(),
      _loadPredictions(),
    ]);
  }

  Future<void> _loadWeeklyReport() async {
    if (_reportService == null) return;
    
    setState(() => _isLoadingWeekly = true);
    
    try {
      final moodRepo = context.read<MoodRepository>();
      final journalRepo = context.read<JournalRepository>();
      
      final moods = await moodRepo.getMoodEntries(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );
      
      final journals = await journalRepo.getJournalEntries(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );
      
      final report = await _reportService!.generateWeeklyReport(
        moodEntries: moods,
        journalEntries: journals,
      );
      
      setState(() {
        _weeklyReport = report;
        _isLoadingWeekly = false;
      });
    } catch (e) {
      setState(() => _isLoadingWeekly = false);
    }
  }

  Future<void> _loadMonthlyReport() async {
    if (_reportService == null || _monthlyReport != null) return;
    
    setState(() => _isLoadingMonthly = true);
    
    try {
      final moodRepo = context.read<MoodRepository>();
      final journalRepo = context.read<JournalRepository>();
      
      final moods = await moodRepo.getMoodEntries(
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime.now(),
      );
      
      final journals = await journalRepo.getJournalEntries(
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime.now(),
      );
      
      final report = await _reportService!.generateMonthlyReport(
        moodEntries: moods,
        journalEntries: journals,
      );
      
      setState(() {
        _monthlyReport = report;
        _isLoadingMonthly = false;
      });
    } catch (e) {
      setState(() => _isLoadingMonthly = false);
    }
  }

  Future<void> _loadPredictions() async {
    if (_predictiveService == null) return;
    
    setState(() => _isLoadingPrediction = true);
    
    try {
      final moodRepo = context.read<MoodRepository>();
      final moods = await moodRepo.getMoodEntries(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      final prediction = await _predictiveService!.predictMood(moodHistory: moods);
      final forecast = await _predictiveService!.generateWeeklyForecast(moodHistory: moods);
      
      setState(() {
        _moodPrediction = prediction;
        _weeklyForecast = forecast;
        _isLoadingPrediction = false;
      });
    } catch (e) {
      setState(() => _isLoadingPrediction = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Insights'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1 && _monthlyReport == null) {
              _loadMonthlyReport();
            }
          },
          tabs: const [
            Tab(text: 'Weekly', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Monthly', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Predictions', icon: Icon(Icons.auto_awesome)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyTab(theme),
          _buildMonthlyTab(theme),
          _buildPredictionsTab(theme),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(ThemeData theme) {
    if (_isLoadingWeekly) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating your weekly report...'),
          ],
        ),
      );
    }

    if (_weeklyReport == null) {
      return _buildEmptyState(
        theme,
        Icons.calendar_view_week,
        'No Report Available',
        'Start tracking your mood to generate weekly reports.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWeeklyReport,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyHeader(theme),
            const SizedBox(height: 24),
            _buildWeeklySummaryCard(theme),
            const SizedBox(height: 16),
            if (_weeklyReport!.highlights.isNotEmpty)
              _buildHighlightsCard(theme),
            const SizedBox(height: 16),
            _buildMoodTrendCard(theme),
            const SizedBox(height: 16),
            if (_weeklyReport!.suggestions.isNotEmpty)
              _buildSuggestionsCard(theme),
            const SizedBox(height: 16),
            _buildAffirmationCard(theme),
            const SizedBox(height: 24),
            _buildShareButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHeader(ThemeData theme) {
    final dateFormat = DateFormat('MMM d');
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              'Weekly Report',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${dateFormat.format(_weeklyReport!.weekStart)} - ${dateFormat.format(_weeklyReport!.weekEnd)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _weeklyReport!.greeting,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _weeklyReport!.summary,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  'Highlights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._weeklyReport!.highlights.map((h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨ '),
                  Expanded(child: Text(h)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrendCard(ThemeData theme) {
    final trend = _weeklyReport!.moodTrend;
    IconData trendIcon;
    Color trendColor;
    
    switch (trend.toLowerCase()) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = Colors.orange;
        break;
      case 'variable':
        trendIcon = Icons.swap_vert;
        trendColor = Colors.blue;
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = theme.colorScheme.primary;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(trendIcon, color: trendColor),
                const SizedBox(width: 8),
                Text(
                  'Mood Trend: ${trend.toUpperCase()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _weeklyReport!.moodTrendExplanation,
              style: theme.textTheme.bodyMedium,
            ),
            if (_weeklyReport!.stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    'Average',
                    '${(_weeklyReport!.stats['average'] as double?)?.toStringAsFixed(1) ?? '-'}/10',
                    theme,
                  ),
                  _buildStatColumn(
                    'High',
                    '${_weeklyReport!.stats['highest'] ?? '-'}/10',
                    theme,
                  ),
                  _buildStatColumn(
                    'Low',
                    '${_weeklyReport!.stats['lowest'] ?? '-'}/10',
                    theme,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Suggestions for Next Week',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._weeklyReport!.suggestions.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 '),
                  Expanded(child: Text(s)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAffirmationCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.favorite_outline,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              _weeklyReport!.affirmation,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            if (_weeklyReport!.weeklyQuote.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '"${_weeklyReport!.weeklyQuote}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final shareText = _weeklyReport!.toShareableText();
          _reportService?.shareReport(
            reportText: shareText,
            reportTitle: 'Weekly Wellness Report',
          );
        },
        icon: const Icon(Icons.share_outlined),
        label: const Text('Share Report'),
      ),
    );
  }

  Widget _buildMonthlyTab(ThemeData theme) {
    if (_isLoadingMonthly) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating your monthly report...'),
          ],
        ),
      );
    }

    if (_monthlyReport == null) {
      return _buildEmptyState(
        theme,
        Icons.calendar_month,
        'Monthly Report',
        'Your monthly reflection will appear here.\nTap on the tab to generate it.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _monthlyReport = null;
        await _loadMonthlyReport();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthlyHeader(theme),
            const SizedBox(height: 24),
            _buildMonthSummaryCard(theme),
            const SizedBox(height: 16),
            if (_monthlyReport!.monthlyWins.isNotEmpty)
              _buildMonthlyWinsCard(theme),
            const SizedBox(height: 16),
            _buildConsistencyCard(theme),
            const SizedBox(height: 16),
            if (_monthlyReport!.personalizedInsight.isNotEmpty)
              _buildInsightCard(theme),
            const SizedBox(height: 16),
            _buildLookingAheadCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHeader(ThemeData theme) {
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month,
              size: 48,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              '${_monthlyReport!.monthName} Reflection',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSummaryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Month in Review',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _monthlyReport!.monthSummary,
              style: theme.textTheme.bodyMedium,
            ),
            if (_monthlyReport!.monthInReview.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _monthlyReport!.monthInReview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyWinsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Monthly Wins',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._monthlyReport!.monthlyWins.map((w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏆 '),
                  Expanded(child: Text(w)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consistency Score',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _monthlyReport!.consistencyScore / 10,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_monthlyReport!.consistencyScore}/10',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _monthlyReport!.consistencyFeedback,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Personalized Insight',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _monthlyReport!.personalizedInsight,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookingAheadCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.arrow_forward_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Looking Ahead',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _monthlyReport!.lookingAhead,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsTab(ThemeData theme) {
    if (_isLoadingPrediction) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing mood patterns...'),
          ],
        ),
      );
    }

    if (_moodPrediction == null && _weeklyForecast == null) {
      return _buildEmptyState(
        theme,
        Icons.auto_awesome,
        'Mood Predictions',
        'Track your mood for at least a week to unlock AI-powered predictions.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPredictions,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_moodPrediction != null) ...[
              _buildPredictionCard(theme),
              const SizedBox(height: 16),
              if (_moodPrediction!.suggestions.isNotEmpty)
                _buildProactiveSuggestionsCard(theme),
              const SizedBox(height: 16),
            ],
            if (_weeklyForecast != null)
              _buildForecastCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(ThemeData theme) {
    final prediction = _moodPrediction!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Prediction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getPredictionColor(prediction.predictedScore),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${prediction.predictedScore}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predicted: ${prediction.predictedCategory?.name ?? 'Unknown'}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        'Confidence: ${(prediction.confidence * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              prediction.reasoning,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPredictionColor(int mood) {
    if (mood >= 8) return Colors.green;
    if (mood >= 6) return Colors.lightGreen;
    if (mood >= 4) return Colors.amber;
    if (mood >= 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildProactiveSuggestionsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Proactive Suggestions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._moodPrediction!.suggestions.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: s.priority == 'high'
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.priority.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: s.priority == 'high' ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.suggestion,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          s.timing,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(ThemeData theme) {
    final forecast = _weeklyForecast!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '7-Day Forecast',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: forecast.dailyPredictions.take(7).map((day) {
                  return _buildDayForecast(theme, day);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              forecast.outlookDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            if (forecast.keyRecommendation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '💡 ${forecast.keyRecommendation}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayForecast(ThemeData theme, DailyPrediction day) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.dayOfWeek.length >= 3 ? day.dayOfWeek.substring(0, 3) : day.dayOfWeek,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getPredictionColor(day.predictedScore),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${day.predictedScore}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getMoodEmoji(day.predictedScore),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _getMoodEmoji(int mood) {
    if (mood >= 8) return '😊';
    if (mood >= 6) return '🙂';
    if (mood >= 4) return '😐';
    if (mood >= 2) return '😔';
    return '😢';
  }

  Widget _buildEmptyState(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
