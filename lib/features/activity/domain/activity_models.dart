enum ActivityType { newWager, wagerResolved, wagerCancelled }

final class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.groupId,
    required this.wagerId,
    required this.groupName,
    required this.condition,
    required this.payout,
    required this.createdAt,
  });

  final String id;
  final ActivityType type;
  final String groupId;
  final String wagerId;
  final String groupName;
  final String condition;
  final int payout;
  final DateTime? createdAt;
}
