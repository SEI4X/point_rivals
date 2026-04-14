import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/wagers/domain/odds_calculator.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

void main() {
  const calculator = OddsCalculator();

  Wager wagerWithStakes(List<Stake> stakes) {
    return Wager(
      id: 'wager-1',
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      condition: 'condition',
      type: WagerType.yesNo,
      leftOption: const WagerOption(side: WagerSide.left, label: 'left'),
      rightOption: const WagerOption(side: WagerSide.right, label: 'right'),
      excludedUserIds: const {},
      stakes: stakes,
      status: WagerStatus.active,
      winningSide: null,
      settlement: null,
      createdAt: null,
      resolvedAt: null,
      updatedAt: null,
    );
  }

  test('calculates odds from pool divided by selected side total', () {
    final wager = wagerWithStakes(const [
      Stake(userId: 'a', side: WagerSide.left, amount: 100),
      Stake(userId: 'b', side: WagerSide.right, amount: 300),
    ]);

    expect(calculator.oddsForSide(wager, WagerSide.left), 2.4);
    expect(
      calculator.oddsForSide(wager, WagerSide.right),
      closeTo(1.714, 0.001),
    );
  });

  test('keeps first stake rewarding with fair opening odds', () {
    final wager = wagerWithStakes(const []);

    expect(calculator.oddsForSide(wager, WagerSide.left), 2);
    expect(calculator.oddsForSide(wager, WagerSide.right), 2);
  });

  test('keeps an empty side bounded by virtual liquidity', () {
    final wager = wagerWithStakes(const [
      Stake(userId: 'a', side: WagerSide.left, amount: 100),
    ]);

    expect(calculator.oddsForSide(wager, WagerSide.right), 3);
  });

  test('reduces the crowded side when only one side has stakes', () {
    final wager = wagerWithStakes(const [
      Stake(userId: 'a', side: WagerSide.left, amount: 100),
    ]);

    expect(calculator.oddsForSide(wager, WagerSide.left), 1.5);
  });

  test('does not explode when one side is heavily staked', () {
    final wager = wagerWithStakes(const [
      Stake(userId: 'a', side: WagerSide.left, amount: 200),
    ]);

    expect(calculator.oddsForSide(wager, WagerSide.right), 3);
  });

  test('calculates payout from winning stake and odds', () {
    const stake = Stake(userId: 'a', side: WagerSide.left, amount: 100);
    final wager = wagerWithStakes(const [
      stake,
      Stake(userId: 'b', side: WagerSide.right, amount: 300),
    ]);

    expect(calculator.payoutForStake(wager: wager, winningStake: stake), 240);
  });

  test('uses locked stake odds for payout when present', () {
    const stake = Stake(
      userId: 'a',
      side: WagerSide.left,
      amount: 100,
      odds: 2,
    );
    final wager = wagerWithStakes(const [stake]);

    expect(calculator.payoutForStake(wager: wager, winningStake: stake), 200);
  });
}
