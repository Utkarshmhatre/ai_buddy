import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mood_entry.dart';

/// Card showing recent mood summary with mini chart
class MoodSummaryCard extends StatelessWidget {
  final VoidCallback? onViewAllTap;

  const MoodSummaryCard({super.key, this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data for now - will be replaced with real data from BLoC
    final recentMoods = [
      MoodCategory.calm,
      MoodCategory.happy,
      MoodCategory.grateful,
      MoodCategory.anxious,
      MoodCategory.calm,
      MoodCategory.happy,
      MoodCategory.hopeful,
    ];
    
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onViewAllTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                    'This Week',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View All',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Mini mood chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final mood = index < recentMoods.length 
                      ? recentMoods[index] 
                      : null;
                  final isToday = index == recentMoods.length - 1;
                  
                  return _MoodDayColumn(
                    day: dayNames[index],
                    mood: mood,
                    isToday: isToday,
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              // Summary text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.encouragementTint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('📈', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You've been mostly positive this week!",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodDayColumn extends StatelessWidget {
  final String day;
  final MoodCategory? mood;
  final bool isToday;

  const _MoodDayColumn({
    required this.day,
    this.mood,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          day,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isToday 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: mood != null 
                ? Color(mood!.colors.first).withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: isToday 
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              mood?.emoji ?? '—',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
