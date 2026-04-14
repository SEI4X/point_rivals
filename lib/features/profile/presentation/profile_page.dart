import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/features/achievements/presentation/profile_achievements_section.dart';
import 'package:point_rivals/features/profile/domain/xp_progression.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final session = AppSessionScope.of(context);
    final profile = session.currentUser;
    const XpProgression progression = XpProgression();
    final int xp = profile?.xp ?? 0;
    final int level = progression.levelForXp(xp);
    final int currentXp = progression.xpIntoCurrentLevel(xp);
    final int requiredXp = progression.xpRequiredForNextLevel(level);
    final int totalWagers = profile?.totalWagers ?? 0;
    final int correctWagers = profile?.correctWagers ?? 0;
    final int totalTokensEarned = profile?.totalTokensEarned ?? 0;
    final String accuracyPercent = totalWagers == 0
        ? '0%'
        : '${((correctWagers / totalWagers) * 100).round()}%';
    final String displayName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : l10n.profileUnnamed;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 8),
        child: AppRefreshIndicator(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            padding: EdgeInsets.only(
              bottom: 24 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: colors.surfaceContainerHigh,
                      backgroundImage: profile?.avatarUrl == null
                          ? null
                          : NetworkImage(profile!.avatarUrl!),
                      foregroundColor: colors.primary,
                      child: profile?.avatarUrl == null
                          ? const Icon(Icons.person_rounded, size: 44)
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.profileLevel(level),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.85,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _ProfileTile(
                      icon: Icons.stars_rounded,
                      label: l10n.profileXp,
                      value: xp.toString(),
                      color: colors.primary,
                    ),
                    _ProfileTile(
                      icon: Icons.casino_rounded,
                      label: l10n.profileTotalWagers,
                      value: totalWagers.toString(),
                      color: colors.tertiary,
                    ),
                    _ProfileTile(
                      icon: Icons.verified_rounded,
                      label: l10n.profileCorrectWagers,
                      value: '$correctWagers / $accuracyPercent',
                      color: colors.secondary,
                    ),
                    _ProfileTile(
                      icon: Icons.emoji_events_rounded,
                      label: l10n.profileTotalEarned,
                      value: totalTokensEarned.toString(),
                      color: colors.primary,
                    ),
                    _ProfileActionTile(
                      icon: Icons.casino_rounded,
                      label: l10n.profileMyWagers,
                      color: colors.tertiary,
                      onTap: () => context.push(AppRoutes.myWagers),
                    ),
                    _ProfileActionTile(
                      icon: Icons.notifications_active_rounded,
                      label: l10n.profileActivity,
                      color: colors.secondary,
                      onTap: () => context.push(AppRoutes.activity),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (profile != null) ...[
                ProfileAchievementsSection(profile: profile),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
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

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
