import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/core/l10n/generated/app_localizations.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:point_rivals/features/profile/presentation/public_member_profile_page.dart';

void main() {
  test('serializes public member profile route extra', () {
    const member = GroupMember(
      userId: 'user-2',
      displayName: 'Morgan',
      avatarUrl: null,
      role: GroupMemberRole.member,
      tokenBalance: 12,
      weeklyTokensEarned: 4,
      weeklyScorePeriodId: '2026-W16',
      dailyTokenBuckets: {'20260414': 4},
      allTimeTokensEarned: 90,
      xp: 20,
      totalWagers: 3,
      correctWagers: 2,
      totalTokensEarned: 140,
    );
    const extra = PublicMemberProfile(member: member);

    final decoded = jsonDecode(jsonEncode(extra)) as Map<String, Object?>;
    final restored = publicMemberProfileFromExtra(decoded);

    expect(restored?.member.userId, member.userId);
    expect(restored?.member.displayName, member.displayName);
    expect(restored?.member.role, member.role);
    expect(restored?.member.dailyTokenBuckets, member.dailyTokenBuckets);
  });

  testWidgets('loads a public profile from the user id without route extra', (
    tester,
  ) async {
    const profile = UserProfile(
      id: 'user-2',
      displayName: 'Morgan',
      avatarUrl: null,
      isActive: true,
      xp: 20,
      totalWagers: 3,
      correctWagers: 2,
      totalTokensEarned: 140,
      notificationsEnabled: false,
      themePreference: AppThemePreference.system,
    );

    await tester.pumpWidget(
      AppDependenciesScope(
        dependencies: AppDependencies(
          authRepository: MemoryAuthRepository(),
          groupRepository: MemoryGroupRepository(),
          wagerRepository: MemoryWagerRepository(),
          taskRepository: MemoryTaskRepository(),
          notificationRepository: MemoryNotificationRepository(),
          profileMediaRepository: MemoryProfileMediaRepository(),
          activityRepository: MemoryActivityRepository(),
          publicProfileRepository: MemoryPublicProfileRepository({
            profile.id: profile,
          }),
          achievementRepository: MemoryAchievementRepository(),
        ),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PublicMemberProfilePage(userId: 'user-2', member: null),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Morgan'), findsWidgets);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('2 / 67%'), findsOneWidget);
    expect(find.text('Correct wagers'), findsOneWidget);
  });
}
