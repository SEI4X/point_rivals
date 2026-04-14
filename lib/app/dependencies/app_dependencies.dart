import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firebase_notification_repository.dart';
import 'package:point_rivals/core/firebase/firebase_profile_media_repository.dart';
import 'package:point_rivals/features/achievements/data/firebase_achievement_repository.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';
import 'package:point_rivals/features/activity/data/firebase_activity_repository.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';
import 'package:point_rivals/features/auth/data/firebase_auth_repository.dart';
import 'package:point_rivals/features/groups/data/firebase_group_repository.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/data/firebase_public_profile_repository.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:point_rivals/features/wagers/data/firebase_wager_repository.dart';
import 'package:point_rivals/features/wagers/domain/odds_calculator.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

final class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.groupRepository,
    required this.wagerRepository,
    required this.notificationRepository,
    required this.profileMediaRepository,
    required this.activityRepository,
    required this.publicProfileRepository,
    required this.achievementRepository,
  });

  factory AppDependencies.firebase() {
    return AppDependencies(
      authRepository: FirebaseAuthRepository(),
      groupRepository: FirebaseGroupRepository(),
      wagerRepository: FirebaseWagerRepository(),
      notificationRepository: FirebaseNotificationRepository(),
      profileMediaRepository: FirebaseProfileMediaRepository(),
      activityRepository: FirebaseActivityRepository(),
      publicProfileRepository: FirebasePublicProfileRepository(),
      achievementRepository: FirebaseAchievementRepository(),
    );
  }

  factory AppDependencies.memory() {
    return AppDependencies(
      authRepository: MemoryAuthRepository(),
      groupRepository: MemoryGroupRepository(),
      wagerRepository: MemoryWagerRepository(),
      notificationRepository: MemoryNotificationRepository(),
      profileMediaRepository: MemoryProfileMediaRepository(),
      activityRepository: MemoryActivityRepository(),
      publicProfileRepository: MemoryPublicProfileRepository(),
      achievementRepository: MemoryAchievementRepository(),
    );
  }

  final AuthRepository authRepository;
  final GroupRepository groupRepository;
  final WagerRepository wagerRepository;
  final NotificationRepository notificationRepository;
  final ProfileMediaRepository profileMediaRepository;
  final ActivityRepository activityRepository;
  final PublicProfileRepository publicProfileRepository;
  final AchievementRepository achievementRepository;
}

class AppDependenciesScope extends InheritedWidget {
  const AppDependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    assert(scope != null, 'AppDependenciesScope is missing.');

    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppDependenciesScope oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}

class MemoryAuthRepository implements AuthRepository {
  MemoryAuthRepository({UserProfile? initialProfile})
    : _profile = initialProfile;

  final StreamController<UserProfile?> _controller =
      StreamController<UserProfile?>.broadcast();
  UserProfile? _profile;

  @override
  Stream<UserProfile?> authStateChanges() async* {
    yield _profile;
    yield* _controller.stream;
  }

  @override
  Future<UserProfile> signInWithApple() async {
    return _signIn();
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    return _signIn();
  }

  @override
  Future<void> signOut() async {
    _profile = null;
    _controller.add(null);
  }

  @override
  Future<void> softDeleteAccount() async {
    _profile = null;
    _controller.add(null);
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String? avatarUrl,
  }) async {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    _profile = UserProfile(
      id: profile.id,
      displayName: displayName.trim(),
      avatarUrl: avatarUrl,
      isActive: profile.isActive,
      xp: profile.xp,
      totalWagers: profile.totalWagers,
      correctWagers: profile.correctWagers,
      totalTokensEarned: profile.totalTokensEarned,
      notificationsEnabled: profile.notificationsEnabled,
      themePreference: profile.themePreference,
    );
    _controller.add(_profile);
  }

  UserProfile _signIn() {
    _profile = const UserProfile(
      id: 'memory-user',
      displayName: 'Alex',
      avatarUrl: null,
      isActive: true,
      xp: 0,
      totalWagers: 0,
      correctWagers: 0,
      totalTokensEarned: 0,
      notificationsEnabled: false,
      themePreference: AppThemePreference.system,
    );

    _controller.add(_profile);
    return _profile!;
  }
}

class MemoryGroupRepository implements GroupRepository {
  MemoryGroupRepository({List<RivalGroup> initialGroups = const []})
    : _groups = [...initialGroups];

  final List<RivalGroup> _groups;
  final StreamController<List<RivalGroup>> _groupsController =
      StreamController<List<RivalGroup>>.broadcast();

  @override
  Future<RivalGroup> createGroup({
    required String name,
    required UserProfile owner,
  }) async {
    final group = RivalGroup(
      id: 'memory-group-${_groups.length + 1}',
      name: name,
      inviteCode: 'MEMORY',
      memberCount: 1,
      activeWagerCount: 0,
      myTokenBalance: 1000,
      leaderboardWindowWeeks: 1,
    );
    _groups.add(group);
    _groupsController.add(List.unmodifiable(_groups));

    return group;
  }

  @override
  Future<void> joinGroup({
    required String groupId,
    required UserProfile user,
  }) async {
    if (_groups.any((group) => group.id == groupId)) {
      return;
    }

    final group = RivalGroup(
      id: groupId,
      name: 'Memory group',
      inviteCode: 'MEMORY',
      memberCount: 1,
      activeWagerCount: 0,
      myTokenBalance: 1000,
      leaderboardWindowWeeks: 1,
    );
    _groups.add(group);
    _groupsController.add(List.unmodifiable(_groups));
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    _groups.removeWhere((group) => group.id == groupId);
    _groupsController.add(List.unmodifiable(_groups));
  }

  @override
  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index < 0) {
      return;
    }

    final group = _groups[index];
    _groups[index] = RivalGroup(
      id: group.id,
      name: name.trim(),
      inviteCode: group.inviteCode,
      memberCount: group.memberCount,
      activeWagerCount: group.activeWagerCount,
      myTokenBalance: group.myTokenBalance,
      leaderboardWindowWeeks: group.leaderboardWindowWeeks,
    );
    _groupsController.add(List.unmodifiable(_groups));
  }

  @override
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupMemberRole role,
  }) async {}

  @override
  Future<void> updateGroupLeaderboardWindowWeeks({
    required String groupId,
    required int weeks,
  }) async {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index < 0) {
      return;
    }

    final group = _groups[index];
    _groups[index] = RivalGroup(
      id: group.id,
      name: group.name,
      inviteCode: group.inviteCode,
      memberCount: group.memberCount,
      activeWagerCount: group.activeWagerCount,
      myTokenBalance: group.myTokenBalance,
      leaderboardWindowWeeks: weeks,
    );
    _groupsController.add(List.unmodifiable(_groups));
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {}

  @override
  Future<RivalGroup> previewGroupByInviteCode(String inviteCode) async {
    return RivalGroup(
      id: 'memory-group',
      name: 'Memory group',
      inviteCode: inviteCode,
      memberCount: 1,
      activeWagerCount: 0,
      myTokenBalance: 0,
      leaderboardWindowWeeks: 1,
    );
  }

  @override
  Stream<List<RivalGroup>> watchMyGroups(String userId) async* {
    yield List.unmodifiable(_groups);
    yield* _groupsController.stream;
  }

  @override
  Stream<RivalGroup> watchGroup(
    String groupId, {
    required String userId,
  }) async* {
    final group = _groups.firstWhere(
      (item) => item.id == groupId,
      orElse: () => RivalGroup(
        id: groupId,
        name: 'Memory group',
        inviteCode: 'MEMORY',
        memberCount: 1,
        activeWagerCount: 0,
        myTokenBalance: 1000,
        leaderboardWindowWeeks: 1,
      ),
    );

    yield group;
  }

  @override
  Stream<List<GroupMember>> watchMembers(String groupId) async* {
    yield const [
      GroupMember(
        userId: 'memory-user',
        displayName: 'Alex',
        avatarUrl: null,
        role: GroupMemberRole.admin,
        tokenBalance: 1000,
        weeklyTokensEarned: 120,
        weeklyScorePeriodId: 'memory-week',
        allTimeTokensEarned: 1000,
        xp: 0,
        totalWagers: 0,
        correctWagers: 0,
        totalTokensEarned: 0,
      ),
    ];
  }
}

class MemoryWagerRepository implements WagerRepository {
  final List<Wager> _wagers = [];
  final StreamController<List<Wager>> _wagersController =
      StreamController<List<Wager>>.broadcast();

  @override
  Stream<Wager> watchWager({
    required String groupId,
    required String wagerId,
  }) async* {
    Wager wagerById(List<Wager> wagers) {
      return wagers.firstWhere(
        (wager) => wager.groupId == groupId && wager.id == wagerId,
      );
    }

    yield wagerById(_wagers);
    yield* _wagersController.stream.map(wagerById);
  }

  @override
  Stream<List<Wager>> watchGroupWagers(String groupId) async* {
    List<Wager> groupWagers(List<Wager> wagers) {
      return wagers.where((wager) => wager.groupId == groupId).toList();
    }

    yield groupWagers(_wagers);
    yield* _wagersController.stream.map(groupWagers);
  }

  @override
  Future<Wager> createWager(WagerDraft draft) async {
    final wager = draft.toWager(id: 'memory-wager-${_wagers.length + 1}');
    _wagers.add(wager);
    _wagersController.add(List.unmodifiable(_wagers));

    return wager;
  }

  @override
  Future<void> placeStake({
    required String groupId,
    required String wagerId,
    required Stake stake,
  }) async {
    final index = _wagers.indexWhere((wager) => wager.id == wagerId);
    if (index == -1) {
      throw StateError('Wager was not found.');
    }

    final wager = _wagers[index];
    if (!wager.canUserStake(stake.userId)) {
      throw StateError('User cannot stake on this wager.');
    }

    final odds = const OddsCalculator().oddsForSide(wager, stake.side);
    final quotedStake = Stake(
      userId: stake.userId,
      side: stake.side,
      amount: stake.amount,
      odds: odds,
    );

    _wagers[index] = Wager(
      id: wager.id,
      groupId: wager.groupId,
      creatorUserId: wager.creatorUserId,
      condition: wager.condition,
      type: wager.type,
      leftOption: wager.leftOption,
      rightOption: wager.rightOption,
      excludedUserIds: wager.excludedUserIds,
      stakes: [...wager.stakes, quotedStake],
      status: wager.status,
      winningSide: wager.winningSide,
      settlement: wager.settlement,
      createdAt: wager.createdAt,
      resolvedAt: wager.resolvedAt,
      updatedAt: DateTime.now(),
    );
    _wagersController.add(List.unmodifiable(_wagers));
  }

  @override
  Future<void> resolveWager({
    required String groupId,
    required String wagerId,
    required WagerSide winningSide,
    required String adminUserId,
  }) async {
    final index = _wagers.indexWhere((wager) => wager.id == wagerId);
    if (index == -1) {
      throw StateError('Wager was not found.');
    }

    final wager = _wagers[index];
    _wagers[index] = Wager(
      id: wager.id,
      groupId: wager.groupId,
      creatorUserId: wager.creatorUserId,
      condition: wager.condition,
      type: wager.type,
      leftOption: wager.leftOption,
      rightOption: wager.rightOption,
      excludedUserIds: wager.excludedUserIds,
      stakes: wager.stakes,
      status: WagerStatus.resolved,
      winningSide: winningSide,
      settlement: WagerSettlement(
        totalPool: wager.totalPool,
        winningSideTotal: wager.totalForSide(winningSide),
        payouts: {
          for (final stake in wager.stakes)
            stake.userId: stake.side == winningSide ? stake.amount * 2 : 0,
        },
      ),
      createdAt: wager.createdAt,
      resolvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _wagersController.add(List.unmodifiable(_wagers));
  }

  @override
  Future<void> cancelWager({
    required String groupId,
    required String wagerId,
    required String adminUserId,
  }) async {
    final index = _wagers.indexWhere((wager) => wager.id == wagerId);
    if (index == -1) {
      throw StateError('Wager was not found.');
    }

    final wager = _wagers[index];
    _wagers[index] = Wager(
      id: wager.id,
      groupId: wager.groupId,
      creatorUserId: wager.creatorUserId,
      condition: wager.condition,
      type: wager.type,
      leftOption: wager.leftOption,
      rightOption: wager.rightOption,
      excludedUserIds: wager.excludedUserIds,
      stakes: wager.stakes,
      status: WagerStatus.cancelled,
      winningSide: null,
      settlement: WagerSettlement(
        totalPool: wager.totalPool,
        winningSideTotal: 0,
        payouts: {for (final stake in wager.stakes) stake.userId: stake.amount},
      ),
      createdAt: wager.createdAt,
      resolvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _wagersController.add(List.unmodifiable(_wagers));
  }

  @override
  Stream<List<Wager>> watchActiveWagers(String groupId) async* {
    List<Wager> activeWagers(List<Wager> wagers) {
      return wagers
          .where(
            (wager) =>
                wager.groupId == groupId && wager.status == WagerStatus.active,
          )
          .toList();
    }

    yield activeWagers(_wagers);
    yield* _wagersController.stream.map(activeWagers);
  }

  @override
  Stream<List<Wager>> watchResolvedWagers(String groupId) async* {
    List<Wager> resolvedWagers(List<Wager> wagers) {
      return wagers
          .where(
            (wager) =>
                wager.groupId == groupId &&
                wager.status == WagerStatus.resolved,
          )
          .toList();
    }

    yield resolvedWagers(_wagers);
    yield* _wagersController.stream.map(resolvedWagers);
  }

  @override
  Stream<List<Wager>> watchArchivedWagers(String groupId) async* {
    List<Wager> archivedWagers(List<Wager> wagers) {
      return wagers
          .where(
            (wager) =>
                wager.groupId == groupId &&
                (wager.status == WagerStatus.resolved ||
                    wager.status == WagerStatus.cancelled),
          )
          .toList();
    }

    yield archivedWagers(_wagers);
    yield* _wagersController.stream.map(archivedWagers);
  }

  @override
  Stream<List<Wager>> watchUserWagers(String userId) async* {
    List<Wager> userWagers(List<Wager> wagers) {
      return wagers.where((wager) => wager.hasStakeFrom(userId)).toList();
    }

    yield userWagers(_wagers);
    yield* _wagersController.stream.map(userWagers);
  }
}

class MemoryNotificationRepository implements NotificationRepository {
  @override
  Future<void> registerDeviceToken(String userId) async {}

  @override
  Future<void> unregisterDeviceToken(String userId) async {}

  @override
  Future<String?> initialNotificationGroupId() async {
    return null;
  }

  @override
  Stream<String> notificationGroupOpenRequests() {
    return const Stream.empty();
  }

  @override
  Future<bool> requestPermission() async {
    return true;
  }

  @override
  Future<void> setNotificationsEnabled({
    required String userId,
    required bool enabled,
  }) async {}
}

class MemoryActivityRepository implements ActivityRepository {
  @override
  Stream<List<ActivityItem>> watchUserActivities(String userId) async* {
    yield const [];
  }
}

class MemoryPublicProfileRepository implements PublicProfileRepository {
  MemoryPublicProfileRepository([Map<String, UserProfile>? profiles])
    : _profiles = profiles ?? const {};

  final Map<String, UserProfile> _profiles;

  @override
  Stream<UserProfile?> watchProfile(String userId) async* {
    yield _profiles[userId];
  }
}

class MemoryAchievementRepository implements AchievementRepository {
  final Set<AchievementId> _earnedIds = {};
  final StreamController<Set<AchievementId>> _controller =
      StreamController<Set<AchievementId>>.broadcast();

  @override
  Stream<Set<AchievementId>> watchEarnedAchievements(String userId) async* {
    yield Set.unmodifiable(_earnedIds);
    yield* _controller.stream;
  }

  @override
  Future<List<AchievementId>> syncEarnedAchievements({
    required String userId,
    required List<AchievementCardModel> cards,
  }) async {
    final newIds = cards
        .where(
          (card) => card.isCurrentlyEarned && !_earnedIds.contains(card.id),
        )
        .map((card) => card.id)
        .toList();
    _earnedIds.addAll(newIds);
    if (newIds.isNotEmpty) {
      _controller.add(Set.unmodifiable(_earnedIds));
    }
    return newIds;
  }
}

class MemoryProfileMediaRepository implements ProfileMediaRepository {
  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    required String? contentType,
  }) async {
    return 'memory://avatars/$userId/$fileName';
  }
}
