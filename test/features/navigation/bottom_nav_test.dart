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
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: AppRoutes.chat,
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: AppRoutes.journal,
              builder: (context, state) => const SizedBox.shrink(),
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

  testWidgets('bottom nav shows four required labels', (
    WidgetTester tester,
  ) async {
    final router = buildTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final bottomBar = find.byType(BottomAppBar);
    expect(bottomBar, findsOneWidget);

    const expectedLabels = ['Home', 'Chat', 'Journal', 'Analytics'];

    for (final label in expectedLabels) {
      expect(
        find.descendant(of: bottomBar, matching: find.text(label)),
        findsOneWidget,
      );
    }

    final navLabelFinder = find.descendant(
      of: bottomBar,
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && expectedLabels.contains(widget.data),
      ),
    );
    expect(navLabelFinder, findsNWidgets(4));

    expect(find.text('Mood'), findsNothing);
    expect(find.text('Insights'), findsNothing);
    expect(find.text('More'), findsNothing);
  });
}
