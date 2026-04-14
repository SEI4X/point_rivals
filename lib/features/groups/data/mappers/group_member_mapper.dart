import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';

abstract final class GroupMemberMapper {
  static GroupMember fromFirestore({
    required String userId,
    required Map<String, Object?> data,
  }) {
    return GroupMember(
      userId: userId,
      displayName: _string(data['displayName']) ?? '',
      avatarUrl: _string(data['avatarUrl']),
      role: _role(data['role']),
      tokenBalance: _int(data['tokenBalance']),
      weeklyTokensEarned: _int(data['weeklyTokensEarned']),
      weeklyScorePeriodId: _string(data['weeklyScorePeriodId']) ?? '',
      allTimeTokensEarned: _int(data['allTimeTokensEarned']),
      xp: _int(data['xp']),
      totalWagers: _int(data['totalWagers']),
      correctWagers: _int(data['correctWagers']),
      totalTokensEarned: _int(data['totalTokensEarned']),
    );
  }

  static Map<String, Object?> createFirestoreData({
    required String displayName,
    required String? avatarUrl,
    required GroupMemberRole role,
    int initialTokenBalance = 0,
    int xp = 0,
  }) {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'tokenBalance': initialTokenBalance,
      'weeklyTokensEarned': 0,
      'weeklyScorePeriodId': '',
      'allTimeTokensEarned': 0,
      'xp': xp,
      'totalWagers': 0,
      'correctWagers': 0,
      'totalTokensEarned': 0,
      'joinedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String? _string(Object? value) => value is String ? value : null;

  static int _int(Object? value) => value is int ? value : 0;

  static GroupMemberRole _role(Object? value) {
    return GroupMemberRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => GroupMemberRole.member,
    );
  }
}
