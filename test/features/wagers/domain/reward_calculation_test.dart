import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

void main() {
  Wager wagerWithPicks(List<Stake> picks, {int rewardCoins = 10}) {
    return Wager(
      id: 'wager-1',
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      condition: 'condition',
      type: WagerType.yesNo,
      leftOption: const WagerOption(side: WagerSide.left, label: 'left'),
      rightOption: const WagerOption(side: WagerSide.right, label: 'right'),
      rewardCoins: rewardCoins,
      excludedUserIds: const {},
      stakes: picks,
      status: WagerStatus.active,
      winningSide: null,
      settlement: null,
      createdAt: null,
      resolvedAt: null,
      updatedAt: null,
    );
  }

  test('returns the base reward for a popular or tied side', () {
    final wager = wagerWithPicks(const [
      Stake(userId: 'a', side: WagerSide.left),
      Stake(userId: 'b', side: WagerSide.right),
    ]);

    expect(wager.rewardForSide(WagerSide.left), 10);
    expect(wager.rewardForSide(WagerSide.right), 10);
  });

  test('adds a 1.5x reward for an unpopular correct side', () {
    final wager = wagerWithPicks(const [
      Stake(userId: 'a', side: WagerSide.left),
      Stake(userId: 'b', side: WagerSide.left),
      Stake(userId: 'c', side: WagerSide.right),
    ]);

    expect(wager.rewardForSide(WagerSide.left), 10);
    expect(wager.rewardForSide(WagerSide.right), 15);
  });

  test('uses the configured reward amount', () {
    final wager = wagerWithPicks(const [
      Stake(userId: 'a', side: WagerSide.left),
      Stake(userId: 'b', side: WagerSide.left),
      Stake(userId: 'c', side: WagerSide.right),
    ], rewardCoins: 20);

    expect(wager.rewardForSide(WagerSide.right), 30);
  });
}
