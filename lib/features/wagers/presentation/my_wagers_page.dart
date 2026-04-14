import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/formatters/app_date_formatter.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class MyWagersPage extends StatelessWidget {
  const MyWagersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);
    final user = AppSessionScope.of(context).currentUser;
    final refreshRevision = AppRefreshScope.revisionOf(context);

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: AppSkeletonList(showHeader: true),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.myWagersTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<List<Wager>>(
          key: ValueKey('my-wagers-${user.id}-$refreshRevision'),
          stream: dependencies.wagerRepository.watchUserWagers(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.groupsLoadError));
            }

            final wagers = snapshot.data ?? const <Wager>[];
            return AppLoadingSwitcher(
              isLoading: !snapshot.hasData,
              loading: const AppSkeletonList(showHeader: true),
              child: _MyWagersList(userId: user.id, wagers: wagers),
            );
          },
        ),
      ),
    );
  }
}

class _MyWagersList extends StatelessWidget {
  const _MyWagersList({required this.userId, required this.wagers});

  final String userId;
  final List<Wager> wagers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myWagers = wagers
        .where((wager) => wager.hasStakeFrom(userId))
        .toList();
    final active = myWagers
        .where((wager) => wager.status == WagerStatus.active)
        .toList();
    final history = myWagers
        .where((wager) => wager.status != WagerStatus.active)
        .toList();

    if (myWagers.isEmpty) {
      return AppRefreshIndicator(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.casino_rounded,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.myWagersEmpty, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppRefreshIndicator(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (active.isNotEmpty) ...[
            _SectionTitle(label: l10n.myWagersActive),
            const SizedBox(height: 10),
            for (final wager in active) ...[
              _MyWagerCard(
                wager: wager,
                groupName: l10n.groupsTitle,
                userId: userId,
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (history.isNotEmpty) ...[
            _SectionTitle(label: l10n.myWagersHistory),
            const SizedBox(height: 10),
            for (final wager in history) ...[
              _MyWagerCard(
                wager: wager,
                groupName: l10n.groupsTitle,
                userId: userId,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _MyWagerCard extends StatelessWidget {
  const _MyWagerCard({
    required this.wager,
    required this.groupName,
    required this.userId,
  });

  final Wager wager;
  final String groupName;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stake = wager.stakes.firstWhere((item) => item.userId == userId);
    final sideLabel = switch (stake.side) {
      WagerSide.left => wager.leftOption.label,
      WagerSide.right => wager.rightOption.label,
    };
    final payout = wager.settlement?.payoutFor(userId) ?? 0;

    return Card(
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.wagerDetails(wager.groupId, wager.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  _StatusChip(status: wager.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                wager.condition,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      l10n.wagerArchiveStakeSide(sideLabel, stake.amount),
                    ),
                  ),
                  Chip(
                    label: Text(
                      l10n.wagerCreatedAt(
                        formatAppDateTime(context, wager.createdAt),
                      ),
                    ),
                  ),
                  if (wager.status != WagerStatus.active)
                    Chip(label: Text(l10n.wagerArchivePayout(payout))),
                  if (wager.status != WagerStatus.active)
                    Chip(
                      label: Text(
                        l10n.wagerCompletedAt(
                          formatAppDateTime(
                            context,
                            wager.resolvedAt ?? wager.updatedAt,
                          ),
                        ),
                      ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final WagerStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (status) {
      WagerStatus.active => l10n.wagerDetailsStatusActive,
      WagerStatus.resolved => l10n.wagerDetailsStatusResolved,
      WagerStatus.cancelled => l10n.wagerDetailsStatusCancelled,
    };

    return Chip(label: Text(label));
  }
}
