import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:point_rivals/features/profile/domain/xp_progression.dart';

final class PublicMemberProfile {
  const PublicMemberProfile({required this.member});

  factory PublicMemberProfile.fromJson(Map<String, Object?> json) {
    final memberJson = json['member'];
    if (memberJson is! Map) {
      throw const FormatException('Public member profile is missing member.');
    }

    return PublicMemberProfile(
      member: GroupMember(
        userId: memberJson['userId'] as String,
        displayName: memberJson['displayName'] as String,
        avatarUrl: memberJson['avatarUrl'] as String?,
        role: GroupMemberRole.values.byName(memberJson['role'] as String),
        tokenBalance: memberJson['tokenBalance'] as int,
        weeklyTokensEarned: memberJson['weeklyTokensEarned'] as int,
        weeklyScorePeriodId: memberJson['weeklyScorePeriodId'] as String,
        dailyTokenBuckets: _dailyTokenBucketsFromJson(
          memberJson['dailyTokenBuckets'],
        ),
        allTimeTokensEarned: memberJson['allTimeTokensEarned'] as int,
        xp: memberJson['xp'] as int,
        totalWagers: memberJson['totalWagers'] as int,
        correctWagers: memberJson['correctWagers'] as int,
        totalTokensEarned: memberJson['totalTokensEarned'] as int,
      ),
    );
  }

  final GroupMember member;

  Map<String, Object?> toJson() => {
    'member': {
      'userId': member.userId,
      'displayName': member.displayName,
      'avatarUrl': member.avatarUrl,
      'role': member.role.name,
      'tokenBalance': member.tokenBalance,
      'weeklyTokensEarned': member.weeklyTokensEarned,
      'weeklyScorePeriodId': member.weeklyScorePeriodId,
      'dailyTokenBuckets': member.dailyTokenBuckets,
      'allTimeTokensEarned': member.allTimeTokensEarned,
      'xp': member.xp,
      'totalWagers': member.totalWagers,
      'correctWagers': member.correctWagers,
      'totalTokensEarned': member.totalTokensEarned,
    },
  };
}

Map<String, int> _dailyTokenBucketsFromJson(Object? value) {
  if (value is! Map) {
    return const {};
  }

  return value.map((key, item) {
    final normalizedKey = key is String ? key : key.toString();
    return MapEntry(normalizedKey, item is int ? item : 0);
  });
}

PublicMemberProfile? publicMemberProfileFromExtra(Object? extra) {
  if (extra is PublicMemberProfile) {
    return extra;
  }
  if (extra is Map<String, Object?>) {
    try {
      return PublicMemberProfile.fromJson(extra);
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

class PublicMemberProfilePage extends StatelessWidget {
  const PublicMemberProfilePage({
    required this.userId,
    required this.member,
    super.key,
  });

  final String userId;
  final PublicMemberProfile? member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final memberData = member?.member;
    if (memberData != null) {
      return _PublicMemberProfileContent(
        data: _PublicMemberViewData.from(
          userId: userId,
          member: memberData,
          profile: null,
        )!,
      );
    }

    final repository = AppDependenciesScope.of(context).publicProfileRepository;

    return StreamBuilder<UserProfile?>(
      stream: repository.watchProfile(userId),
      builder: (context, snapshot) {
        final data = _PublicMemberViewData.from(
          userId: userId,
          member: member?.member,
          profile: snapshot.data,
        );
        if (snapshot.hasError && data == null) {
          return _PublicMemberProfileScaffold(
            title: l10n.profileTitle,
            child: Center(child: Text(l10n.profileLoadError)),
          );
        }

        if (data == null) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none;
          return _PublicMemberProfileScaffold(
            title: l10n.profileTitle,
            child: isLoading
                ? const AppSkeletonList(itemCount: 3)
                : Center(child: Text(l10n.profileNotFound)),
          );
        }

        return _PublicMemberProfileContent(data: data);
      },
    );
  }
}

class _PublicMemberProfileScaffold extends StatelessWidget {
  const _PublicMemberProfileScaffold({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go('/groups');
          },
        ),
        title: Text(title),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }
}

class _PublicMemberProfileContent extends StatelessWidget {
  const _PublicMemberProfileContent({required this.data});

  final _PublicMemberViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    const progression = XpProgression();
    final xp = data.xp;
    final level = progression.levelForXp(xp);
    final currentXp = progression.xpIntoCurrentLevel(xp);
    final requiredXp = progression.xpRequiredForNextLevel(level);
    final totalWagers = data.totalWagers;
    final correctWagers = data.correctWagers;
    final accuracyPercent = totalWagers == 0
        ? '0%'
        : '${((correctWagers / totalWagers) * 100).round()}%';
    final avatarUrl = data.avatarUrl?.trim();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go('/groups');
          },
        ),
        title: Text(data.displayName),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: colors.surfaceContainerHigh,
                          backgroundImage:
                              avatarUrl == null || avatarUrl.isEmpty
                              ? null
                              : NetworkImage(avatarUrl),
                          foregroundColor: colors.primary,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? const Icon(Icons.person_rounded, size: 34)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.profileLevel(level),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: LinearProgressIndicator(
                        value: progression.progressToNextLevel(xp),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.profileXpProgress(currentXp, requiredXp),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                        Text(
                          xp.toString(),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.85,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _MemberStat(
                  icon: Icons.savings_rounded,
                  value: data.tokenBalance.toString(),
                  label: l10n.profileChips,
                  color: colors.primary,
                ),
                _MemberStat(
                  icon: Icons.stars_rounded,
                  value: xp.toString(),
                  label: l10n.profileXp,
                  color: colors.tertiary,
                ),
                _MemberStat(
                  icon: Icons.casino_rounded,
                  value: totalWagers.toString(),
                  label: l10n.profileTotalWagers,
                  color: colors.tertiary,
                ),
                _MemberStat(
                  icon: Icons.verified_rounded,
                  value: '$correctWagers / $accuracyPercent',
                  label: l10n.profileCorrectWagers,
                  color: colors.secondary,
                ),
                _MemberStat(
                  icon: Icons.emoji_events_rounded,
                  value: data.totalTokensEarned.toString(),
                  label: l10n.profileTotalEarned,
                  color: colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _PublicMemberViewData {
  const _PublicMemberViewData({
    required this.displayName,
    required this.avatarUrl,
    required this.tokenBalance,
    required this.xp,
    required this.totalWagers,
    required this.correctWagers,
    required this.totalTokensEarned,
  });

  final String displayName;
  final String? avatarUrl;
  final int tokenBalance;
  final int xp;
  final int totalWagers;
  final int correctWagers;
  final int totalTokensEarned;

  static _PublicMemberViewData? from({
    required String userId,
    required GroupMember? member,
    required UserProfile? profile,
  }) {
    if (member == null && profile == null) {
      return null;
    }

    final displayName = _firstNonEmpty([
      profile?.displayName,
      member?.displayName,
      userId,
    ]);

    return _PublicMemberViewData(
      displayName: displayName,
      avatarUrl: _firstNonEmpty([profile?.avatarUrl, member?.avatarUrl]),
      tokenBalance: member?.tokenBalance ?? 0,
      xp: profile?.xp ?? member?.xp ?? 0,
      totalWagers: profile?.totalWagers ?? member?.totalWagers ?? 0,
      correctWagers: profile?.correctWagers ?? member?.correctWagers ?? 0,
      totalTokensEarned:
          profile?.totalTokensEarned ?? member?.totalTokensEarned ?? 0,
    );
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }
}

class _MemberStat extends StatelessWidget {
  const _MemberStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
