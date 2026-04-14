import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/groups/domain/leaderboard_period_id.dart';

void main() {
  test('uses ISO weeks that start on Monday', () {
    expect(
      currentLeaderboardPeriodId(
        windowWeeks: 1,
        now: DateTime.utc(2026, 4, 13),
      ),
      '2026-W16',
    );
    expect(
      currentLeaderboardPeriodId(
        windowWeeks: 1,
        now: DateTime.utc(2026, 4, 19),
      ),
      '2026-W16',
    );
    expect(
      currentLeaderboardPeriodId(
        windowWeeks: 1,
        now: DateTime.utc(2026, 4, 20),
      ),
      '2026-W17',
    );
  });

  test('uses configured multi-week windows', () {
    expect(
      currentLeaderboardPeriodId(
        windowWeeks: 2,
        now: DateTime.utc(2026, 4, 14),
      ),
      '2026-W08x2',
    );
  });

  test('uses sprint windows from an anchor date', () {
    final anchorDate = DateTime.utc(2026, 4, 13);

    expect(
      currentLeaderboardPeriodId(
        windowWeeks: 2,
        anchorDate: anchorDate,
        now: DateTime.utc(2026, 4, 14),
      ),
      '20260413-S001x2',
    );
    expect(
      currentLeaderboardPeriodId(
        windowWeeks: 2,
        anchorDate: anchorDate,
        now: DateTime.utc(2026, 4, 27),
      ),
      '20260427-S002x2',
    );
  });
}
