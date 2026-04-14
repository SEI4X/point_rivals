import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/core/formatters/app_date_formatter.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class WagerDetailsPage extends StatelessWidget {
  const WagerDetailsPage({
    required this.groupId,
    required this.wagerId,
    super.key,
  });

  final String groupId;
  final String wagerId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);
    final userId = AppSessionScope.of(context).currentUser?.id;
    final refreshRevision = AppRefreshScope.revisionOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.wagerDetailsTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<List<GroupMember>>(
          key: ValueKey('wager-members-$groupId-$refreshRevision'),
          stream: dependencies.groupRepository.watchMembers(groupId),
          builder: (context, membersSnapshot) {
            final membersById = {
              for (final member
                  in membersSnapshot.data ?? const <GroupMember>[])
                member.userId: member,
            };

            return StreamBuilder<Wager>(
              key: ValueKey('wager-$groupId-$wagerId-$refreshRevision'),
              stream: dependencies.wagerRepository.watchWager(
                groupId: groupId,
                wagerId: wagerId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.authGenericError));
                }

                final wager = snapshot.data;
                return AppLoadingSwitcher(
                  isLoading: wager == null,
                  loading: const AppSkeletonList(itemCount: 3),
                  child: wager == null
                      ? const SizedBox.shrink()
                      : _WagerDetailsContent(
                          wager: wager,
                          membersById: membersById,
                          userId: userId,
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _WagerDetailsContent extends StatelessWidget {
  const _WagerDetailsContent({
    required this.wager,
    required this.membersById,
    required this.userId,
  });

  final Wager wager;
  final Map<String, GroupMember> membersById;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myStake = userId == null
        ? null
        : wager.stakes.where((stake) => stake.userId == userId).firstOrNull;

    return AppRefreshIndicator(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _SummaryCard(wager: wager),
          if (myStake != null) ...[
            const SizedBox(height: 12),
            _MyStakeCard(wager: wager, stake: myStake),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.wagerArchiveStakes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (wager.stakes.isEmpty)
                    Text(
                      l10n.wagerDetailsNoStakes,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (final stake in wager.stakes)
                      _StakeDetailTile(
                        wager: wager,
                        stake: stake,
                        member: membersById[stake.userId],
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.wager});

  final Wager wager;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final winningSide = wager.winningSide;
    final winningLabel = winningSide == null ? null : _labelFor(winningSide);
    final winningPool =
        wager.settlement?.winningSideTotal ??
        (winningSide == null ? 0 : wager.totalForSide(winningSide));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  wager.status == WagerStatus.resolved
                      ? Icons.verified_rounded
                      : wager.status == WagerStatus.cancelled
                      ? Icons.cancel_rounded
                      : Icons.hourglass_top_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    wager.status == WagerStatus.resolved
                        ? l10n.wagerDetailsStatusResolved
                        : wager.status == WagerStatus.cancelled
                        ? l10n.wagerDetailsStatusCancelled
                        : l10n.wagerDetailsStatusActive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              wager.condition,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (winningLabel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Chip(label: Text(l10n.wagerArchiveWinner(winningLabel))),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(label: l10n.wagerArchiveTotalPool(wager.totalPool)),
                _InfoPill(label: l10n.wagerArchiveWinningPool(winningPool)),
                _InfoPill(
                  label: l10n.wagerCreatedAt(
                    formatAppDateTime(context, wager.createdAt),
                  ),
                ),
                if (wager.status != WagerStatus.active)
                  _InfoPill(
                    label: l10n.wagerCompletedAt(
                      formatAppDateTime(
                        context,
                        wager.resolvedAt ?? wager.updatedAt,
                      ),
                    ),
                  ),
                _InfoPill(label: l10n.wagerRewardCoins(wager.rewardCoins)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(WagerSide side) {
    return switch (side) {
      WagerSide.left => wager.leftOption.label,
      WagerSide.right => wager.rightOption.label,
    };
  }
}

class _MyStakeCard extends StatelessWidget {
  const _MyStakeCard({required this.wager, required this.stake});

  final Wager wager;
  final Stake stake;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sideLabel = _labelFor(stake.side);
    final payout = _payoutFor(wager, stake);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Icon(
          Icons.account_balance_wallet_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(l10n.wagerDetailsMyStake),
        subtitle: Text(l10n.wagerArchiveStakeSide(sideLabel, stake.amount)),
        trailing:
            wager.status == WagerStatus.resolved ||
                wager.status == WagerStatus.cancelled
            ? Text(
                l10n.wagerArchivePayout(payout),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
      ),
    );
  }

  String _labelFor(WagerSide side) {
    return switch (side) {
      WagerSide.left => wager.leftOption.label,
      WagerSide.right => wager.rightOption.label,
    };
  }
}

class _StakeDetailTile extends StatelessWidget {
  const _StakeDetailTile({
    required this.wager,
    required this.stake,
    required this.member,
  });

  final Wager wager;
  final Stake stake;
  final GroupMember? member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = member?.displayName ?? l10n.profileUnnamed;
    final sideLabel = _labelFor(stake.side);
    final payout = _payoutFor(wager, stake);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: member?.avatarUrl == null
            ? null
            : NetworkImage(member!.avatarUrl!),
        child: member?.avatarUrl == null
            ? Text(displayName.characters.first)
            : null,
      ),
      title: Text(displayName),
      subtitle: Text(l10n.wagerArchiveStakeSide(sideLabel, stake.amount)),
      trailing:
          wager.status == WagerStatus.resolved ||
              wager.status == WagerStatus.cancelled
          ? Text(
              l10n.wagerArchivePayout(payout),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
    );
  }

  String _labelFor(WagerSide side) {
    return switch (side) {
      WagerSide.left => wager.leftOption.label,
      WagerSide.right => wager.rightOption.label,
    };
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

int _payoutFor(Wager wager, Stake stake) {
  if (wager.status != WagerStatus.resolved &&
      wager.status != WagerStatus.cancelled) {
    return 0;
  }

  final settlementPayout = wager.settlement?.payoutFor(stake.userId);
  if (settlementPayout != null) {
    return settlementPayout;
  }

  if (wager.winningSide != stake.side) {
    return 0;
  }

  return wager.rewardForSide(stake.side);
}
