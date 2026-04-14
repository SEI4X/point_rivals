String currentLeaderboardMonthId({DateTime? now}) {
  final current = _dateOnly(now ?? DateTime.now().toUtc());
  return '${current.year}-${current.month.toString().padLeft(2, '0')}';
}

DateTime currentLeaderboardMonthStart({DateTime? now}) {
  final current = _dateOnly(now ?? DateTime.now().toUtc());
  return DateTime.utc(current.year, current.month);
}

List<String> currentMonthDateIds({DateTime? now}) {
  final current = _dateOnly(now ?? DateTime.now().toUtc());
  final start = currentLeaderboardMonthStart(now: current);

  return [
    for (
      var date = start;
      !date.isAfter(current);
      date = date.add(const Duration(days: 1))
    )
      _dateId(date),
  ];
}

Set<String> currentMonthIsoWeekPeriodIds({DateTime? now}) {
  final dateIds = currentMonthDateIds(now: now);

  return {
    for (final dateId in dateIds)
      isoWeekParts(
        DateTime.utc(
          int.parse(dateId.substring(0, 4)),
          int.parse(dateId.substring(4, 6)),
          int.parse(dateId.substring(6, 8)),
        ),
      ).periodId,
  };
}

DateTime _dateOnly(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

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
