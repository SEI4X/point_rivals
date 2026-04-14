enum ActivityType { newWager, wagerResolved, wagerCancelled, taskCompleted }

final class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.groupId,
    required this.wagerId,
    required this.taskId,
    required this.groupName,
    required this.condition,
    required this.taskTitle,
    required this.payout,
    required this.createdAt,
  });

  final String id;
  final ActivityType type;
  final String groupId;
  final String wagerId;
  final String taskId;
  final String groupName;
  final String condition;
  final String taskTitle;
  final int payout;
  final DateTime? createdAt;
}
