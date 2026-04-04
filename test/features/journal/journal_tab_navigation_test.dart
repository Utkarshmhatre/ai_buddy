import 'package:ai_buddy/core/router/app_router.dart';
import 'package:ai_buddy/core/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  GoRouter buildTestRouter() {
    return GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const _HomeStub(),
            ),
            GoRoute(
              path: AppRoutes.chat,
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: AppRoutes.journal,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: _JournalListStub()),
              routes: [
                GoRoute(
                  path: 'write',
                  builder: (context, state) => const _JournalEntryStub(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.analytics,
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.moodCheckIn,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  testWidgets('tapping Journal tab shows JournalListScreen', (
    WidgetTester tester,
  ) async {
    final router = buildTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('HomeScreen'), findsOneWidget);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();

    expect(find.text('JournalListScreen'), findsOneWidget);
    expect(find.byType(BottomAppBar), findsOneWidget);
  });

  testWidgets(
    'entry push stays inside tab shell and keeps bottom nav visible',
    (WidgetTester tester) async {
      final router = buildTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open Journal Entry'));
      await tester.pumpAndSettle();

      expect(find.text('JournalEntryScreen'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsOneWidget);
    },
  );
}

class _HomeStub extends StatelessWidget {
  const _HomeStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('HomeScreen')));
  }
}

class _JournalListStub extends StatelessWidget {
  const _JournalListStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('JournalListScreen')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Open Journal Entry',
        onPressed: () => context.push(AppRoutes.journalWrite),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _JournalEntryStub extends StatelessWidget {
  const _JournalEntryStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('JournalEntryScreen')));
  }
}
