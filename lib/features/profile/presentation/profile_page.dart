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
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AppRefreshIndicator(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: colors.surfaceContainerHigh,
                            backgroundImage: profile?.avatarUrl == null
                                ? null
                                : NetworkImage(profile!.avatarUrl!),
                            foregroundColor: colors.primary,
                            child: profile?.avatarUrl == null
                                ? const Icon(Icons.person_rounded, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.profileLevel(level),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.stars_rounded, color: colors.primary),
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
              Row(
                children: [
                  Expanded(
                    child: _ProfileMetric(
                      icon: Icons.casino_rounded,
                      label: l10n.profileTotalWagers,
                      value: totalWagers.toString(),
                      color: colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileMetric(
                      icon: Icons.verified_rounded,
                      label: l10n.profileCorrectWagers,
                      value: accuracyPercent,
                      color: colors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (profile != null) ...[
                ProfileAchievementsSection(profile: profile),
                const SizedBox(height: 12),
              ],
              Card(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Icon(
                        Icons.casino_rounded,
                        color: colors.tertiary,
                      ),
                      title: Text(l10n.profileMyWagers),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.myWagers),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Icon(
                        Icons.notifications_active_rounded,
                        color: colors.secondary,
                      ),
                      title: Text(l10n.profileActivity),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.activity),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _ProfileStat(
                      icon: Icons.check_circle_rounded,
                      label: l10n.profileCorrectWagers,
                      value: '$correctWagers / $accuracyPercent',
                      color: colors.secondary,
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _ProfileStat(
                      icon: Icons.stars_rounded,
                      label: l10n.profileTotalEarned,
                      value: totalTokensEarned.toString(),
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}
