import 'package:point_rivals/features/groups/domain/group_models.dart';

enum LeaderboardPeriod { month, allTime }

final class LeaderboardCalculator {
  const LeaderboardCalculator();

  List<GroupMember> topMembers({
    required List<GroupMember> members,
    required LeaderboardPeriod period,
    String? monthPeriodId,
    List<String> activeDateIds = const [],
    Set<String> legacyWeeklyPeriodIds = const {},
    Map<String, int> reconstructedMonthScores = const {},
    int limit = 3,
  }) {
    final sortedMembers = [...members];
    sortedMembers.sort((left, right) {
      final rightScore = _scoreFor(
        right,
        period,
        monthPeriodId: monthPeriodId,
        activeDateIds: activeDateIds,
        legacyWeeklyPeriodIds: legacyWeeklyPeriodIds,
        reconstructedMonthScores: reconstructedMonthScores,
      );
      final leftScore = _scoreFor(
        left,
        period,
        monthPeriodId: monthPeriodId,
        activeDateIds: activeDateIds,
        legacyWeeklyPeriodIds: legacyWeeklyPeriodIds,
        reconstructedMonthScores: reconstructedMonthScores,
      );
      final scoreComparison = rightScore.compareTo(leftScore);
      if (scoreComparison != 0) {
        return scoreComparison;
      }

      return left.displayName.compareTo(right.displayName);
    });

    return sortedMembers.take(limit).toList();
  }

  int scoreFor(
    GroupMember member,
    LeaderboardPeriod period, {
    String? monthPeriodId,
    List<String> activeDateIds = const [],
    Set<String> legacyWeeklyPeriodIds = const {},
    Map<String, int> reconstructedMonthScores = const {},
  }) {
    return _scoreFor(
      member,
      period,
      monthPeriodId: monthPeriodId,
      activeDateIds: activeDateIds,
      legacyWeeklyPeriodIds: legacyWeeklyPeriodIds,
      reconstructedMonthScores: reconstructedMonthScores,
    );
  }

  int _scoreFor(
    GroupMember member,
    LeaderboardPeriod period, {
    String? monthPeriodId,
    List<String> activeDateIds = const [],
    Set<String> legacyWeeklyPeriodIds = const {},
    Map<String, int> reconstructedMonthScores = const {},
  }) {
    return switch (period) {
      LeaderboardPeriod.month => _monthScoreFor(
        member,
        monthPeriodId: monthPeriodId,
        activeDateIds: activeDateIds,
        legacyWeeklyPeriodIds: legacyWeeklyPeriodIds,
        reconstructedMonthScores: reconstructedMonthScores,
      ),
      LeaderboardPeriod.allTime => member.allTimeTokensEarned,
    };
  }

  int _monthScoreFor(
    GroupMember member, {
    required String? monthPeriodId,
    required List<String> activeDateIds,
    required Set<String> legacyWeeklyPeriodIds,
    required Map<String, int> reconstructedMonthScores,
  }) {
    final dailyScore = activeDateIds.fold<int>(
      0,
      (total, dateId) => total + (member.dailyTokenBuckets[dateId] ?? 0),
    );
    final legacyPeriodMatches =
        monthPeriodId == null ||
        legacyWeeklyPeriodIds.contains(member.weeklyScorePeriodId);
    final legacyScore = legacyPeriodMatches ? member.weeklyTokensEarned : 0;
    final reconstructedScore = reconstructedMonthScores[member.userId] ?? 0;

    return [
      dailyScore,
      legacyScore,
      reconstructedScore,
    ].reduce((value, element) => value > element ? value : element);
  }
}
