import 'dart:typed_data';

import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

abstract interface class AuthRepository {
  Stream<UserProfile?> authStateChanges();

  Future<UserProfile> signInWithApple();

  Future<UserProfile> signInWithGoogle();

  Future<void> signOut();

  Future<void> softDeleteAccount();

  Future<void> updateProfile({
    required String displayName,
    required String? avatarUrl,
  });
}

abstract interface class GroupRepository {
  Stream<List<RivalGroup>> watchMyGroups(String userId);

  Stream<RivalGroup> watchGroup(String groupId, {required String userId});

  Stream<List<GroupMember>> watchMembers(String groupId);

  Future<RivalGroup> createGroup({
    required String name,
    required UserProfile owner,
  });

  Future<RivalGroup> previewGroupByInviteCode(String inviteCode);

  Future<void> joinGroup({required String groupId, required UserProfile user});

  Future<void> leaveGroup(String groupId);

  Future<void> updateGroupName({required String groupId, required String name});

  Future<void> updateGroupAccentColor({
    required String groupId,
    required int accentColorValue,
  });

  Future<void> updateGroupLeaderboardWindowWeeks({
    required String groupId,
    required int weeks,
  });

  Future<void> updateGroupLeaderboardPeriodAnchorDate({
    required String groupId,
    required DateTime anchorDate,
  });

  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupMemberRole role,
  });

  Future<void> removeMember({required String groupId, required String userId});
}

abstract interface class WagerRepository {
  Stream<Wager> watchWager({required String groupId, required String wagerId});

  Stream<List<Wager>> watchGroupWagers(String groupId);

  Stream<List<Wager>> watchActiveWagers(String groupId);

  Stream<List<Wager>> watchResolvedWagers(String groupId);

  Stream<List<Wager>> watchArchivedWagers(String groupId);

  Stream<List<Wager>> watchUserWagers(String userId);

  Future<Wager> createWager(WagerDraft draft);

  Future<void> placeStake({
    required String groupId,
    required String wagerId,
    required Stake stake,
  });

  Future<void> resolveWager({
    required String groupId,
    required String wagerId,
    required WagerSide winningSide,
    required String adminUserId,
  });

  Future<void> cancelWager({
    required String groupId,
    required String wagerId,
    required String adminUserId,
  });
}

abstract interface class NotificationRepository {
  Future<bool> requestPermission();

  Future<void> registerDeviceToken(String userId);

  Future<void> unregisterDeviceToken(String userId);

  Future<String?> initialNotificationGroupId();

  Stream<String> notificationGroupOpenRequests();

  Stream<IncomingNotification> foregroundNotifications();

  Future<void> setNotificationsEnabled({
    required String userId,
    required bool enabled,
  });
}

final class IncomingNotification {
  const IncomingNotification({
    required this.groupId,
    required this.title,
    required this.body,
  });

  final String? groupId;
  final String title;
  final String body;
}

abstract interface class ActivityRepository {
  Stream<List<ActivityItem>> watchUserActivities(String userId);
}

abstract interface class PublicProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);
}

abstract interface class AchievementRepository {
  Stream<Set<AchievementId>> watchEarnedAchievements(String userId);

  Future<List<AchievementId>> syncEarnedAchievements({
    required String userId,
    required List<AchievementCardModel> cards,
  });
}

abstract interface class ProfileMediaRepository {
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    required String? contentType,
  });
}
