import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/features/groups/domain/group_models.dart';
import 'package:point_rivals/features/wagers/domain/odds_calculator.dart';
import 'package:point_rivals/features/wagers/domain/wager_archive_filter.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class WagerArchivePage extends StatefulWidget {
  const WagerArchivePage({required this.groupId, super.key});

  final String groupId;

  @override
  State<WagerArchivePage> createState() => _WagerArchivePageState();
}

class _WagerArchivePageState extends State<WagerArchivePage> {
  final TextEditingController _searchController = TextEditingController();
  WagerArchiveStatusFilter _statusFilter = WagerArchiveStatusFilter.all;
  WagerArchiveSort _sort = WagerArchiveSort.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dependencies = AppDependenciesScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.wagerArchiveTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<List<GroupMember>>(
          stream: dependencies.groupRepository.watchMembers(widget.groupId),
          builder: (context, membersSnapshot) {
            final membersById = {
              for (final member
                  in membersSnapshot.data ?? const <GroupMember>[])
                member.userId: member,
            };

            return StreamBuilder<List<Wager>>(
              stream: dependencies.wagerRepository.watchArchivedWagers(
                widget.groupId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.authGenericError));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final wagers = snapshot.data!;
                final filteredWagers = WagerArchiveFilter(
                  query: _searchController.text,
                  status: _statusFilter,
                  sort: _sort,
                ).apply(wagers);

                if (wagers.isEmpty) {
                  return AppRefreshIndicator(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.55,
                          child: Center(child: Text(l10n.wagerArchiveEmpty)),
                        ),
                      ],
                    ),
                  );
                }

                return AppRefreshIndicator(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      _ArchiveControls(
                        searchController: _searchController,
                        statusFilter: _statusFilter,
                        sort: _sort,
                        resultCount: filteredWagers.length,
                        onSearchChanged: (_) => setState(() {}),
                        onStatusChanged: (value) {
                          setState(() => _statusFilter = value);
                        },
                        onSortChanged: (value) {
                          setState(() => _sort = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (filteredWagers.isEmpty)
                        _EmptyFilteredArchive(
                          icon: Icons.manage_search_rounded,
                          message: l10n.wagerArchiveFilteredEmpty,
                        )
                      else
                        for (final wager in filteredWagers) ...[
                          _ResolvedWagerCard(
                            groupId: widget.groupId,
                            wager: wager,
                            membersById: membersById,
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
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

class _ArchiveControls extends StatelessWidget {
  const _ArchiveControls({
    required this.searchController,
    required this.statusFilter,
    required this.sort,
    required this.resultCount,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final WagerArchiveStatusFilter statusFilter;
  final WagerArchiveSort sort;
  final int resultCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<WagerArchiveStatusFilter> onStatusChanged;
  final ValueChanged<WagerArchiveSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.wagerArchiveSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<WagerArchiveStatusFilter>(
          segments: [
            ButtonSegment(
              value: WagerArchiveStatusFilter.all,
              icon: const Icon(Icons.all_inclusive_rounded),
              label: Text(l10n.wagerArchiveFilterAll),
            ),
            ButtonSegment(
              value: WagerArchiveStatusFilter.resolved,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(l10n.wagerArchiveFilterResolved),
            ),
            ButtonSegment(
              value: WagerArchiveStatusFilter.cancelled,
              icon: const Icon(Icons.cancel_rounded),
              label: Text(l10n.wagerArchiveFilterCancelled),
            ),
          ],
          selected: {statusFilter},
          showSelectedIcon: false,
          onSelectionChanged: (values) => onStatusChanged(values.single),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<WagerArchiveSort>(
                initialValue: sort,
                decoration: InputDecoration(
                  labelText: l10n.wagerArchiveSortLabel,
                  prefixIcon: const Icon(Icons.sort_rounded),
                ),
                items: [
                  DropdownMenuItem(
                    value: WagerArchiveSort.newest,
                    child: Text(l10n.wagerArchiveSortNewest),
                  ),
                  DropdownMenuItem(
                    value: WagerArchiveSort.largestPool,
                    child: Text(l10n.wagerArchiveSortLargestPool),
                  ),
                  DropdownMenuItem(
                    value: WagerArchiveSort.mostStakes,
                    child: Text(l10n.wagerArchiveSortMostStakes),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Chip(label: Text(l10n.wagerArchiveResultCount(resultCount))),
          ],
        ),
      ],
    );
  }
}

class _EmptyFilteredArchive extends StatelessWidget {
  const _EmptyFilteredArchive({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          children: [
            Icon(
              icon,
              size: 34,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedWagerCard extends StatelessWidget {
  const _ResolvedWagerCard({
    required this.groupId,
    required this.wager,
    required this.membersById,
  });

  final String groupId;
  final Wager wager;
  final Map<String, GroupMember> membersById;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final winningSide = wager.winningSide;
    final winnerLabel = winningSide == null
        ? ''
        : _labelForSide(wager, winningSide);
    final winningSideTotal = winningSide == null
        ? 0
        : wager.totalForSide(winningSide);

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.wagerDetails(groupId, wager.id)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _ArchiveStatusIcon(status: wager.status),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      wager.condition,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (winningSide != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Chip(
                    label: Text(l10n.wagerArchiveWinner(winnerLabel)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    icon: Icons.savings_rounded,
                    label: l10n.wagerArchiveTotalPool(wager.totalPool),
                  ),
                  _MetricChip(
                    icon: Icons.emoji_events_rounded,
                    label: l10n.wagerArchiveWinningPool(winningSideTotal),
                  ),
                ],
              ),
              if (wager.stakes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.wagerArchiveStakes,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                for (final stake in wager.stakes)
                  _StakeResultTile(
                    wager: wager,
                    stake: stake,
                    displayName:
                        membersById[stake.userId]?.displayName ??
                        l10n.profileUnnamed,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _labelForSide(Wager wager, WagerSide side) {
    return switch (side) {
      WagerSide.left => wager.leftOption.label,
      WagerSide.right => wager.rightOption.label,
    };
  }
}

class _ArchiveStatusIcon extends StatelessWidget {
  const _ArchiveStatusIcon({required this.status});

  final WagerStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = status == WagerStatus.cancelled
        ? colors.onSurfaceVariant
        : colors.primary;
    final icon = status == WagerStatus.cancelled
        ? Icons.cancel_rounded
        : Icons.check_circle_rounded;

    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
      child: Icon(icon, size: 20),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}

class _StakeResultTile extends StatelessWidget {
  const _StakeResultTile({
    required this.wager,
    required this.stake,
    required this.displayName,
  });

  final Wager wager;
  final Stake stake;
  final String displayName;
  static const OddsCalculator _oddsCalculator = OddsCalculator();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sideLabel = switch (stake.side) {
      WagerSide.left => wager.leftOption.label,
      WagerSide.right => wager.rightOption.label,
    };
    final payout = wager.status == WagerStatus.cancelled
        ? wager.settlement?.payoutFor(stake.userId) ?? stake.amount
        : wager.winningSide == stake.side
        ? wager.settlement?.payoutFor(stake.userId) ??
              _oddsCalculator.payoutForStake(wager: wager, winningStake: stake)
        : 0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.10),
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: Text(displayName.characters.first),
      ),
      title: Text(displayName),
      subtitle: Text(l10n.wagerArchiveStakeSide(sideLabel, stake.amount)),
      trailing: Text(
        l10n.wagerArchivePayout(payout),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
