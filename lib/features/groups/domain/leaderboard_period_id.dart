String currentLeaderboardPeriodId({
  required int windowWeeks,
  DateTime? anchorDate,
  DateTime? now,
}) {
  final normalizedWindowWeeks = windowWeeks > 0 ? windowWeeks : 1;
  final currentDate = now ?? DateTime.now().toUtc();
  if (anchorDate != null) {
    return sprintPeriodId(
      windowWeeks: normalizedWindowWeeks,
      anchorDate: anchorDate,
      now: currentDate,
    );
  }

  final parts = isoWeekParts(currentDate);
  if (normalizedWindowWeeks == 1) {
    return parts.periodId;
  }

  final windowIndex = ((parts.week - 1) ~/ normalizedWindowWeeks) + 1;
  final paddedWindow = windowIndex.toString().padLeft(2, '0');
  return '${parts.year}-W${paddedWindow}x$normalizedWindowWeeks';
}

String sprintPeriodId({
  required int windowWeeks,
  required DateTime anchorDate,
  DateTime? now,
}) {
  final normalizedWindowWeeks = windowWeeks > 0 ? windowWeeks : 1;
  final periodDays = normalizedWindowWeeks * 7;
  final anchor = DateTime.utc(
    anchorDate.year,
    anchorDate.month,
    anchorDate.day,
  );
  final current = now ?? DateTime.now().toUtc();
  final today = DateTime.utc(current.year, current.month, current.day);
  final daysSinceAnchor = today.difference(anchor).inDays;
  final periodIndex = daysSinceAnchor < 0 ? 0 : daysSinceAnchor ~/ periodDays;
  final periodStart = anchor.add(Duration(days: periodIndex * periodDays));

  return '${_dateId(periodStart)}-S${(periodIndex + 1).toString().padLeft(3, '0')}x$normalizedWindowWeeks';
}

String _dateId(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}$month$day';
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
