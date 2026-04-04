import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/mood_entry.dart';
import '../bloc/analytics_bloc.dart';
import '../models/analytics_enums.dart';

class VisualView extends StatelessWidget {
  final AnalyticsLoaded state;

  const VisualView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        SegmentedButton<AnalyticsChartType>(
          segments: const [
            ButtonSegment<AnalyticsChartType>(
              value: AnalyticsChartType.line,
              label: Text('Line'),
            ),
            ButtonSegment<AnalyticsChartType>(
              value: AnalyticsChartType.bar,
              label: Text('Bar'),
            ),
            ButtonSegment<AnalyticsChartType>(
              value: AnalyticsChartType.distribution,
              label: Text('Distribution'),
            ),
          ],
          selected: {state.chartType},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            BlocProvider.of<AnalyticsBloc>(
              context,
            ).add(SwitchChartType(selection.first));
          },
        ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.chartType.label} chart',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 260, child: _buildChart(context)),
                if (state.chartType == AnalyticsChartType.distribution)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildPieLegend(theme),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    if (state.moodEntries.isEmpty) {
      return _emptyChartMessage(context);
    }

    switch (state.chartType) {
      case AnalyticsChartType.line:
        return _buildLineChart(context);
      case AnalyticsChartType.bar:
        return _buildBarChart(context);
      case AnalyticsChartType.distribution:
        return _buildDistributionChart(context);
    }
  }

  Widget _buildLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final startDate = state.period.startDate(DateTime.now());
    final spots = _buildLineSpots(state.moodEntries, state.period);

    if (spots.isEmpty) {
      return _emptyChartMessage(context);
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (state.period.days - 1).toDouble(),
        minY: 1,
        maxY: 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) =>
                  _lineBottomTitle(value, startDate, theme),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3.5,
                color: theme.colorScheme.primary,
                strokeWidth: 1,
                strokeColor: theme.colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final theme = Theme.of(context);
    final buckets = _buildBarBuckets(state.moodEntries, state.period);

    if (buckets.isEmpty) {
      return _emptyChartMessage(context);
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= buckets.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  buckets[index].label,
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(buckets.length, (index) {
          final bucket = buckets[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: bucket.average,
                width: state.period == AnalyticsPeriod.year ? 10 : 14,
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDistributionChart(BuildContext context) {
    final theme = Theme.of(context);
    final entries = state.moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return _emptyChartMessage(context);
    }

    final total = math.max(1, state.moodEntries.length);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 44,
        sections: entries.map((entry) {
          final percent = entry.value / total;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${(percent * 100).round()}%',
            radius: 72,
            color: Color(entry.key.colors.first),
            titleStyle: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieLegend(ThemeData theme) {
    final entries = state.moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(entry.key.colors.first),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('${entry.key.emoji} ${entry.key.label}'),
          ],
        );
      }).toList(),
    );
  }

  Widget _lineBottomTitle(double value, DateTime startDate, ThemeData theme) {
    final index = value.toInt();
    if (index < 0 || index >= state.period.days) {
      return const SizedBox.shrink();
    }

    final checkpoints = {0, state.period.days ~/ 2, state.period.days - 1};

    if (!checkpoints.contains(index)) {
      return const SizedBox.shrink();
    }

    final date = startDate.add(Duration(days: index));
    final label = '${date.month}/${date.day}';

    return Text(label, style: theme.textTheme.labelSmall);
  }

  List<FlSpot> _buildLineSpots(
    List<MoodEntry> entries,
    AnalyticsPeriod period,
  ) {
    final startDate = period.startDate(DateTime.now());
    final byDay = <int, List<double>>{};

    for (final entry in entries) {
      final dayIndex = entry.timestamp
          .difference(DateTime(startDate.year, startDate.month, startDate.day))
          .inDays;
      if (dayIndex < 0 || dayIndex >= period.days) continue;
      byDay
          .putIfAbsent(dayIndex, () => [])
          .add((entry.moodScore * 2).toDouble());
    }

    final spots = <FlSpot>[];
    final sortedKeys = byDay.keys.toList()..sort();
    for (final key in sortedKeys) {
      final values = byDay[key]!;
      final average = values.reduce((a, b) => a + b) / values.length;
      spots.add(FlSpot(key.toDouble(), average));
    }

    return spots;
  }

  List<_BarBucket> _buildBarBuckets(
    List<MoodEntry> entries,
    AnalyticsPeriod period,
  ) {
    switch (period) {
      case AnalyticsPeriod.week:
        return _buildDailyBuckets(entries, period.startDate(DateTime.now()), 7);
      case AnalyticsPeriod.month:
        return _buildWeeklyBuckets(entries, period.startDate(DateTime.now()));
      case AnalyticsPeriod.year:
        return _buildMonthlyBuckets(entries);
    }
  }

  List<_BarBucket> _buildDailyBuckets(
    List<MoodEntry> entries,
    DateTime start,
    int days,
  ) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final buckets = <_BarBucket>[];

    for (var i = 0; i < days; i++) {
      final bucketStart = normalizedStart.add(Duration(days: i));
      final bucketEnd = bucketStart.add(const Duration(days: 1));
      final values = entries
          .where(
            (entry) =>
                !entry.timestamp.isBefore(bucketStart) &&
                entry.timestamp.isBefore(bucketEnd),
          )
          .map((entry) => (entry.moodScore * 2).toDouble())
          .toList();

      final average = values.isEmpty
          ? 0.0
          : values.reduce((a, b) => a + b) / values.length;

      buckets.add(_BarBucket(_weekdayLabel(bucketStart.weekday), average));
    }

    return buckets;
  }

  List<_BarBucket> _buildWeeklyBuckets(
    List<MoodEntry> entries,
    DateTime start,
  ) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final weekCount = 5;
    final buckets = <_BarBucket>[];

    for (var i = 0; i < weekCount; i++) {
      final bucketStart = normalizedStart.add(Duration(days: i * 7));
      final bucketEnd = bucketStart.add(const Duration(days: 7));

      final values = entries
          .where(
            (entry) =>
                !entry.timestamp.isBefore(bucketStart) &&
                entry.timestamp.isBefore(bucketEnd),
          )
          .map((entry) => (entry.moodScore * 2).toDouble())
          .toList();

      final average = values.isEmpty
          ? 0.0
          : values.reduce((a, b) => a + b) / values.length;

      buckets.add(_BarBucket('W${i + 1}', average));
    }

    return buckets;
  }

  List<_BarBucket> _buildMonthlyBuckets(List<MoodEntry> entries) {
    final now = DateTime.now();
    final startMonth = DateTime(now.year, now.month - 11, 1);
    final buckets = <_BarBucket>[];

    for (var i = 0; i < 12; i++) {
      final bucketStart = DateTime(startMonth.year, startMonth.month + i, 1);
      final bucketEnd = DateTime(bucketStart.year, bucketStart.month + 1, 1);

      final values = entries
          .where(
            (entry) =>
                !entry.timestamp.isBefore(bucketStart) &&
                entry.timestamp.isBefore(bucketEnd),
          )
          .map((entry) => (entry.moodScore * 2).toDouble())
          .toList();

      final average = values.isEmpty
          ? 0.0
          : values.reduce((a, b) => a + b) / values.length;

      buckets.add(_BarBucket(_monthLabel(bucketStart.month), average));
    }

    return buckets;
  }

  String _weekdayLabel(int weekday) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[(weekday - 1).clamp(0, 6)];
  }

  String _monthLabel(int month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[(month - 1).clamp(0, 11)];
  }

  Widget _emptyChartMessage(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'No mood data for this period yet.',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _BarBucket {
  final String label;
  final double average;

  const _BarBucket(this.label, this.average);
}
