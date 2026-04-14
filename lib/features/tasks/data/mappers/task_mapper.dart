import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/tasks/domain/task_models.dart';

abstract final class TaskMapper {
  static RivalTask fromFirestore({
    required String id,
    required Map<String, Object?> data,
  }) {
    return RivalTask(
      id: id,
      groupId: _string(data['groupId']) ?? '',
      creatorUserId: _string(data['creatorUserId']) ?? '',
      title: _string(data['title']) ?? '',
      description: _string(data['description']) ?? '',
      assignedUserId: _emptyToNull(_string(data['assignedUserId'])),
      rewardPoints: _positiveInt(data['rewardPoints'], 10),
      dueAt: _dateTime(data['dueAt']),
      status: _enumValue(TaskStatus.values, data['status'], TaskStatus.active),
      createdAt: _dateTime(data['createdAt']),
      completedAt: _dateTime(data['completedAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static Map<String, Object?> draftToFirestore(TaskDraft draft) {
    return {
      'groupId': draft.groupId,
      'creatorUserId': draft.creatorUserId,
      'title': draft.title,
      'description': draft.description,
      'assignedUserId': draft.assignedUserId,
      'rewardPoints': draft.rewardPoints,
      'dueAt': draft.dueAt == null ? null : Timestamp.fromDate(draft.dueAt!),
      'status': TaskStatus.active.name,
      'notifications': {'assignedSent': false},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String? _string(Object? value) => value is String ? value : null;

  static String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value;
  }

  static int _positiveInt(Object? value, int fallback) {
    return value is int && value > 0 ? value : fallback;
  }

  static DateTime? _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? value,
    T fallback,
  ) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => fallback,
    );
  }
}
