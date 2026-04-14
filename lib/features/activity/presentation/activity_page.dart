import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/formatters/app_date_formatter.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = AppSessionScope.of(context).currentUser;
    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: AppSkeletonList(),
        ),
      );
    }

    final refreshRevision = AppRefreshScope.revisionOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.activityTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<List<ActivityItem>>(
          key: ValueKey('activity-${user.id}-$refreshRevision'),
          stream: AppDependenciesScope.of(
            context,
          ).activityRepository.watchUserActivities(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.authGenericError));
            }

            final activities = snapshot.data ?? const <ActivityItem>[];
            return AppLoadingSwitcher(
              isLoading: !snapshot.hasData,
              loading: const AppSkeletonList(),
              child: activities.isEmpty
                  ? AppRefreshIndicator(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.55,
                            child: Center(child: Text(l10n.activityEmpty)),
                          ),
                        ],
                      ),
                    )
                  : AppRefreshIndicator(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          return _ActivityCard(activity: activities[index]);
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemCount: activities.length,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    final title = switch (activity.type) {
      ActivityType.newWager => l10n.activityNewWagerTitle,
      ActivityType.wagerResolved when activity.payout > 0 =>
        l10n.activityResolvedWonTitle(activity.payout),
      ActivityType.wagerResolved => l10n.activityResolvedTitle,
      ActivityType.wagerCancelled => l10n.activityCancelledTitle,
    };
    final icon = switch (activity.type) {
      ActivityType.newWager => Icons.add_circle_rounded,
      ActivityType.wagerResolved => Icons.check_circle_rounded,
      ActivityType.wagerCancelled => Icons.cancel_rounded,
    };

    return Card(
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.wagerDetails(activity.groupId, activity.wagerId),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                foregroundColor: colors.primary,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      activity.condition,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(activity.groupName)),
                        Chip(
                          label: Text(
                            l10n.activityCreatedAt(
                              formatAppDateTime(context, activity.createdAt),
                            ),
                          ),
                        ),
                        if (activity.type != ActivityType.newWager)
                          Chip(
                            label: Text(
                              l10n.activityCompletedAt(
                                formatAppDateTime(context, activity.createdAt),
                              ),
                            ),
                          ),
                        Chip(label: Text(l10n.activityOpenGroup)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
