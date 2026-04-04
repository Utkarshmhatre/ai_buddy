import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/quotes_service.dart';
import '../../../core/services/streak_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../../data/repositories/mood_repository.dart';
import '../../exercises/screens/configurable_breathing_screen.dart';
import '../widgets/daily_insight_card.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/greeting_header.dart';
import '../widgets/streak_widget.dart';

/// Home screen with wellness dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuotesService _quotesService = QuotesService();
  StreakData? _streakData;
  bool _isLoadingStreak = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadStreakData();
    _loadUserName();
  }

  Future<void> _loadStreakData() async {
    try {
      final moodRepository = context.read<MoodRepository>();
      final journalRepository = context.read<JournalRepository>();

      final streakService = StreakService(
        moodRepository: moodRepository,
        journalRepository: journalRepository,
      );

      final streakData = await streakService.getStreakData();

      if (mounted) {
        setState(() {
          _streakData = streakData;
          _isLoadingStreak = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStreak = false;
        });
      }
    }
  }

  void _loadUserName() {
    // In a real implementation, this would load from user profile
    // For now, we'll leave it null and let the greeting handle it
    setState(() {
      _userName = null; // Load from user profile when available
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todaysQuote = _quotesService.getTimeAppropriateQuote();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App bar with greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: GreetingHeader(
                    userName: _userName,
                    onSettingsTap: () => context.push(AppRoutes.settings),
                  ),
                ),
              ),

              // Streak widget
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: StreakWidget(
                    streakData: _streakData,
                    isLoading: _isLoadingStreak,
                    onTap: () => context.go(AppRoutes.moodHistory),
                  ),
                ),
              ),

              // Daily insight card with motivational quote
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: DailyInsightCard(
                    insight: todaysQuote,
                    onTap: () => context.go(AppRoutes.insights),
                  ),
                ),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: QuickActionsRow(
                    onChatTap: () => context.go(AppRoutes.chat),
                    onMoodTap: () => context.push(AppRoutes.moodCheckIn),
                    onBreatheTap: () => _showBreathingExercises(context),
                  ),
                ),
              ),

              // Recent mood summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: MoodSummaryCard(
                    onViewAllTap: () => context.go(AppRoutes.moodHistory),
                  ),
                ),
              ),

              // Suggested activities section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Suggested for You',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Activity cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ActivityCard(
                      icon: Icons.self_improvement_rounded,
                      title: '5-Minute Calm',
                      subtitle: 'Box breathing exercise',
                      color: AppColors.primary,
                      onTap: () => _showBreathingExercise(context),
                    ),
                    const SizedBox(height: 12),
                    _ActivityCard(
                      icon: Icons.psychology_rounded,
                      title: 'Grounding Exercise',
                      subtitle: '5-4-3-2-1 technique',
                      color: AppColors.primaryAlt,
                      onTap: () => _showGroundingExercise(context),
                    ),
                    const SizedBox(height: 12),
                    _ActivityCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Evening Reflection',
                      subtitle: 'Journal about your day',
                      color: AppColors.secondary,
                      onTap: () => _showJournalPrompt(context),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBreathingExercises(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _BreathingExercisesSheet(),
    );
  }

  void _showBreathingExercise(BuildContext context) {
    context.push(AppRoutes.breathingExercise);
  }

  void _showGroundingExercise(BuildContext context) {
    context.push(AppRoutes.groundingExercise);
  }

  void _showJournalPrompt(BuildContext context) {
    context.go(AppRoutes.journal);
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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

/// Bottom sheet for selecting breathing exercises
class _BreathingExercisesSheet extends StatelessWidget {
  const _BreathingExercisesSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Breathing Exercises',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _ExerciseOption(
              icon: Icons.air_rounded,
              title: '4-7-8 Breathing',
              description: 'Calming technique for sleep and relaxation',
              duration: '5 min',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfigurableBreathingScreen(
                      exerciseType: BreathingExerciseType.fourSevenEight,
                    ),
                  ),
                );
              },
            ),
            _ExerciseOption(
              icon: Icons.crop_square_rounded,
              title: 'Box Breathing',
              description: 'Focus and reduce stress',
              duration: '4 min',
              color: AppColors.calmTint,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfigurableBreathingScreen(
                      exerciseType: BreathingExerciseType.box,
                    ),
                  ),
                );
              },
            ),
            _ExerciseOption(
              icon: Icons.expand_rounded,
              title: 'Deep Belly Breathing',
              description: 'Activate relaxation response',
              duration: '5 min',
              color: AppColors.encouragementTint,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfigurableBreathingScreen(
                      exerciseType: BreathingExerciseType.deepBelly,
                    ),
                  ),
                );
              },
            ),
            _ExerciseOption(
              icon: Icons.bolt_rounded,
              title: 'Energizing Breath',
              description: 'Boost energy and alertness',
              duration: '3 min',
              color: AppColors.celebrationTint,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfigurableBreathingScreen(
                      exerciseType: BreathingExerciseType.energizing,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ExerciseOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String duration;
  final Color color;
  final VoidCallback onTap;

  const _ExerciseOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.duration,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
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
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
