import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/journal_entry.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/exercises/screens/breathing_exercise_screen.dart';
import '../../features/exercises/screens/grounding_exercise_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/journal/screens/journal_detail_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/journal/screens/journal_write_screen.dart';
import '../../features/mood/screens/mood_check_in_screen.dart';
import '../../features/mood/screens/mood_history_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../widgets/main_scaffold.dart';

/// App routes
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String chat = '/chat';
  static const String analytics = '/analytics';
  static const String moodCheckIn = '/mood/check-in';
  static const String moodHistory = '/mood/history';
  static const String insights = '/insights';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String breathingExercise = '/exercise/breathing';
  static const String groundingExercise = '/exercise/grounding';
  static const String journal = '/journal';
  static const String journalWrite = '/journal/write';
  static const String journalView = '/journal/view';
}

/// App router configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router({bool showOnboarding = false}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
      routes: [
        // Onboarding (full screen, no bottom nav)
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Main app with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
            GoRoute(
              path: AppRoutes.chat,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ChatScreen()),
            ),
            GoRoute(
              path: AppRoutes.journal,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: JournalScreen()),
              routes: [
                GoRoute(
                  path: 'write',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return JournalWriteScreen(
                      type:
                          extra?['type'] as JournalEntryType? ??
                          JournalEntryType.free,
                      initialPrompt: extra?['prompt'] as String?,
                    );
                  },
                ),
                GoRoute(
                  path: 'view',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return JournalDetailScreen(
                      entry: extra['entry'] as JournalEntry,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.analytics,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AnalyticsScreen()),
            ),
          ],
        ),

        // Modal screens (without bottom nav)
        GoRoute(
          path: AppRoutes.moodCheckIn,
          builder: (context, state) => const MoodCheckInScreen(),
        ),
        GoRoute(
          path: AppRoutes.moodHistory,
          builder: (context, state) => const MoodHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.insights,
          builder: (context, state) => const InsightsScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        // Therapeutic exercises
        GoRoute(
          path: AppRoutes.breathingExercise,
          builder: (context, state) => const BreathingExerciseScreen(),
        ),
        GoRoute(
          path: AppRoutes.groundingExercise,
          builder: (context, state) => const GroundingExerciseScreen(),
        ),
        GoRoute(
          path: AppRoutes.reports,
          builder: (context, state) => const ReportsScreen(),
        ),
      ],
    );
  }
}
