import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/widgets/app_shell_layout.dart';
import 'package:point_rivals/features/achievements/presentation/achievements_page.dart';
import 'package:point_rivals/features/activity/presentation/activity_page.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/groups/presentation/create_group_page.dart';
import 'package:point_rivals/features/groups/presentation/group_page.dart';
import 'package:point_rivals/features/groups/presentation/group_settings_page.dart';
import 'package:point_rivals/features/groups/presentation/groups_page.dart';
import 'package:point_rivals/features/groups/presentation/join_group_scanner_page.dart';
import 'package:point_rivals/features/onboarding/presentation/onboarding_page.dart';
import 'package:point_rivals/features/profile/presentation/profile_page.dart';
import 'package:point_rivals/features/profile/presentation/public_member_profile_page.dart';
import 'package:point_rivals/features/settings/presentation/settings_page.dart';
import 'package:point_rivals/features/tasks/presentation/create_task_page.dart';
import 'package:point_rivals/features/tasks/presentation/task_details_page.dart';
import 'package:point_rivals/features/wagers/presentation/create_wager_page.dart';
import 'package:point_rivals/features/wagers/presentation/my_wagers_page.dart';
import 'package:point_rivals/features/wagers/presentation/wager_archive_page.dart';
import 'package:point_rivals/features/wagers/presentation/wager_details_page.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String splash = '/splash';
  static const String groups = '/groups';
  static const String createGroup = '/groups/create';
  static const String joinGroupScanner = '/groups/join/scan';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String myWagers = '/profile/wagers';
  static const String activity = '/profile/activity';
  static const String achievements = '/profile/achievements';

  static String group(String groupId) => '/groups/$groupId';

  static String groupSettings(String groupId) => '/groups/$groupId/settings';

  static String wagerArchive(String groupId) =>
      '/groups/$groupId/wagers/archive';

  static String createWager(String groupId) => '/groups/$groupId/wagers/create';

  static String wagerDetails(String groupId, String wagerId) =>
      '/groups/$groupId/wagers/$wagerId';

  static String createTask(String groupId) => '/groups/$groupId/tasks/create';

  static String taskDetails(String groupId, String taskId) =>
      '/groups/$groupId/tasks/$taskId';

  static String memberProfile(String userId) => '/members/$userId';
}

Map<String, Object?> rivalGroupRouteExtra(RivalGroup group) => {
  'id': group.id,
  'name': group.name,
  'inviteCode': group.inviteCode,
  'memberCount': group.memberCount,
  'activeWagerCount': group.activeWagerCount,
  'myTokenBalance': group.myTokenBalance,
  'accentColorValue': group.accentColorValue,
};

RivalGroup? rivalGroupFromRouteExtra(Object? extra) {
  if (extra is RivalGroup) {
    return extra;
  }
  if (extra is Map<String, Object?>) {
    try {
      return RivalGroup(
        id: extra['id'] as String,
        name: extra['name'] as String,
        inviteCode: extra['inviteCode'] as String,
        memberCount: extra['memberCount'] as int,
        activeWagerCount: extra['activeWagerCount'] as int,
        myTokenBalance: extra['myTokenBalance'] as int,
        leaderboardWindowWeeks: 1,
        leaderboardPeriodAnchorDate: null,
        accentColorValue: extra['accentColorValue'] as int,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  return null;
}

GoRouter createAppRouter(AppSessionController sessionController) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: sessionController,
    redirect: (context, state) {
      final bool isSplash = state.uri.path == AppRoutes.splash;
      final bool isOnboarding = state.uri.path == AppRoutes.onboarding;
      if (sessionController.isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      if (!sessionController.isSignedIn) {
        return isOnboarding ? null : AppRoutes.onboarding;
      }

      return isOnboarding || isSplash ? AppRoutes.groups : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            showTabBar:
                state.uri.path == AppRoutes.groups ||
                state.uri.path == AppRoutes.profile,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) => const GroupsPage(),
                routes: [
                  GoRoute(
                    path: ':groupId',
                    builder: (context, state) {
                      return GroupPage(
                        groupId: state.pathParameters['groupId']!,
                        previewGroup: rivalGroupFromRouteExtra(state.extra),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'settings',
                        builder: (context, state) {
                          return GroupSettingsPage(
                            groupId: state.pathParameters['groupId']!,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'wagers/archive',
                        builder: (context, state) {
                          return WagerArchivePage(
                            groupId: state.pathParameters['groupId']!,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'wagers/create',
                        builder: (context, state) {
                          return CreateWagerPage(
                            groupId: state.pathParameters['groupId']!,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'wagers/:wagerId',
                        builder: (context, state) {
                          return WagerDetailsPage(
                            groupId: state.pathParameters['groupId']!,
                            wagerId: state.pathParameters['wagerId']!,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'tasks/create',
                        builder: (context, state) {
                          return CreateTaskPage(
                            groupId: state.pathParameters['groupId']!,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'tasks/:taskId',
                        builder: (context, state) {
                          return TaskDetailsPage(
                            groupId: state.pathParameters['groupId']!,
                            taskId: state.pathParameters['taskId']!,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createGroup,
        builder: (context, state) => const CreateGroupPage(),
      ),
      GoRoute(
        path: AppRoutes.joinGroupScanner,
        builder: (context, state) => const JoinGroupScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.myWagers,
        builder: (context, state) => const MyWagersPage(),
      ),
      GoRoute(
        path: AppRoutes.activity,
        builder: (context, state) => const ActivityPage(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsPage(),
      ),
      GoRoute(
        path: '/members/:userId',
        builder: (context, state) {
          return PublicMemberProfilePage(
            userId: state.pathParameters['userId']!,
            member: publicMemberProfileFromExtra(state.extra),
          );
        },
      ),
    ],
  );
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.expand());
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.showTabBar,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool showTabBar;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: navigationShell),
          if (showTabBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                minimum: const EdgeInsets.only(
                  bottom: AppShellLayout.tabBarBottomMargin,
                ),
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 252),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: AppShellLayout.tabBarHeight,
                          child: Row(
                            children: [
                              Expanded(
                                child: _CapsuleTabItem(
                                  icon: Icons.groups_2_rounded,
                                  label: l10n.navGroups,
                                  isSelected: navigationShell.currentIndex == 0,
                                  onTap: () => navigationShell.goBranch(0),
                                ),
                              ),
                              Expanded(
                                child: _CapsuleTabItem(
                                  icon: navigationShell.currentIndex == 1
                                      ? Icons.person_rounded
                                      : Icons.person_outline_rounded,
                                  label: l10n.navProfile,
                                  isSelected: navigationShell.currentIndex == 1,
                                  onTap: () => navigationShell.goBranch(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CapsuleTabItem extends StatelessWidget {
  const _CapsuleTabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = isSelected ? colors.primary : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 62,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.surfaceContainerHigh
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: foreground, size: 27),
            ),
          ),
        ),
      ),
    );
  }
}
