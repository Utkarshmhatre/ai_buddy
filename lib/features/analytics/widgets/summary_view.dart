import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bloc/analytics_bloc.dart';

class SummaryView extends StatelessWidget {
  final AnalyticsLoaded state;

  const SummaryView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        _buildOverviewCard(theme),
        const SizedBox(height: 12),
        _buildTextCard(theme, '📊 Mood Story', state.moodNarrative),
        const SizedBox(height: 12),
        _buildTextCard(theme, '🔍 Pattern', state.patternInsight),
        const SizedBox(height: 12),
        _buildTextCard(theme, '🔮 Prediction', state.prediction),
        const SizedBox(height: 12),
        _buildDistributionCard(theme),
      ],
    );
  }

  Widget _buildOverviewCard(ThemeData theme) {
    final scoreColor = _scoreColor(theme, state.averageMoodScore);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text('This ${state.period.label}'),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${state.averageMoodScore.toStringAsFixed(1)} / 10',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Average mood score',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.moodEntries.isEmpty
                  ? 'No entries yet for this period.'
                  : 'Based on ${state.moodEntries.length} mood check-ins.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard(ThemeData theme, String title, String body) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionCard(ThemeData theme) {
    final sorted = state.moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalEntries = math.max(1, state.moodEntries.length);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📈 At a glance',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (sorted.isEmpty)
              Text(
                'Add mood entries to see your distribution.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...sorted.map((entry) {
                final category = entry.key;
                final count = entry.value;
                final ratio = count / totalEntries;
                final moodColor = Color(category.colors.first);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${category.emoji} ${category.label}'),
                          const Spacer(),
                          Text('${(ratio * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        color: moodColor,
                        backgroundColor: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(ThemeData theme, double score) {
    if (score >= 7) return Colors.green.shade600;
    if (score >= 5) return Colors.orange.shade700;
    return theme.colorScheme.error;
  }
}
