enum TaskStatus { active, completed }

final class RivalTask {
  const RivalTask({
    required this.id,
    required this.groupId,
    required this.creatorUserId,
    required this.title,
    required this.description,
    required this.assignedUserId,
    required this.rewardPoints,
    required this.dueAt,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    required this.updatedAt,
  });

  final String id;
  final String groupId;
  final String creatorUserId;
  final String title;
  final String description;
  final String? assignedUserId;
  final int rewardPoints;
  final DateTime? dueAt;
  final TaskStatus status;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  bool get isUnassigned => assignedUserId == null || assignedUserId!.isEmpty;

  bool canAssignSelf(String userId) {
    return status == TaskStatus.active && isUnassigned && userId.isNotEmpty;
  }
}

final class TaskDraft {
  const TaskDraft({
    required this.groupId,
    required this.creatorUserId,
    required this.title,
    required this.description,
    required this.assignedUserId,
    required this.rewardPoints,
    required this.dueAt,
  }) : assert(rewardPoints > 0, 'Reward points must be positive.');

  final String groupId;
  final String creatorUserId;
  final String title;
  final String description;
  final String? assignedUserId;
  final int rewardPoints;
  final DateTime? dueAt;

  RivalTask toTask({required String id}) {
    return RivalTask(
      id: id,
      groupId: groupId,
      creatorUserId: creatorUserId,
      title: title,
      description: description,
      assignedUserId: assignedUserId,
      rewardPoints: rewardPoints,
      dueAt: dueAt,
      status: TaskStatus.active,
      createdAt: null,
      completedAt: null,
      updatedAt: null,
    );
  }
}
