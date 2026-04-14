import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/tasks/data/mappers/task_mapper.dart';
import 'package:point_rivals/features/tasks/domain/task_models.dart';

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  static const int _activeTasksLimit = 50;
  static const int _userTasksLimit = 50;
  static const int _monthlyTasksLimit = 1000;
  final Map<String, _CachedTaskListStream> _activeTasksStreams = {};
  final Map<String, _CachedTaskListStream> _monthlyCompletedTasksStreams = {};
  final Map<String, _CachedTaskListStream> _userCompletedTasksStreams = {};

  @override
  Stream<RivalTask> watchTask({
    required String groupId,
    required String taskId,
  }) {
    return _tasksCollection(groupId).doc(taskId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        throw StateError('Task was not found.');
      }

      return TaskMapper.fromFirestore(id: snapshot.id, data: data);
    });
  }

  @override
  Stream<List<RivalTask>> watchActiveTasks(String groupId) {
    return _activeTasksStreams
        .putIfAbsent(
          groupId,
          () => _CachedTaskListStream(
            _tasksCollection(groupId)
                .where('status', isEqualTo: TaskStatus.active.name)
                .limit(_activeTasksLimit)
                .snapshots()
                .map(_tasksFromSnapshot),
          ),
        )
        .watch();
  }

  @override
  Stream<List<RivalTask>> watchUserCompletedTasks(String userId) {
    return _userCompletedTasksStreams
        .putIfAbsent(
          userId,
          () => _CachedTaskListStream(
            _firestore
                .collectionGroup(FirestoreCollections.tasks)
                .where('assignedUserId', isEqualTo: userId)
                .where('status', isEqualTo: TaskStatus.completed.name)
                .orderBy('completedAt', descending: true)
                .limit(_userTasksLimit)
                .snapshots()
                .map(_tasksFromSnapshot),
          ),
        )
        .watch();
  }

  @override
  Stream<List<RivalTask>> watchCompletedTasksSince({
    required String groupId,
    required DateTime since,
  }) {
    final start = DateTime.utc(since.year, since.month, since.day);
    final cacheKey = '$groupId-${start.toIso8601String()}';

    return _monthlyCompletedTasksStreams
        .putIfAbsent(
          cacheKey,
          () => _CachedTaskListStream(
            _tasksCollection(groupId)
                .where(
                  'completedAt',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(start),
                )
                .orderBy('completedAt', descending: true)
                .limit(_monthlyTasksLimit)
                .snapshots()
                .map(_completedTasksFromSnapshot),
          ),
        )
        .watch();
  }

  @override
  Future<RivalTask> createTask(TaskDraft draft) async {
    final callable = _functions.httpsCallable('createTask');
    final response = await callable.call<Map<Object?, Object?>>({
      'groupId': draft.groupId,
      'title': draft.title,
      'description': draft.description,
      'assignedUserId': draft.assignedUserId,
      'rewardPoints': draft.rewardPoints,
      'dueAt': draft.dueAt?.toUtc().toIso8601String(),
    });
    final taskId = response.data['taskId'];
    if (taskId is! String || taskId.isEmpty) {
      throw StateError('Task was created without an id.');
    }

    return draft.toTask(id: taskId);
  }

  @override
  Future<void> assignTaskToSelf({
    required String groupId,
    required String taskId,
    required String userId,
  }) async {
    final callable = _functions.httpsCallable('assignTaskToSelf');
    await callable.call<void>({'groupId': groupId, 'taskId': taskId});
  }

  @override
  Future<void> completeTask({
    required String groupId,
    required String taskId,
    required String adminUserId,
  }) async {
    final callable = _functions.httpsCallable('completeTask');
    await callable.call<void>({'groupId': groupId, 'taskId': taskId});
  }

  List<RivalTask> _tasksFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final tasks = snapshot.docs.map((document) {
      return TaskMapper.fromFirestore(id: document.id, data: document.data());
    }).toList();
    tasks.sort((left, right) {
      final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightDate =
          right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return rightDate.compareTo(leftDate);
    });

    return tasks;
  }

  List<RivalTask> _completedTasksFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return _tasksFromSnapshot(
      snapshot,
    ).where((task) => task.status == TaskStatus.completed).toList();
  }

  CollectionReference<Map<String, dynamic>> _tasksCollection(String groupId) {
    return _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .collection(FirestoreCollections.tasks);
  }
}

class _CachedTaskListStream {
  _CachedTaskListStream(Stream<List<RivalTask>> source) {
    _subscription = source.listen((tasks) {
      _latest = tasks;
      _controller.add(tasks);
    }, onError: _controller.addError);
  }

  final StreamController<List<RivalTask>> _controller =
      StreamController<List<RivalTask>>.broadcast();
  late final StreamSubscription<List<RivalTask>> _subscription;
  List<RivalTask>? _latest;

  Stream<List<RivalTask>> watch() async* {
    final latest = _latest;
    if (latest != null) {
      yield latest;
    }

    yield* _controller.stream;
  }

  // Kept for future repository disposal when app-wide dependencies become
  // explicitly disposable.
  Future<void> close() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
