import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/tasks/domain/task_models.dart';

void main() {
  test('allows self assignment only for active unassigned tasks', () {
    const task = RivalTask(
      id: 'task-1',
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      title: 'Bring match balls',
      description: '',
      assignedUserId: null,
      rewardPoints: 20,
      dueAt: null,
      status: TaskStatus.active,
      createdAt: null,
      completedAt: null,
      updatedAt: null,
    );

    expect(task.canAssignSelf('user-1'), isTrue);
    expect(task.canAssignSelf(''), isFalse);
  });

  test('blocks self assignment after a task has an assignee', () {
    const task = RivalTask(
      id: 'task-1',
      groupId: 'group-1',
      creatorUserId: 'creator-1',
      title: 'Bring match balls',
      description: '',
      assignedUserId: 'user-2',
      rewardPoints: 20,
      dueAt: null,
      status: TaskStatus.active,
      createdAt: null,
      completedAt: null,
      updatedAt: null,
    );

    expect(task.canAssignSelf('user-1'), isFalse);
  });
}
