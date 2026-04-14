import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/groups/data/mappers/group_mapper.dart';

void main() {
  test('maps Firestore group data to domain model', () {
    final group = GroupMapper.fromFirestore(
      id: 'group-1',
      data: const {
        'name': 'Morning rivals',
        'inviteCode': 'MORN1234',
        'memberCount': 8,
        'activeWagerCount': 3,
        'accentColor': 0xFFFF3B64,
      },
      myTokenBalance: 1240,
    );

    expect(group.id, 'group-1');
    expect(group.name, 'Morning rivals');
    expect(group.inviteCode, 'MORN1234');
    expect(group.memberCount, 8);
    expect(group.activeWagerCount, 3);
    expect(group.myTokenBalance, 1240);
    expect(group.accentColorValue, 0xFFFF3B64);
  });

  test('falls back to the default group accent color', () {
    final group = GroupMapper.fromFirestore(
      id: 'group-1',
      data: const {'name': 'Morning rivals'},
      myTokenBalance: 0,
    );

    expect(group.accentColorValue, 0xFFFFD426);
  });

  test('ignores legacy anchor dates unless custom anchors are enabled', () {
    final legacyAnchor = Timestamp.fromDate(DateTime.utc(2026, 4, 7));
    final group = GroupMapper.fromFirestore(
      id: 'group-1',
      data: {
        'name': 'Morning rivals',
        'leaderboardWindowWeeks': 2,
        'leaderboardPeriodAnchorDate': legacyAnchor,
      },
      myTokenBalance: 0,
    );

    expect(group.leaderboardPeriodAnchorDate, isNull);
  });

  test('keeps explicit custom anchor dates', () {
    final anchor = Timestamp.fromDate(DateTime.utc(2026, 4, 13, 18));
    final group = GroupMapper.fromFirestore(
      id: 'group-1',
      data: {
        'name': 'Morning rivals',
        'leaderboardWindowWeeks': 2,
        'leaderboardPeriodAnchorDate': anchor,
        'leaderboardUsesCustomAnchor': true,
      },
      myTokenBalance: 0,
    );

    expect(group.leaderboardPeriodAnchorDate, DateTime.utc(2026, 4, 13));
  });
}
