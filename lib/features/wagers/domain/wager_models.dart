enum WagerType { yesNo, participantVsParticipant, custom }

enum WagerSide { left, right }

enum WagerStatus { active, resolved, cancelled }

final class WagerOption {
  const WagerOption({required this.side, required this.label});

  final WagerSide side;
  final String label;
}

final class Stake {
  const Stake({
    required this.userId,
    required this.side,
    required this.amount,
    this.odds,
  }) : assert(amount > 0, 'Stake amount must be positive.'),
       assert(odds == null || odds > 0, 'Stake odds must be positive.');

  final String userId;
  final WagerSide side;
  final int amount;
  final double? odds;
}

final class Wager {
  const Wager({
    required this.id,
    required this.groupId,
    required this.creatorUserId,
    required this.condition,
    required this.type,
    required this.leftOption,
    required this.rightOption,
    required this.excludedUserIds,
    required this.stakes,
    required this.status,
    required this.winningSide,
    required this.settlement,
    required this.createdAt,
    required this.resolvedAt,
    required this.updatedAt,
  });

  final String id;
  final String groupId;
  final String creatorUserId;
  final String condition;
  final WagerType type;
  final WagerOption leftOption;
  final WagerOption rightOption;
  final Set<String> excludedUserIds;
  final List<Stake> stakes;
  final WagerStatus status;
  final WagerSide? winningSide;
  final WagerSettlement? settlement;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final DateTime? updatedAt;

  int totalForSide(WagerSide side) => stakes
      .where((stake) => stake.side == side)
      .fold(0, (total, stake) => total + stake.amount);

  int get totalPool => stakes.fold(0, (total, stake) => total + stake.amount);

  int stakeCountForSide(WagerSide side) =>
      stakes.where((stake) => stake.side == side).length;

  bool hasStakeFrom(String userId) {
    return stakes.any((stake) => stake.userId == userId);
  }

  bool canUserStake(String userId) {
    return status == WagerStatus.active &&
        !excludedUserIds.contains(userId) &&
        !hasStakeFrom(userId);
  }
}

final class WagerDraft {
  WagerDraft({
    required this.groupId,
    required this.creatorUserId,
    required this.condition,
    required this.type,
    required this.leftOption,
    required this.rightOption,
    required Set<String> excludedUserIds,
  }) : excludedUserIds = Set.unmodifiable(excludedUserIds);

  final String groupId;
  final String creatorUserId;
  final String condition;
  final WagerType type;
  final WagerOption leftOption;
  final WagerOption rightOption;
  final Set<String> excludedUserIds;

  Wager toWager({required String id}) {
    return Wager(
      id: id,
      groupId: groupId,
      creatorUserId: creatorUserId,
      condition: condition,
      type: type,
      leftOption: leftOption,
      rightOption: rightOption,
      excludedUserIds: excludedUserIds,
      stakes: const [],
      status: WagerStatus.active,
      winningSide: null,
      settlement: null,
      createdAt: null,
      resolvedAt: null,
      updatedAt: null,
    );
  }
}

final class WagerSettlement {
  const WagerSettlement({
    required this.totalPool,
    required this.winningSideTotal,
    required this.payouts,
  });

  final int totalPool;
  final int winningSideTotal;
  final Map<String, int> payouts;

  int payoutFor(String userId) => payouts[userId] ?? 0;
}
