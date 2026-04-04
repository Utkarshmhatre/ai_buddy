import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../bloc/analytics_bloc.dart';
import '../models/analytics_enums.dart';
import '../widgets/summary_view.dart';
import '../widgets/visual_view.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(
      const LoadAnalytics(AnalyticsPeriod.week),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mood & Insights'),
      ),
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            final mode = _modeForState(state);
            final period = _periodForState(state);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SegmentedButton<AnalyticsMode>(
                    segments: const [
                      ButtonSegment<AnalyticsMode>(
                        value: AnalyticsMode.summary,
                        label: Text('Summary'),
                      ),
                      ButtonSegment<AnalyticsMode>(
                        value: AnalyticsMode.visual,
                        label: Text('Visual'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      context.read<AnalyticsBloc>().add(
                        SwitchMode(selection.first),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: AnalyticsPeriod.values.map((item) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: item != AnalyticsPeriod.values.last ? 8 : 0,
                          ),
                          child: FilterChip(
                            showCheckmark: false,
                            label: Text(item.label),
                            selected: period == item,
                            onSelected: (_) {
                              context.read<AnalyticsBloc>().add(
                                SwitchPeriod(item),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildContent(state, mode, period)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.moodCheckIn);
          if (!mounted) return;

          final currentPeriod = _periodForState(
            context.read<AnalyticsBloc>().state,
          );
          context.read<AnalyticsBloc>().add(SwitchPeriod(currentPeriod));
        },
        tooltip: 'Quick mood log',
        child: const Icon(Icons.add),
      ),
    );
  }

  AnalyticsMode _modeForState(AnalyticsState state) {
    if (state is AnalyticsLoaded) return state.mode;
    if (state is AnalyticsLoading) return state.mode;
    if (state is AnalyticsError) return state.mode;
    return AnalyticsMode.summary;
  }

  AnalyticsPeriod _periodForState(AnalyticsState state) {
    if (state is AnalyticsLoaded) return state.period;
    if (state is AnalyticsLoading) return state.period;
    if (state is AnalyticsError) return state.period;
    return AnalyticsPeriod.week;
  }

  Widget _buildContent(
    AnalyticsState state,
    AnalyticsMode mode,
    AnalyticsPeriod period,
  ) {
    if (state is AnalyticsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AnalyticsError) {
      return Center(
        child: _ErrorCard(
          message: state.message,
          onRetry: () =>
              context.read<AnalyticsBloc>().add(LoadAnalytics(period)),
        ),
      );
    }

    if (state is AnalyticsLoaded) {
      if (mode == AnalyticsMode.summary) {
        return SummaryView(state: state);
      }
      return VisualView(state: state);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
