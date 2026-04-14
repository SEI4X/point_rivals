import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/tasks/data/mappers/task_mapper.dart';
import 'package:point_rivals/features/tasks/domain/task_models.dart';

void main() {
  test('maps task documents with optional fields', () {
    final task = TaskMapper.fromFirestore(
      id: 'task-1',
      data: const {
        'groupId': 'group-1',
        'creatorUserId': 'creator-1',
        'title': 'Bring match balls',
        'description': '',
        'assignedUserId': '',
        'rewardPoints': 25,
        'status': 'active',
      },
    );

    expect(task.id, 'task-1');
    expect(task.assignedUserId, isNull);
    expect(task.rewardPoints, 25);
    expect(task.status, TaskStatus.active);
  });
}
