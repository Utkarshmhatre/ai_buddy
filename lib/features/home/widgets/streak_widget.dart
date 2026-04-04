import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/streak_service.dart';
import '../../../core/theme/app_colors.dart';

/// Widget displaying the user's current streak with animation
class StreakWidget extends StatelessWidget {
  final StreakData? streakData;
  final bool isLoading;
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    this.streakData,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildShimmer(context);
    }

    final streak = streakData?.currentStreak ?? 0;
    final hasActivityToday = streakData?.hasActivityToday ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: streak > 0
                ? [
                    AppColors.celebrationTint,
                    AppColors.celebrationTint.withOpacity(0.7),
                  ]
                : [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: streak > 0
              ? [
                  BoxShadow(
                    color: AppColors.celebrationTint.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Fire icon with animation
            _buildStreakIcon(streak, hasActivityToday),
            const SizedBox(width: 16),
            // Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$streak',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: streak > 0
                              ? AppColors.textPrimaryLight
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        streak == 1 ? 'day streak' : 'day streak',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: streak > 0
                              ? AppColors.textPrimaryLight.withOpacity(0.8)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    streakData?.encouragementMessage ?? 'Start your streak today!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: streak > 0
                          ? AppColors.textPrimaryLight.withOpacity(0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Activity indicator
            if (!hasActivityToday && streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.textPrimaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Log today!',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 500.ms)
                  .then()
                  .fadeOut(duration: 500.ms, delay: 1.seconds),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIcon(int streak, bool hasActivityToday) {
    final iconSize = 48.0;
    
    Widget icon = Icon(
      streak > 0 ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
      size: iconSize,
      color: streak > 0 ? Colors.orange : Colors.grey,
    );

    if (streak > 0) {
      icon = icon
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2.seconds,
            color: Colors.white.withOpacity(0.5),
          )
          .animate()
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 600.ms,
            curve: Curves.elasticOut,
          );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: streak > 0
            ? Colors.white.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1.5.seconds);
  }
}

/// Compact streak indicator for use in smaller spaces
class CompactStreakIndicator extends StatelessWidget {
  final int streak;
  final bool hasActivityToday;

  const CompactStreakIndicator({
    super.key,
    required this.streak,
    required this.hasActivityToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: streak > 0
            ? AppColors.celebrationTint.withOpacity(0.2)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streak > 0
              ? AppColors.celebrationTint.withOpacity(0.5)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: streak > 0 ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: streak > 0
                  ? Colors.orange.shade700
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!hasActivityToday && streak > 0) ...[
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
