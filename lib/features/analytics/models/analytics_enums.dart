enum AnalyticsMode {
  summary('Summary'),
  visual('Visual');

  final String label;
  const AnalyticsMode(this.label);
}

enum AnalyticsPeriod {
  week('Week', 7),
  month('Month', 30),
  year('Year', 365);

  final String label;
  final int days;
  const AnalyticsPeriod(this.label, this.days);

  DateTime startDate(DateTime now) {
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
  }
}

enum AnalyticsChartType {
  line('Line'),
  bar('Bar'),
  distribution('Distribution');

  final String label;
  const AnalyticsChartType(this.label);
}
