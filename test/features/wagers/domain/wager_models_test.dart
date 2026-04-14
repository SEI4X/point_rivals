import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

void main() {
  test('converts wager draft to active wager with empty stakes', () {
    final draft = WagerDraft(
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      condition: 'Who wins?',
      type: WagerType.yesNo,
      leftOption: const WagerOption(side: WagerSide.left, label: 'Yes'),
      rightOption: const WagerOption(side: WagerSide.right, label: 'No'),
      excludedUserIds: {'participant-1'},
    );

    final wager = draft.toWager(id: 'wager-1');

    expect(wager.id, 'wager-1');
    expect(wager.groupId, 'group-1');
    expect(wager.creatorUserId, 'creator-1');
    expect(wager.status, WagerStatus.active);
    expect(wager.stakes, isEmpty);
    expect(wager.canUserStake('participant-1'), isFalse);
    expect(wager.canUserStake('viewer-1'), isTrue);
  });

  test('prevents a user from staking twice', () {
    const wager = Wager(
      id: 'wager-1',
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      condition: 'Who wins?',
      type: WagerType.yesNo,
      leftOption: WagerOption(side: WagerSide.left, label: 'Yes'),
      rightOption: WagerOption(side: WagerSide.right, label: 'No'),
      rewardCoins: 10,
      excludedUserIds: {},
      stakes: [Stake(userId: 'user-1', side: WagerSide.left, amount: 100)],
      status: WagerStatus.active,
      winningSide: null,
      settlement: null,
      createdAt: null,
      resolvedAt: null,
      updatedAt: null,
    );

    expect(wager.hasStakeFrom('user-1'), isTrue);
    expect(wager.canUserStake('user-1'), isFalse);
    expect(wager.canUserStake('user-2'), isTrue);
  });
}
