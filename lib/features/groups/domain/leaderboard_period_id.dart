String currentLeaderboardPeriodId({required int windowWeeks, DateTime? now}) {
  final normalizedWindowWeeks = windowWeeks > 0 ? windowWeeks : 1;
  final parts = isoWeekParts(now ?? DateTime.now().toUtc());
  if (normalizedWindowWeeks == 1) {
    return parts.periodId;
  }

  final windowIndex = ((parts.week - 1) ~/ normalizedWindowWeeks) + 1;
  final paddedWindow = windowIndex.toString().padLeft(2, '0');
  return '${parts.year}-W${paddedWindow}x$normalizedWindowWeeks';
}

({int year, int week, String periodId}) isoWeekParts(DateTime date) {
  final utcDate = DateTime.utc(date.year, date.month, date.day);
  final day = utcDate.weekday;
  final thursday = utcDate.add(Duration(days: 4 - day));
  final yearStart = DateTime.utc(thursday.year);
  final week = ((thursday.difference(yearStart).inDays + 1) / 7).ceil();
  final periodId = '${thursday.year}-W${week.toString().padLeft(2, '0')}';

  return (year: thursday.year, week: week, periodId: periodId);
}
