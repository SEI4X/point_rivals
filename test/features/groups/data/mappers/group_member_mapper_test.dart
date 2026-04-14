import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/groups/data/mappers/group_member_mapper.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';

void main() {
  test('maps Firestore member data to domain model', () {
    final member = GroupMemberMapper.fromFirestore(
      userId: 'user-1',
      data: const {
        'displayName': 'Alex',
        'avatarUrl': 'https://example.com/avatar.png',
        'role': 'admin',
        'tokenBalance': 920,
        'weeklyTokensEarned': 140,
        'weeklyScorePeriodId': '2026-W16',
        'allTimeTokensEarned': 2100,
        'xp': 450,
        'totalWagers': 12,
        'correctWagers': 8,
        'totalTokensEarned': 700,
      },
    );

    expect(member.userId, 'user-1');
    expect(member.displayName, 'Alex');
    expect(member.avatarUrl, 'https://example.com/avatar.png');
    expect(member.role, GroupMemberRole.admin);
    expect(member.tokenBalance, 920);
    expect(member.weeklyTokensEarned, 140);
    expect(member.weeklyScorePeriodId, '2026-W16');
    expect(member.allTimeTokensEarned, 2100);
    expect(member.xp, 450);
    expect(member.totalWagers, 12);
    expect(member.correctWagers, 8);
    expect(member.totalTokensEarned, 700);
  });
}
