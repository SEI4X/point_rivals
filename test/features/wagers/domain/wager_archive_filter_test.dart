import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/wagers/domain/wager_archive_filter.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

void main() {
  Wager wager({
    required String id,
    required String condition,
    required WagerStatus status,
    required List<Stake> stakes,
    WagerSide? winningSide,
  }) {
    return Wager(
      id: id,
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      condition: condition,
      type: WagerType.custom,
      leftOption: const WagerOption(side: WagerSide.left, label: 'Left'),
      rightOption: const WagerOption(side: WagerSide.right, label: 'Right'),
      rewardCoins: 10,
      excludedUserIds: const {},
      stakes: stakes,
      status: status,
      winningSide: winningSide,
      settlement: null,
      createdAt: null,
      resolvedAt: null,
      updatedAt: null,
    );
  }

  Stake stake(String userId, int amount) {
    return Stake(userId: userId, side: WagerSide.left, amount: amount);
  }

  test('filters archived wagers by query and status', () {
    final result =
        const WagerArchiveFilter(
          query: 'workout',
          status: WagerArchiveStatusFilter.resolved,
        ).apply([
          wager(
            id: 'a',
            condition: 'Morning workout',
            status: WagerStatus.resolved,
            winningSide: WagerSide.left,
            stakes: [stake('a', 20)],
          ),
          wager(
            id: 'b',
            condition: 'Morning workout cancelled',
            status: WagerStatus.cancelled,
            stakes: [stake('b', 40)],
          ),
          wager(
            id: 'c',
            condition: 'Late arrival',
            status: WagerStatus.resolved,
            winningSide: WagerSide.left,
            stakes: [stake('c', 60)],
          ),
        ]);

    expect(result.map((item) => item.id), ['a']);
  });

  test('sorts archived wagers by largest pool', () {
    final result = const WagerArchiveFilter(sort: WagerArchiveSort.largestPool)
        .apply([
          wager(
            id: 'a',
            condition: 'Small',
            status: WagerStatus.resolved,
            stakes: [stake('a', 20)],
          ),
          wager(
            id: 'b',
            condition: 'Large',
            status: WagerStatus.resolved,
            stakes: [stake('b', 40), stake('c', 80)],
          ),
        ]);

    expect(result.map((item) => item.id), ['b', 'a']);
  });

  test('keeps repository order when sorting by newest', () {
    final result = const WagerArchiveFilter().apply([
      wager(
        id: 'newer',
        condition: 'Newer',
        status: WagerStatus.resolved,
        stakes: [stake('a', 20)],
      ),
      wager(
        id: 'older',
        condition: 'Older',
        status: WagerStatus.cancelled,
        stakes: [stake('b', 40)],
      ),
    ]);

    expect(result.map((item) => item.id), ['newer', 'older']);
  });
}
