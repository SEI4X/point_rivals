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
    Map<String, int> dailyTokenBuckets = const {},
    String weeklyScorePeriodId = '2026-W16',
  }) {
    return GroupMember(
      userId: id,
      displayName: name,
      avatarUrl: null,
      role: GroupMemberRole.member,
      tokenBalance: allTimeTokensEarned,
      weeklyTokensEarned: weeklyTokensEarned,
      weeklyScorePeriodId: weeklyScorePeriodId,
      dailyTokenBuckets: dailyTokenBuckets,
      allTimeTokensEarned: allTimeTokensEarned,
      xp: 0,
      totalWagers: 0,
      correctWagers: 0,
      totalTokensEarned: 0,
    );
  }

  test('returns top members for monthly leaderboard', () {
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
      period: LeaderboardPeriod.month,
      limit: 2,
    );

    expect(result.map((item) => item.userId), ['b', 'c']);
  });

  test('ignores legacy weekly scores outside the current month', () {
    const staleMember = GroupMember(
      userId: 'stale',
      displayName: 'Stale',
      avatarUrl: null,
      role: GroupMemberRole.member,
      tokenBalance: 0,
      weeklyTokensEarned: 1000,
      weeklyScorePeriodId: '2026-W15',
      dailyTokenBuckets: {},
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
      period: LeaderboardPeriod.month,
      monthPeriodId: '2026-04',
      legacyWeeklyPeriodIds: const {'2026-W16'},
      limit: 1,
    );

    expect(result.single.userId, 'current');
  });

  test('sums daily points across the current month', () {
    final result = calculator.topMembers(
      members: [
        member(
          id: 'current',
          name: 'Current',
          weeklyTokensEarned: 0,
          allTimeTokensEarned: 0,
          dailyTokenBuckets: {'20260407': 10, '20260413': 20, '20260414': 30},
        ),
        member(
          id: 'today',
          name: 'Today',
          weeklyTokensEarned: 0,
          allTimeTokensEarned: 0,
          dailyTokenBuckets: {'20260414': 40},
        ),
      ],
      period: LeaderboardPeriod.month,
      activeDateIds: const [
        '20260407',
        '20260408',
        '20260409',
        '20260410',
        '20260411',
        '20260412',
        '20260413',
        '20260414',
      ],
      limit: 1,
    );

    expect(result.single.userId, 'current');
    expect(
      calculator.scoreFor(
        result.single,
        LeaderboardPeriod.month,
        activeDateIds: const [
          '20260407',
          '20260408',
          '20260409',
          '20260410',
          '20260411',
          '20260412',
          '20260413',
          '20260414',
        ],
      ),
      60,
    );
  });

  test('uses legacy weekly points when daily buckets are incomplete', () {
    final legacy = member(
      id: 'legacy',
      name: 'Legacy',
      weeklyTokensEarned: 70,
      allTimeTokensEarned: 70,
      dailyTokenBuckets: {'20260414': 20},
    );

    expect(
      calculator.scoreFor(
        legacy,
        LeaderboardPeriod.month,
        activeDateIds: const ['20260413', '20260414'],
        legacyWeeklyPeriodIds: const {'2026-W16'},
      ),
      70,
    );
  });

  test(
    'uses reconstructed monthly points for operations before daily buckets',
    () {
      final result = calculator.topMembers(
        members: [
          member(
            id: 'old',
            name: 'Old',
            weeklyTokensEarned: 0,
            allTimeTokensEarned: 0,
          ),
          member(
            id: 'new',
            name: 'New',
            weeklyTokensEarned: 0,
            allTimeTokensEarned: 0,
            dailyTokenBuckets: {'20260414': 20},
          ),
        ],
        period: LeaderboardPeriod.month,
        activeDateIds: const ['20260414'],
        reconstructedMonthScores: const {'old': 60, 'new': 20},
      );

      expect(result.map((member) => member.userId), ['old', 'new']);
      expect(
        calculator.scoreFor(
          result.first,
          LeaderboardPeriod.month,
          activeDateIds: const ['20260414'],
          reconstructedMonthScores: const {'old': 60},
        ),
        60,
      );
    },
  );

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
