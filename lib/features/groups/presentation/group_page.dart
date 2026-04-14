import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/formatters/app_date_formatter.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/core/widgets/app_snack_bar.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/groups/domain/leaderboard_calculator.dart';
import 'package:point_rivals/features/groups/domain/leaderboard_period_id.dart';
import 'package:point_rivals/features/groups/presentation/group_accent_color.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:point_rivals/features/profile/domain/xp_progression.dart';
import 'package:point_rivals/features/profile/presentation/public_member_profile_page.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({required this.groupId, this.previewGroup, super.key});

  final String groupId;
  final RivalGroup? previewGroup;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  static const LeaderboardCalculator _leaderboardCalculator =
      LeaderboardCalculator();
  LeaderboardPeriod _leaderboardPeriod = LeaderboardPeriod.weekly;
  RivalGroup? _previewGroup;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _previewGroup = widget.previewGroup;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);
    final session = AppSessionScope.of(context);
    final user = session.currentUser;
    final refreshRevision = AppRefreshScope.revisionOf(context);

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppSkeletonList(),
        ),
      );
    }

    final previewGroup = _previewGroup;
    if (previewGroup != null) {
      return _GroupPreviewScaffold(
        group: previewGroup,
        isJoining: _isJoining,
        onJoin: () => _joinPreviewGroup(context, previewGroup, user),
        onRefresh: () => _refreshPreview(context, previewGroup),
      );
    }

    return StreamBuilder<List<GroupMember>>(
      key: ValueKey('group-members-${widget.groupId}-$refreshRevision'),
      stream: dependencies.groupRepository.watchMembers(widget.groupId),
      builder: (context, membersSnapshot) {
        final members = membersSnapshot.data ?? const [];
        final currentMember = members
            .where((member) => member.userId == user.id)
            .firstOrNull;
        final isAdmin = currentMember?.role == GroupMemberRole.admin;

        return StreamBuilder<RivalGroup>(
          key: ValueKey('group-${widget.groupId}-$refreshRevision'),
          stream: dependencies.groupRepository.watchGroup(
            widget.groupId,
            userId: user.id,
          ),
          builder: (context, groupSnapshot) {
            final group = groupSnapshot.data;
            final accentColor = group?.accentColor;
            final leaderboardWindowWeeks =
                group?.leaderboardWindowWeeks.clamp(1, 52) ?? 1;
            final weeklyPeriodId = currentLeaderboardPeriodId(
              windowWeeks: leaderboardWindowWeeks,
              anchorDate: group?.leaderboardPeriodAnchorDate,
            );
            final leaders = _leaderboardCalculator.topMembers(
              members: members,
              period: _leaderboardPeriod,
              weeklyPeriodId: weeklyPeriodId,
            );
            final scaffold = Scaffold(
              appBar: AppBar(
                actions: [
                  if (!isAdmin)
                    IconButton(
                      tooltip: l10n.groupLeaveAction,
                      onPressed: () => _confirmLeaveGroup(context),
                      icon: const Icon(Icons.logout_rounded),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.groupLeaveAction,
                          onPressed: () => _confirmLeaveGroup(context),
                          icon: const Icon(Icons.logout_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            unawaited(
                              context.push(
                                AppRoutes.groupSettings(widget.groupId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_rounded),
                        ),
                      ],
                    ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () =>
                    context.push(AppRoutes.createWager(widget.groupId)),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.groupCreateWager),
              ),
              body: SafeArea(
                minimum: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppRefreshIndicator(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: 24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      _GroupHeroCard(
                        group: group,
                        members: members,
                        currentMember: currentMember,
                        onMembersPressed: members.isEmpty
                            ? null
                            : () => _showMembers(context, members),
                      ),
                      const SizedBox(height: 12),
                      _LeaderboardSwitcher(
                        period: _leaderboardPeriod,
                        onChanged: (period) {
                          setState(() => _leaderboardPeriod = period);
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          child: _Leaderboard(
                            key: ValueKey(
                              '$_leaderboardPeriod-$weeklyPeriodId',
                            ),
                            title:
                                _leaderboardPeriod == LeaderboardPeriod.weekly
                                ? l10n.groupWindowLeaders(
                                    leaderboardWindowWeeks,
                                  )
                                : l10n.groupAllTimeLeaders,
                            members: leaders,
                            period: _leaderboardPeriod,
                            weeklyPeriodId: weeklyPeriodId,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          unawaited(
                            context.push(
                              AppRoutes.wagerArchive(widget.groupId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.archive_rounded),
                        label: Text(l10n.groupWagerArchive),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.groupActiveWagers,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _ActiveWagersList(
                        groupId: widget.groupId,
                        currentMember: currentMember,
                        isAdmin: isAdmin,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (accentColor == null) {
              return scaffold;
            }

            return Theme(
              data: groupAccentTheme(context, accentColor),
              child: scaffold,
            );
          },
        );
      },
    );
  }

  Future<void> _refreshPreview(
    BuildContext context,
    RivalGroup previewGroup,
  ) async {
    final repository = AppDependenciesScope.of(context).groupRepository;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final group = await repository.previewGroupByInviteCode(
        previewGroup.inviteCode,
      );
      if (mounted) {
        setState(() => _previewGroup = group);
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.joinGroupError,
        );
      }
    }
  }

  Future<void> _joinPreviewGroup(
    BuildContext context,
    RivalGroup group,
    UserProfile user,
  ) async {
    if (_isJoining) {
      return;
    }

    final l10n = context.l10n;
    final repository = AppDependenciesScope.of(context).groupRepository;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isJoining = true);
    try {
      await repository.joinGroup(groupId: group.inviteCode, user: user);
      if (mounted) {
        router.go(AppRoutes.group(group.id));
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.joinGroupError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _showMembers(BuildContext context, List<GroupMember> members) {
    final AppLocalizations l10n = context.l10n;
    final rootContext = context;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return SafeArea(
          minimum: const EdgeInsets.all(20),
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (itemContext, index) {
              final member = members[index];

              return ListTile(
                leading: _MemberAvatar(member: member),
                title: Text(member.displayName),
                subtitle: Text(_levelLabel(itemContext, member)),
                trailing: member.role == GroupMemberRole.admin
                    ? Chip(label: Text(l10n.groupAdminBadge))
                    : null,
                onTap: () {
                  final router = GoRouter.of(rootContext);
                  Navigator.of(sheetContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!rootContext.mounted) {
                      return;
                    }

                    pushPublicMemberProfile(router, member);
                  });
                },
              );
            },
            itemCount: members.length,
          ),
        );
      },
    );
  }

  Future<void> _confirmLeaveGroup(BuildContext context) async {
    final l10n = context.l10n;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.groupLeaveTitle),
          content: Text(l10n.groupLeaveBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.groupLeaveConfirm),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true || !context.mounted) {
      return;
    }

    final repository = AppDependenciesScope.of(context).groupRepository;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await repository.leaveGroup(widget.groupId);
      if (context.mounted) {
        router.go(AppRoutes.groups);
      }
    } on Object {
      if (context.mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.groupLeaveError,
        );
      }
    }
  }

  String _levelLabel(BuildContext context, GroupMember member) {
    return context.l10n.profileLevel(
      const XpProgression().levelForXp(member.xp),
    );
  }
}

class _GroupHeroCard extends StatelessWidget {
  const _GroupHeroCard({
    required this.group,
    required this.members,
    required this.currentMember,
    required this.onMembersPressed,
  });

  final RivalGroup? group;
  final List<GroupMember> members;
  final GroupMember? currentMember;
  final VoidCallback? onMembersPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final accentColor = group?.accentColor ?? colors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: onGroupAccentColor(accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group?.name ?? l10n.groupsTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.groupMembers(members.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.stars_rounded,
                    label: l10n.groupsMyBalance(
                      currentMember?.tokenBalance ?? 0,
                    ),
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.local_fire_department_rounded,
                    label: l10n.groupsActiveWagersCount(
                      group?.activeWagerCount ?? 0,
                    ),
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onMembersPressed,
              icon: const Icon(Icons.people_outline_rounded),
              label: Text(l10n.groupMembers(members.length)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openPublicMemberProfile(BuildContext context, GroupMember member) {
  pushPublicMemberProfile(GoRouter.of(context), member);
}

void pushPublicMemberProfile(GoRouter router, GroupMember member) {
  unawaited(
    router.push(
      AppRoutes.memberProfile(member.userId),
      extra: PublicMemberProfile(member: member),
    ),
  );
}

class _GroupPreviewScaffold extends StatelessWidget {
  const _GroupPreviewScaffold({
    required this.group,
    required this.isJoining,
    required this.onJoin,
    required this.onRefresh,
  });

  final RivalGroup group;
  final bool isJoining;
  final VoidCallback onJoin;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppRefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.groups_2_rounded,
                        size: 34,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        group.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.joinGroupMembersPreview(group.memberCount),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: isJoining ? null : onJoin,
                        child: isJoining
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.joinGroupJoinButton),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({
    required this.title,
    required this.members,
    required this.period,
    required this.weeklyPeriodId,
    super.key,
  });

  final String title;
  final List<GroupMember> members;
  final LeaderboardPeriod period;
  final String weeklyPeriodId;
  static const LeaderboardCalculator _leaderboardCalculator =
      LeaderboardCalculator();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (members.isEmpty)
              const SizedBox(height: 8)
            else
              for (final entry in members.indexed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _LeaderboardAvatar(
                    member: entry.$2,
                    rank: entry.$1 + 1,
                  ),
                  title: Text(
                    entry.$2.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  subtitle: Text(
                    l10n.profileLevel(
                      const XpProgression().levelForXp(entry.$2.xp),
                    ),
                  ),
                  trailing: Text(
                    _leaderboardCalculator
                        .scoreFor(
                          entry.$2,
                          period,
                          weeklyPeriodId: weeklyPeriodId,
                        )
                        .toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: colors.primary),
                  ),
                  onTap: () => openPublicMemberProfile(context, entry.$2),
                ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardAvatar extends StatelessWidget {
  const _LeaderboardAvatar({required this.member, required this.rank});

  final GroupMember member;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avatarUrl = member.avatarUrl;

    return SizedBox.square(
      dimension: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.surfaceContainerHigh,
            backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
            foregroundColor: colors.primary,
            child: avatarUrl == null ? const Icon(Icons.person_rounded) : null,
          ),
          PositionedDirectional(
            end: -2,
            bottom: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: SizedBox.square(
                dimension: 18,
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
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

class _LeaderboardSwitcher extends StatelessWidget {
  const _LeaderboardSwitcher({
    required this.period,
    required this.onChanged,
    required this.child,
  });

  final LeaderboardPeriod period;
  final ValueChanged<LeaderboardPeriod> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<LeaderboardPeriod>(
          segments: [
            ButtonSegment(
              value: LeaderboardPeriod.weekly,
              label: Text(l10n.groupWeeklyTab),
              icon: const Icon(Icons.calendar_view_week_rounded),
            ),
            ButtonSegment(
              value: LeaderboardPeriod.allTime,
              label: Text(l10n.groupAllTimeTab),
              icon: const Icon(Icons.emoji_events_rounded),
            ),
          ],
          selected: {period},
          onSelectionChanged: (selection) => onChanged(selection.single),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ActiveWagersList extends StatelessWidget {
  const _ActiveWagersList({
    required this.groupId,
    required this.currentMember,
    required this.isAdmin,
    required this.accentColor,
  });

  final String groupId;
  final GroupMember? currentMember;
  final bool isAdmin;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);

    return StreamBuilder<List<Wager>>(
      stream: dependencies.wagerRepository.watchActiveWagers(groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                l10n.groupsLoadError,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const AppShimmer(child: AppSkeletonCard(height: 128));
        }

        final wagers = snapshot.data!;
        if (wagers.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                l10n.groupNoActiveWagers,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final wager in wagers) ...[
              _ActiveWagerCard(
                groupId: groupId,
                wager: wager,
                currentMember: currentMember,
                isAdmin: isAdmin,
                accentColor: accentColor,
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ActiveWagerCard extends StatefulWidget {
  const _ActiveWagerCard({
    required this.groupId,
    required this.wager,
    required this.currentMember,
    required this.isAdmin,
    required this.accentColor,
  });

  final String groupId;
  final Wager wager;
  final GroupMember? currentMember;
  final bool isAdmin;
  final Color? accentColor;

  @override
  State<_ActiveWagerCard> createState() => _ActiveWagerCardState();
}

class _ActiveWagerCardState extends State<_ActiveWagerCard> {
  bool _isSettling = false;

  String get groupId => widget.groupId;

  Wager get wager => widget.wager;

  GroupMember? get currentMember => widget.currentMember;

  bool get isAdmin => widget.isAdmin;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final accentColor = widget.accentColor ?? colors.primary;
    final userId = currentMember?.userId;
    final canStake = userId != null && wager.canUserStake(userId);
    final myStake = userId == null
        ? null
        : wager.stakes.where((stake) => stake.userId == userId).firstOrNull;

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.wagerDetails(groupId, wager.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      wager.condition,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _WagerOptionButton(
                      label: wager.leftOption.label,
                      isSelected: myStake?.side == WagerSide.left,
                      accentColor: accentColor,
                      onPressed: canStake
                          ? () {
                              unawaited(_confirmStake(context, WagerSide.left));
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WagerOptionButton(
                      label: wager.rightOption.label,
                      isSelected: myStake?.side == WagerSide.right,
                      accentColor: accentColor,
                      onPressed: canStake
                          ? () {
                              unawaited(
                                _confirmStake(context, WagerSide.right),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(label: l10n.wagerRewardCoins(wager.rewardCoins)),
                  _InfoPill(
                    label: l10n.wagerStakeRatio(
                      wager.stakeCountForSide(WagerSide.left),
                      wager.stakeCountForSide(WagerSide.right),
                    ),
                  ),
                  _InfoPill(
                    label: l10n.wagerCreatedAt(
                      formatAppDateTime(context, wager.createdAt),
                    ),
                  ),
                ],
              ),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSettling
                            ? null
                            : () {
                                unawaited(
                                  _confirmResolve(context, WagerSide.left),
                                );
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: colors.secondary,
                        ),
                        child: Text(
                          l10n.wagerResolveAs(wager.leftOption.label),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: _isSettling
                            ? null
                            : () {
                                unawaited(
                                  _confirmResolve(context, WagerSide.right),
                                );
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: colors.secondary,
                        ),
                        child: Text(
                          l10n.wagerResolveAs(wager.rightOption.label),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _isSettling
                      ? null
                      : () {
                          unawaited(_confirmCancel(context));
                        },
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                  icon: const Icon(Icons.cancel_rounded),
                  label: Text(l10n.wagerCancelAction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmStake(BuildContext context, WagerSide side) {
    final AppLocalizations l10n = context.l10n;
    final member = currentMember;
    if (member == null || !wager.canUserStake(member.userId)) {
      showAppSnackBar(context: context, message: l10n.wagerStakeUnavailable);
      return Future<void>.value();
    }

    return showDialog<void>(
      context: context,
      builder: (context) {
        return _StakeDialog(
          groupId: groupId,
          wager: wager,
          side: side,
          userId: member.userId,
        );
      },
    );
  }

  Future<void> _confirmResolve(BuildContext context, WagerSide side) {
    final l10n = context.l10n;
    final repository = AppDependenciesScope.of(context).wagerRepository;
    final messenger = ScaffoldMessenger.of(context);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.wagerResolveTitle),
          content: Text(l10n.wagerResolveBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () async {
                final member = currentMember;
                if (member == null) {
                  return;
                }

                try {
                  Navigator.of(dialogContext).pop();
                  setState(() => _isSettling = true);
                  await repository.resolveWager(
                    groupId: groupId,
                    wagerId: wager.id,
                    winningSide: side,
                    adminUserId: member.userId,
                  );
                } on Object {
                  showAppSnackBarOnMessenger(
                    messenger: messenger,
                    message: l10n.wagerResolveError,
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isSettling = false);
                  }
                }
              },
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context) {
    final l10n = context.l10n;
    final repository = AppDependenciesScope.of(context).wagerRepository;
    final messenger = ScaffoldMessenger.of(context);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.wagerCancelTitle),
          content: Text(l10n.wagerCancelBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () async {
                final member = currentMember;
                if (member == null) {
                  return;
                }

                try {
                  Navigator.of(dialogContext).pop();
                  setState(() => _isSettling = true);
                  await repository.cancelWager(
                    groupId: groupId,
                    wagerId: wager.id,
                    adminUserId: member.userId,
                  );
                } on Object {
                  showAppSnackBarOnMessenger(
                    messenger: messenger,
                    message: l10n.wagerCancelError,
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isSettling = false);
                  }
                }
              },
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _WagerOptionButton extends StatelessWidget {
  const _WagerOptionButton({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;
    final foregroundColor = isSelected
        ? accentColor
        : isEnabled
        ? colors.onSurface
        : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : colors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, size: 14, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        l10n.wagerYourChoice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StakeDialog extends StatefulWidget {
  const _StakeDialog({
    required this.groupId,
    required this.wager,
    required this.side,
    required this.userId,
  });

  final String groupId;
  final Wager wager;
  final WagerSide side;
  final String userId;

  @override
  State<_StakeDialog> createState() => _StakeDialogState();
}

class _StakeDialogState extends State<_StakeDialog> {
  bool _isSaving = false;

  Future<void> _placeStake() async {
    if (_isSaving) {
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      await AppDependenciesScope.of(context).wagerRepository.placeStake(
        groupId: widget.groupId,
        wagerId: widget.wager.id,
        stake: Stake(userId: widget.userId, side: widget.side),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        showAppSnackBarOnMessenger(
          messenger: messenger,
          message: l10n.wagerStakeError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reward = widget.wager.rewardForSide(widget.side);

    return AlertDialog(
      title: Text(l10n.wagerConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.wagerConfirmBody),
          const SizedBox(height: 12),
          Chip(
            avatar: const Icon(Icons.savings_rounded, size: 16),
            label: Text(l10n.wagerPotentialPayout(reward)),
          ),
          if (reward > widget.wager.rewardCoins) ...[
            const SizedBox(height: 8),
            Text(
              l10n.wagerUnderdogBonus,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _placeStake,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person_outline_rounded));
    }

    return CircleAvatar(backgroundImage: NetworkImage(avatarUrl));
  }
}
