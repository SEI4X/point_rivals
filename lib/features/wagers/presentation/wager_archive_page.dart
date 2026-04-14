import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/core/routing/app_router.dart';
import 'package:point_rivals/core/widgets/app_refresh_indicator.dart';
import 'package:point_rivals/core/widgets/app_shimmer.dart';
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
    final refreshRevision = AppRefreshScope.revisionOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.wagerArchiveTitle),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<List<Wager>>(
          key: ValueKey('wager-archive-${widget.groupId}-$refreshRevision'),
          stream: dependencies.wagerRepository.watchArchivedWagers(
            widget.groupId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.authGenericError));
            }

            final wagers = snapshot.data ?? const <Wager>[];
            final filteredWagers = WagerArchiveFilter(
              query: _searchController.text,
              status: _statusFilter,
              sort: _sort,
            ).apply(wagers);

            return AppLoadingSwitcher(
              isLoading: !snapshot.hasData,
              loading: const AppSkeletonList(showHeader: true),
              child: wagers.isEmpty
                  ? AppRefreshIndicator(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.55,
                            child: Center(child: Text(l10n.wagerArchiveEmpty)),
                          ),
                        ],
                      ),
                    )
                  : AppRefreshIndicator(
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
                              ),
                              const SizedBox(height: 12),
                            ],
                        ],
                      ),
                    ),
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
        _ArchiveStatusFilterControl(
          value: statusFilter,
          onChanged: onStatusChanged,
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

class _ArchiveStatusFilterControl extends StatelessWidget {
  const _ArchiveStatusFilterControl({
    required this.value,
    required this.onChanged,
  });

  final WagerArchiveStatusFilter value;
  final ValueChanged<WagerArchiveStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _ArchiveStatusFilterItem(
              flex: 2,
              label: l10n.wagerArchiveFilterAll,
              icon: Icons.all_inclusive_rounded,
              isSelected: value == WagerArchiveStatusFilter.all,
              onTap: () => onChanged(WagerArchiveStatusFilter.all),
            ),
            _ArchiveStatusFilterItem(
              flex: 3,
              label: l10n.wagerArchiveFilterResolved,
              icon: Icons.check_circle_rounded,
              isSelected: value == WagerArchiveStatusFilter.resolved,
              onTap: () => onChanged(WagerArchiveStatusFilter.resolved),
            ),
            _ArchiveStatusFilterItem(
              flex: 3,
              label: l10n.wagerArchiveFilterCancelled,
              icon: Icons.cancel_rounded,
              isSelected: value == WagerArchiveStatusFilter.cancelled,
              onTap: () => onChanged(WagerArchiveStatusFilter.cancelled),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveStatusFilterItem extends StatelessWidget {
  const _ArchiveStatusFilterItem({
    required this.flex,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final int flex;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Expanded(
      flex: flex,
      child: Semantics(
        selected: isSelected,
        button: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: foregroundColor),
                    const SizedBox(width: 5),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: foregroundColor,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
  const _ResolvedWagerCard({required this.groupId, required this.wager});

  final String groupId;
  final Wager wager;

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
