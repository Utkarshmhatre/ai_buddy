import 'package:equatable/equatable.dart';

/// Events for InsightsBloc
abstract class InsightsEvent extends Equatable {
  const InsightsEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load all insights data
class LoadInsights extends InsightsEvent {
  const LoadInsights();
}

/// Refresh pattern analysis
class RefreshPatternAnalysis extends InsightsEvent {
  const RefreshPatternAnalysis();
}

/// Generate weekly summary
class GenerateWeeklySummary extends InsightsEvent {
  const GenerateWeeklySummary();
}
