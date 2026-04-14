import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/wagers/data/mappers/wager_mapper.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

void main() {
  test('maps Firestore wager data to domain model', () {
    final wager = WagerMapper.fromFirestore(
      id: 'wager-1',
      data: const {
        'groupId': 'group-1',
        'creatorUserId': 'creator-1',
        'condition': 'Who wins?',
        'type': 'custom',
        'leftLabel': 'Alex',
        'rightLabel': 'Sam',
        'excludedUserIds': ['alex', 'sam'],
        'status': 'resolved',
        'winningSide': 'right',
        'settlement': {
          'totalPool': 400,
          'winningSideTotal': 300,
          'payouts': {'sam': 400},
        },
      },
    );

    expect(wager.id, 'wager-1');
    expect(wager.groupId, 'group-1');
    expect(wager.creatorUserId, 'creator-1');
    expect(wager.type, WagerType.custom);
    expect(wager.leftOption.label, 'Alex');
    expect(wager.excludedUserIds, {'alex', 'sam'});
    expect(wager.status, WagerStatus.resolved);
    expect(wager.winningSide, WagerSide.right);
    expect(wager.settlement?.totalPool, 400);
    expect(wager.settlement?.payoutFor('sam'), 400);
  });
}
