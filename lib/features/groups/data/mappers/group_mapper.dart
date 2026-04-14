import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';

abstract final class GroupMapper {
  static RivalGroup fromFirestore({
    required String id,
    required Map<String, Object?> data,
    required int myTokenBalance,
  }) {
    return RivalGroup(
      id: id,
      name: _string(data['name']) ?? '',
      inviteCode: _string(data['inviteCode']) ?? '',
      memberCount: _int(data['memberCount']),
      activeWagerCount: _int(data['activeWagerCount']),
      myTokenBalance: myTokenBalance,
      leaderboardWindowWeeks: _positiveInt(data['leaderboardWindowWeeks'], 1),
    );
  }

  static Map<String, Object?> createFirestoreData({
    required String name,
    required String inviteCode,
    required String ownerUserId,
  }) {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'ownerUserId': ownerUserId,
      'memberCount': 1,
      'activeWagerCount': 0,
      'leaderboardWindowWeeks': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String? _string(Object? value) => value is String ? value : null;

  static int _int(Object? value) => value is int ? value : 0;

  static int _positiveInt(Object? value, int fallback) {
    return value is int && value > 0 ? value : fallback;
  }
}
