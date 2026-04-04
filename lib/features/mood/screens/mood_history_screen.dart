import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mood_entry.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';
import '../bloc/mood_state.dart';

/// Period filter for mood history
enum MoodHistoryPeriod {
  week('Week', 7),
  month('Month', 30),
  threeMonths('3 Months', 90);

  final String label;
  final int days;
  const MoodHistoryPeriod(this.label, this.days);
}

/// Screen showing mood history and charts with real data from BLoC
class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  MoodHistoryPeriod _selectedPeriod = MoodHistoryPeriod.week;

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  void _loadMoodHistory() {
    context.read<MoodBloc>().add(LoadMoodHistory(daysBack: _selectedPeriod.days));
  }

  void _onPeriodChanged(MoodHistoryPeriod period) {
    setState(() => _selectedPeriod = period);
    context.read<MoodBloc>().add(LoadMoodHistory(daysBack: period.days));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.moodCheckIn),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          if (state is MoodLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoodError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMoodHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MoodHistoryLoaded) {
            return _buildContent(context, state);
          }

          // Initial state or other states - load history
          if (state is MoodInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadMoodHistory();
            });
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MoodHistoryLoaded state) {
    final theme = Theme.of(context);
    final entries = state.entries;

    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return CustomScrollView(
      slivers: [
        // Period selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ),
          ),
        ),

        // Weekly/Monthly mood chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _MoodChart(
              entries: entries,
              period: _selectedPeriod,
            ),
          ),
        ),

        // Stats summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _StatsRow(
              entries: entries,
              trend: state.trend,
              averageIntensity: state.averageIntensity,
            ),
          ),
        ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Recent Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Mood entries list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MoodEntryCard(entry: entry),
                );
              },
              childCount: entries.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100), // Bottom padding
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mood_rounded,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No mood entries yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your moods to see patterns and insights',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.moodCheckIn),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log Your First Mood'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final MoodHistoryPeriod selectedPeriod;
  final ValueChanged<MoodHistoryPeriod> onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: MoodHistoryPeriod.values.map((period) {
        final isSelected = period == selectedPeriod;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: period != MoodHistoryPeriod.values.last ? 8 : 0,
            ),
            child: Material(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onPeriodChanged(period),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    period.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final MoodHistoryPeriod period;

  const _MoodChart({required this.entries, required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = _generateChartData();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getPeriodTitle(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (entries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entries.length} entries',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No data for this period',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) =>
                                _getBottomTitle(value, meta, theme),
                            reservedSize: 24,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                      minY: 1,
                      maxY: 5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getPeriodTitle() {
    switch (period) {
      case MoodHistoryPeriod.week:
        return 'This Week';
      case MoodHistoryPeriod.month:
        return 'This Month';
      case MoodHistoryPeriod.threeMonths:
        return 'Last 3 Months';
    }
  }

  List<FlSpot> _generateChartData() {
    if (entries.isEmpty) return [];

    // Group entries by day and calculate average mood per day
    final now = DateTime.now();
    final Map<int, List<double>> dayScores = {};

    for (final entry in entries) {
      final daysAgo = now.difference(entry.timestamp).inDays;
      if (daysAgo < period.days) {
        dayScores.putIfAbsent(daysAgo, () => []);
        dayScores[daysAgo]!.add(entry.intensity.value.toDouble());
      }
    }

    // Calculate averages and create spots
    final spots = <FlSpot>[];
    final sortedDays = dayScores.keys.toList()..sort((a, b) => b.compareTo(a));

    for (int i = 0; i < sortedDays.length && i < 7; i++) {
      final day = sortedDays[i];
      final scores = dayScores[day]!;
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      spots.add(FlSpot(i.toDouble(), avg));
    }

    return spots.reversed.toList();
  }

  Widget _getBottomTitle(double value, TitleMeta meta, ThemeData theme) {
    final now = DateTime.now();
    final dayIndex = value.toInt();
    
    String label;
    if (period == MoodHistoryPeriod.week) {
      final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      final dayOfWeek = (now.weekday - 1 - (6 - dayIndex)) % 7;
      label = days[dayOfWeek < 0 ? dayOfWeek + 7 : dayOfWeek];
    } else {
      final targetDate = now.subtract(Duration(days: 6 - dayIndex));
      label = '${targetDate.day}';
    }

    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<MoodEntry> entries;
  final MoodTrend? trend;
  final double? averageIntensity;

  const _StatsRow({
    required this.entries,
    this.trend,
    this.averageIntensity,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate most frequent mood
    final moodCounts = <MoodCategory, int>{};
    for (final entry in entries) {
      moodCounts[entry.category] = (moodCounts[entry.category] ?? 0) + 1;
    }
    
    MoodCategory? mostFrequent;
    int maxCount = 0;
    moodCounts.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = category;
      }
    });

    // Calculate streak (consecutive days with entries)
    final streak = _calculateStreak();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_emotions_rounded,
            label: 'Most Frequent',
            value: mostFrequent != null
                ? '${mostFrequent!.label} ${mostFrequent!.emoji}'
                : '—',
            color: AppColors.encouragementTint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            label: 'Avg Mood',
            value: averageIntensity != null
                ? '${averageIntensity!.toStringAsFixed(1)} / 5'
                : '—',
            color: AppColors.calmTint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '$streak ${streak == 1 ? 'day' : 'days'}',
            color: AppColors.celebrationTint,
          ),
        ),
      ],
    );
  }

  int _calculateStreak() {
    if (entries.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get unique days with entries
    final daysWithEntries = <DateTime>{};
    for (final entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      daysWithEntries.add(date);
    }

    // Count consecutive days starting from today
    int streak = 0;
    var checkDate = today;
    
    // Allow for entries from today or yesterday to start the streak
    if (!daysWithEntries.contains(today)) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (daysWithEntries.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;

  const _MoodEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodColor = Color(entry.category.colors.first);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // Mood emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: moodColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(entry.category.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.category.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: moodColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.intensity.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: moodColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (entry.notes != null) ...[
                  Text(
                    entry.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    _formatTime(entry.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Time
          if (entry.notes != null)
            Text(
              _formatTime(entry.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
