import 'package:point_rivals/features/groups/domain/group_models.dart';

enum LeaderboardPeriod { weekly, allTime }

final class LeaderboardCalculator {
  const LeaderboardCalculator();

  List<GroupMember> topMembers({
    required List<GroupMember> members,
    required LeaderboardPeriod period,
    String? weeklyPeriodId,
    int limit = 3,
  }) {
    final sortedMembers = [...members];
    sortedMembers.sort((left, right) {
      final rightScore = _scoreFor(
        right,
        period,
        weeklyPeriodId: weeklyPeriodId,
      );
      final leftScore = _scoreFor(left, period, weeklyPeriodId: weeklyPeriodId);
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
    String? weeklyPeriodId,
  }) {
    return _scoreFor(member, period, weeklyPeriodId: weeklyPeriodId);
  }

  int _scoreFor(
    GroupMember member,
    LeaderboardPeriod period, {
    String? weeklyPeriodId,
  }) {
    return switch (period) {
      LeaderboardPeriod.weekly =>
        weeklyPeriodId == null || member.weeklyScorePeriodId == weeklyPeriodId
            ? member.weeklyTokensEarned
            : 0,
      LeaderboardPeriod.allTime => member.allTimeTokensEarned,
    };
  }
}
