import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/groups/domain/leaderboard_calculator.dart';

void main() {
  const calculator = LeaderboardCalculator();

  GroupMember member({
    required String id,
    required String name,
    required int weeklyTokensEarned,
    required int allTimeTokensEarned,
  }) {
    return GroupMember(
      userId: id,
      displayName: name,
      avatarUrl: null,
      role: GroupMemberRole.member,
      tokenBalance: allTimeTokensEarned,
      weeklyTokensEarned: weeklyTokensEarned,
      weeklyScorePeriodId: '2026-W16',
      allTimeTokensEarned: allTimeTokensEarned,
      xp: 0,
      totalWagers: 0,
      correctWagers: 0,
      totalTokensEarned: 0,
    );
  }

  test('returns top members for weekly leaderboard', () {
    final result = calculator.topMembers(
      members: [
        member(
          id: 'a',
          name: 'Alex',
          weeklyTokensEarned: 10,
          allTimeTokensEarned: 1000,
        ),
        member(
          id: 'b',
          name: 'Blake',
          weeklyTokensEarned: 40,
          allTimeTokensEarned: 100,
        ),
        member(
          id: 'c',
          name: 'Casey',
          weeklyTokensEarned: 20,
          allTimeTokensEarned: 200,
        ),
      ],
      period: LeaderboardPeriod.weekly,
      limit: 2,
    );

    expect(result.map((item) => item.userId), ['b', 'c']);
  });

  test('ignores stale weekly scores outside the active period', () {
    const staleMember = GroupMember(
      userId: 'stale',
      displayName: 'Stale',
      avatarUrl: null,
      role: GroupMemberRole.member,
      tokenBalance: 0,
      weeklyTokensEarned: 1000,
      weeklyScorePeriodId: '2026-W15',
      allTimeTokensEarned: 1000,
      xp: 0,
      totalWagers: 0,
      correctWagers: 0,
      totalTokensEarned: 0,
    );

    final result = calculator.topMembers(
      members: [
        staleMember,
        member(
          id: 'current',
          name: 'Current',
          weeklyTokensEarned: 20,
          allTimeTokensEarned: 20,
        ),
      ],
      period: LeaderboardPeriod.weekly,
      weeklyPeriodId: '2026-W16',
      limit: 1,
    );

    expect(result.single.userId, 'current');
  });

  test('returns top members for all-time leaderboard', () {
    final result = calculator.topMembers(
      members: [
        member(
          id: 'a',
          name: 'Alex',
          weeklyTokensEarned: 10,
          allTimeTokensEarned: 1000,
        ),
        member(
          id: 'b',
          name: 'Blake',
          weeklyTokensEarned: 40,
          allTimeTokensEarned: 100,
        ),
        member(
          id: 'c',
          name: 'Casey',
          weeklyTokensEarned: 20,
          allTimeTokensEarned: 200,
        ),
      ],
      period: LeaderboardPeriod.allTime,
      limit: 2,
    );

    expect(result.map((item) => item.userId), ['a', 'c']);
  });
}
