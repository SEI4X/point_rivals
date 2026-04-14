import 'package:point_rivals/features/wagers/domain/wager_models.dart';

enum WagerArchiveStatusFilter { all, resolved, cancelled }

enum WagerArchiveSort { newest, largestPool, mostStakes }

final class WagerArchiveFilter {
  const WagerArchiveFilter({
    this.query = '',
    this.status = WagerArchiveStatusFilter.all,
    this.sort = WagerArchiveSort.newest,
  });

  final String query;
  final WagerArchiveStatusFilter status;
  final WagerArchiveSort sort;

  List<Wager> apply(List<Wager> wagers) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = wagers.where((wager) {
      if (!_matchesStatus(wager)) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return _searchableText(wager).contains(normalizedQuery);
    }).toList();

    return switch (sort) {
      WagerArchiveSort.newest => filtered,
      WagerArchiveSort.largestPool =>
        filtered..sort((left, right) {
          final poolComparison = right.totalPool.compareTo(left.totalPool);
          if (poolComparison != 0) {
            return poolComparison;
          }

          return left.condition.compareTo(right.condition);
        }),
      WagerArchiveSort.mostStakes =>
        filtered..sort((left, right) {
          final stakeComparison = right.stakes.length.compareTo(
            left.stakes.length,
          );
          if (stakeComparison != 0) {
            return stakeComparison;
          }

          return left.condition.compareTo(right.condition);
        }),
    };
  }

  bool _matchesStatus(Wager wager) {
    return switch (status) {
      WagerArchiveStatusFilter.all => true,
      WagerArchiveStatusFilter.resolved => wager.status == WagerStatus.resolved,
      WagerArchiveStatusFilter.cancelled =>
        wager.status == WagerStatus.cancelled,
    };
  }

  String _searchableText(Wager wager) {
    return [
      wager.condition,
      wager.leftOption.label,
      wager.rightOption.label,
    ].join(' ').toLowerCase();
  }
}
