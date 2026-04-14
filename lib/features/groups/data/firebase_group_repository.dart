import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/groups/data/mappers/group_mapper.dart';
import 'package:point_rivals/features/groups/data/mappers/group_member_mapper.dart';
import 'package:point_rivals/features/groups/domain/group_accent_colors.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

class FirebaseGroupRepository implements GroupRepository {
  FirebaseGroupRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  static const int _myGroupsLimit = 60;
  static const int _membersLimit = 200;

  @override
  Stream<List<RivalGroup>> watchMyGroups(String userId) {
    return _firestore
        .collectionGroup(FirestoreCollections.members)
        .where('userId', isEqualTo: userId)
        .limit(_myGroupsLimit)
        .snapshots()
        .asyncMap((membershipSnapshot) async {
          final groups = <RivalGroup>[];

          for (final membership in membershipSnapshot.docs) {
            final groupReference = membership.reference.parent.parent;
            if (groupReference == null) {
              continue;
            }

            final groupSnapshot = await groupReference.get();
            final groupData = groupSnapshot.data();
            if (groupData == null) {
              continue;
            }

            groups.add(
              GroupMapper.fromFirestore(
                id: groupSnapshot.id,
                data: groupData,
                myTokenBalance: _int(membership.data()['tokenBalance']),
              ),
            );
          }

          return groups;
        });
  }

  @override
  Stream<RivalGroup> watchGroup(String groupId, {required String userId}) {
    final groupReference = _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId);
    final memberReference = groupReference
        .collection(FirestoreCollections.members)
        .doc(userId);

    return groupReference.snapshots().asyncMap((groupSnapshot) async {
      final groupData = groupSnapshot.data();
      if (groupData == null) {
        throw StateError('Group was not found.');
      }

      final memberSnapshot = await memberReference.get();
      return GroupMapper.fromFirestore(
        id: groupSnapshot.id,
        data: groupData,
        myTokenBalance: _int(memberSnapshot.data()?['tokenBalance']),
      );
    });
  }

  @override
  Stream<List<GroupMember>> watchMembers(String groupId) {
    return _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .collection(FirestoreCollections.members)
        .limit(_membersLimit)
        .snapshots()
        .map((snapshot) {
          final members = snapshot.docs.map((document) {
            return GroupMemberMapper.fromFirestore(
              userId: document.id,
              data: document.data(),
            );
          }).toList();

          members.sort((left, right) {
            return right.tokenBalance.compareTo(left.tokenBalance);
          });

          return members;
        });
  }

  @override
  Future<RivalGroup> createGroup({
    required String name,
    required UserProfile owner,
  }) async {
    final inviteCode = _inviteCodeFromName(name);
    final groupReference = _firestore
        .collection(FirestoreCollections.groups)
        .doc();

    await _firestore.runTransaction((transaction) async {
      transaction.set(
        groupReference,
        GroupMapper.createFirestoreData(
          name: name,
          inviteCode: inviteCode,
          ownerUserId: owner.id,
        ),
      );
      transaction.set(
        groupReference.collection(FirestoreCollections.members).doc(owner.id),
        {
          'userId': owner.id,
          ...GroupMemberMapper.createFirestoreData(
            displayName: owner.displayName,
            avatarUrl: owner.avatarUrl,
            role: GroupMemberRole.admin,
            xp: owner.xp,
          ),
        },
      );
    });

    final snapshot = await groupReference.get();
    return GroupMapper.fromFirestore(
      id: snapshot.id,
      data: snapshot.data() ?? const {},
      myTokenBalance: 0,
    );
  }

  @override
  Future<RivalGroup> previewGroupByInviteCode(String inviteCode) async {
    final result = await _functions
        .httpsCallable('previewGroupByInviteCode')
        .call<Map<Object?, Object?>>({
          'inviteCode': _normalizeInviteCode(inviteCode),
        });

    return _groupFromCallable(result.data);
  }

  @override
  Future<void> joinGroup({
    required String groupId,
    required UserProfile user,
  }) async {
    await _functions.httpsCallable('joinGroupByInviteCode').call<void>({
      'inviteCode': _normalizeInviteCode(groupId),
    });
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await _functions.httpsCallable('leaveGroup').call<void>({
      'groupId': groupId,
    });
  }

  @override
  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    await _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .update({
          'name': name.trim(),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateGroupAccentColor({
    required String groupId,
    required int accentColorValue,
  }) async {
    await _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .update({
          'accentColor': GroupAccentColors.normalize(accentColorValue),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateGroupLeaderboardWindowWeeks({
    required String groupId,
    required int weeks,
  }) async {
    final now = DateTime.now().toUtc();
    await _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .update({
          'leaderboardWindowWeeks': weeks.clamp(1, 52),
          'leaderboardPeriodAnchorDate': Timestamp.fromDate(
            DateTime.utc(now.year, now.month, now.day),
          ),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateGroupLeaderboardPeriodAnchorDate({
    required String groupId,
    required DateTime anchorDate,
  }) async {
    await _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .update({
          'leaderboardPeriodAnchorDate': Timestamp.fromDate(
            DateTime.utc(anchorDate.year, anchorDate.month, anchorDate.day),
          ),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupMemberRole role,
  }) async {
    await _functions.httpsCallable('manageGroupMember').call<void>({
      'groupId': groupId,
      'targetUserId': userId,
      'action': role == GroupMemberRole.admin ? 'promote' : 'demote',
    });
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    await _functions.httpsCallable('manageGroupMember').call<void>({
      'groupId': groupId,
      'targetUserId': userId,
      'action': 'remove',
    });
  }

  static int _int(Object? value) => value is int ? value : 0;

  static String _normalizeInviteCode(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    final queryCode = uri?.queryParameters['code'];
    if (queryCode != null && queryCode.trim().isNotEmpty) {
      return queryCode.trim().toUpperCase();
    }

    final codeMatch = RegExp(
      r'(?:code|invite|код)[^A-Za-z0-9]*([A-Za-z0-9]{4,24})',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (codeMatch != null) {
      return codeMatch.group(1)!.toUpperCase();
    }

    return trimmed.toUpperCase();
  }

  static RivalGroup _groupFromCallable(Map<Object?, Object?> data) {
    return GroupMapper.fromFirestore(
      id: data['id'] as String? ?? '',
      data: {
        'name': data['name'],
        'inviteCode': data['inviteCode'],
        'memberCount': data['memberCount'],
        'activeWagerCount': data['activeWagerCount'],
        'leaderboardWindowWeeks': data['leaderboardWindowWeeks'],
        'leaderboardPeriodAnchorDate': data['leaderboardPeriodAnchorDate'],
        'accentColor': data['accentColor'],
      },
      myTokenBalance: _int(data['myTokenBalance']),
    );
  }

  static String _inviteCodeFromName(String name) {
    final normalized = name
        .replaceAll(RegExp('[^A-Za-z0-9]'), '')
        .toUpperCase()
        .padRight(4, 'X');
    final prefix = normalized.substring(0, 4);
    final suffix = DateTime.now().millisecondsSinceEpoch
        .remainder(10000)
        .toString()
        .padLeft(4, '0');

    return '$prefix$suffix';
  }
}
