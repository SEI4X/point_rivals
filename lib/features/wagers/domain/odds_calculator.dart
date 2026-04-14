import 'package:point_rivals/features/wagers/domain/wager_models.dart';

final class OddsCalculator {
  const OddsCalculator();

  static const double _openingOdds = 2;
  static const double _minimumOdds = 1.1;
  static const double _maximumOdds = 5;
  static const int _minimumVirtualPool = 100;

  double oddsForSide(Wager wager, WagerSide side) {
    final int sideTotal = wager.totalForSide(side);
    final int totalPool = wager.totalPool;
    if (totalPool == 0) {
      return _openingOdds;
    }

    final virtualSidePool = totalPool > _minimumVirtualPool
        ? totalPool.toDouble()
        : _minimumVirtualPool.toDouble();
    final virtualTotalPool = virtualSidePool * 2;
    final odds = (totalPool + virtualTotalPool) / (sideTotal + virtualSidePool);
    return odds.clamp(_minimumOdds, _maximumOdds);
  }

  int payoutForStake({required Wager wager, required Stake winningStake}) {
    final double odds =
        winningStake.odds ?? oddsForSide(wager, winningStake.side);
    return (winningStake.amount * odds).floor();
  }
}
