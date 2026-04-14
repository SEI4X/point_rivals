import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/groups/domain/leaderboard_period_id.dart';

void main() {
  test('uses calendar months that start on the first day', () {
    expect(currentLeaderboardMonthId(now: DateTime.utc(2026, 4)), '2026-04');
    expect(
      currentLeaderboardMonthId(now: DateTime.utc(2026, 4, 30, 23, 59)),
      '2026-04',
    );
    expect(currentLeaderboardMonthId(now: DateTime.utc(2026, 5)), '2026-05');
  });

  test('returns current month date ids through today', () {
    expect(currentMonthDateIds(now: DateTime.utc(2026, 4, 3)), [
      '20260401',
      '20260402',
      '20260403',
    ]);
  });

  test('returns current month start at midnight UTC', () {
    expect(
      currentLeaderboardMonthStart(now: DateTime.utc(2026, 4, 14, 18, 30)),
      DateTime.utc(2026, 4),
    );
  });

  test('returns active ISO weeks for legacy scores in the current month', () {
    expect(currentMonthIsoWeekPeriodIds(now: DateTime.utc(2026, 4, 15)), {
      '2026-W14',
      '2026-W15',
      '2026-W16',
    });
  });
}
