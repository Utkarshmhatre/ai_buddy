import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';

/// Screen showing AI-generated insights and patterns
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InsightsBloc>().add(const LoadInsights());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<InsightsBloc>().add(const LoadInsights());
            },
            tooltip: 'Refresh Insights',
          ),
        ],
      ),
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (context, state) {
          if (state is InsightsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is InsightsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<InsightsBloc>().add(const LoadInsights());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is InsightsLoaded) {
            return _buildContent(context, state);
          }
          
          return _buildEmptyState(context);
        },
      ),
    );
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up_rounded;
      case 'declining':
        return Icons.trending_down_rounded;
      case 'fluctuating':
        return Icons.trending_flat_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return AppColors.encouragementTint;
      case 'declining':
        return Colors.orange;
      case 'fluctuating':
        return AppColors.thoughtfulTint;
      default:
        return AppColors.calmTint;
    }
  }

  String _formatTrend(String trend) {
    switch (trend) {
      case 'improving':
        return 'Improving 📈';
      case 'declining':
        return 'Needs Attention';
      case 'fluctuating':
        return 'Variable';
      case 'stable':
        return 'Stable';
      default:
        return 'Building Data';
    }
  }

  String _formatTimePatterns(Map<String, dynamic> timePatterns) {
    final parts = <String>[];
    
    final bestDays = timePatterns['bestDays'] as List<dynamic>?;
    if (bestDays != null && bestDays.isNotEmpty) {
      parts.add('Best days: ${bestDays.join(", ")}');
    }
    
    final challengingDays = timePatterns['challengingDays'] as List<dynamic>?;
    if (challengingDays != null && challengingDays.isNotEmpty) {
      parts.add('Challenging: ${challengingDays.join(", ")}');
    }
    
    final bestTime = timePatterns['bestTimeOfDay'] as String?;
    if (bestTime != null) {
      parts.add('Peak time: $bestTime');
    }
    
    return parts.isNotEmpty ? parts.join(' • ') : 'Keep tracking for time insights';
  }

  Widget _buildContent(BuildContext context, InsightsLoaded state) {
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<InsightsBloc>().add(const LoadInsights());
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Weekly summary card
          _WeeklySummaryCard(
            summary: state.weeklySummary,
            checkIns: state.totalCheckIns,
            streak: state.checkInStreak,
            averageMood: state.averageMood,
          ),
          const SizedBox(height: 24),
          
          // AI Pattern Analysis Section
          if (state.patternAnalysis != null) ...[
            _SectionHeader(
              title: 'AI Pattern Analysis',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _PatternAnalysisCard(analysis: state.patternAnalysis!),
            const SizedBox(height: 24),
          ],
          
          // Detected Patterns
          _SectionHeader(
            title: 'Patterns Detected',
            icon: Icons.psychology_rounded,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          
          if (state.patternAnalysis != null) ...[
            // Overall Trend
            if (state.patternAnalysis!.trendDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PatternCard(
                  icon: _getTrendIcon(state.patternAnalysis!.overallTrend),
                  title: 'Mood Trend: ${_formatTrend(state.patternAnalysis!.overallTrend)}',
                  description: state.patternAnalysis!.trendDescription,
                  color: _getTrendColor(state.patternAnalysis!.overallTrend),
                ),
              ),
            
            // Recurring Themes
            if (state.patternAnalysis!.recurringThemes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PatternCard(
                  icon: Icons.repeat_rounded,
                  title: 'Recurring Themes',
                  description: state.patternAnalysis!.recurringThemes.join(", "),
                  color: AppColors.calmTint,
                ),
              ),
            
            // Time Patterns
            if (state.patternAnalysis!.timePatterns != null)
              _PatternCard(
                icon: Icons.schedule_rounded,
                title: 'Time Patterns',
                description: _formatTimePatterns(state.patternAnalysis!.timePatterns!),
                color: AppColors.thoughtfulTint,
              ),
          ] else ...[
            // Default patterns when no AI analysis
            _PatternCard(
              icon: Icons.wb_sunny_rounded,
              title: 'Keep Tracking',
              description: 'Log more moods to unlock AI-powered pattern insights.',
              color: AppColors.encouragementTint,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Top Triggers Section
          if (state.topTriggers.isNotEmpty) ...[
            _SectionHeader(
              title: 'Common Triggers',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _ChipSection(
              items: state.topTriggers,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
          ],
          
          // Helpful Activities Section
          if (state.helpfulActivities.isNotEmpty) ...[
            _SectionHeader(
              title: 'Helpful Activities',
              icon: Icons.favorite_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _ChipSection(
              items: state.helpfulActivities,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 24),
          ],
          
          // Growth Opportunities / Suggested Strategies
          if (state.patternAnalysis != null &&
              state.patternAnalysis!.growthOpportunities.isNotEmpty) ...[
            _SectionHeader(
              title: 'Growth Opportunities',
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            ...state.patternAnalysis!.growthOpportunities.map((strategy) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StrategyCard(strategy: strategy),
            )),
            const SizedBox(height: 24),
          ],
          
          // Strengths Section
          if (state.patternAnalysis != null &&
              state.patternAnalysis!.strengths.isNotEmpty) ...[
            _SectionHeader(
              title: 'Your Strengths',
              icon: Icons.star_rounded,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _ChipSection(
              items: state.patternAnalysis!.strengths,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
          ],
          
          // Growth section
          _SectionHeader(
            title: 'Your Growth',
            icon: Icons.emoji_events_rounded,
            color: AppColors.encouragementTint,
          ),
          const SizedBox(height: 12),
          _GrowthCard(
            streak: state.checkInStreak,
            totalCheckIns: state.totalCheckIns,
          ),
          
          const SizedBox(height: 24),
          
          // View Reports Button
          _ViewReportsCard(
            onTap: () => context.push(AppRoutes.reports),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
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
              Icons.insights_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Start Tracking Your Mood',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete a few mood check-ins to unlock personalized insights and pattern recognition.',
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final WeeklySummary? summary;
  final int checkIns;
  final int streak;
  final double? averageMood;

  const _WeeklySummaryCard({
    this.summary,
    required this.checkIns,
    required this.streak,
    this.averageMood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('📊', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary?.summaryText ??
                "Complete more check-ins this week to unlock your personalized weekly summary.",
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryChip(
                label: '$checkIns check-ins',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              if (summary != null && summary!.moodChangePercent != 0)
                _SummaryChip(
                  label: '${summary!.moodChangePercent > 0 ? '+' : ''}${summary!.moodChangePercent}% mood',
                  icon: summary!.moodChangePercent > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: '$streak day streak',
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SummaryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternAnalysisCard extends StatelessWidget {
  final PatternAnalysis analysis;

  const _PatternAnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryAlt.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'AI-Powered Insights',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (analysis.recurringThemes.isNotEmpty) ...[
            Text(
              'Recurring Themes',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: analysis.recurringThemes.map((theme) => Chip(
                label: Text(theme, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _PatternCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  final List<String> items;
  final Color color;

  const _ChipSection({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Use contrasting text color for visibility
    final textColor = isDark ? Colors.white : color.withValues(alpha: 0.9);
    final bgColor = isDark 
        ? color.withValues(alpha: 0.25) 
        : color.withValues(alpha: 0.1);
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => Chip(
        label: Text(
          item,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: bgColor,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      )).toList(),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final String strategy;

  const _StrategyCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strategy,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final int streak;
  final int totalCheckIns;

  const _GrowthCard({
    required this.streak,
    required this.totalCheckIns,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final badgeTitle = _getBadgeTitle(streak);
    final badgeProgress = (streak / 10).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getBadgeEmoji(streak),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badgeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'You\'ve checked in $streak days in a row!',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: badgeProgress,
              backgroundColor: AppColors.encouragementTint.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(AppColors.encouragementTint),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$streak / 10 days to unlock "Mindful Week" badge',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeTitle(int streak) {
    if (streak >= 30) return 'Mindfulness Master';
    if (streak >= 14) return 'Consistent Champion';
    if (streak >= 7) return 'Weekly Warrior';
    if (streak >= 3) return 'Getting Started';
    return 'Beginning Your Journey';
  }

  String _getBadgeEmoji(int streak) {
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '🌟';
    if (streak >= 3) return '🌱';
    return '🌱';
  }
}

class _ViewReportsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewReportsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Generated Reports',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View weekly & monthly summaries, predictions, and shareable reports',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
