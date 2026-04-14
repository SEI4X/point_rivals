import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/activity/data/activity_mapper.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';

class FirebaseActivityRepository implements ActivityRepository {
  FirebaseActivityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Map<String, _CachedActivityListStream> _userActivityStreams = {};

  @override
  Stream<List<ActivityItem>> watchUserActivities(String userId) {
    return _userActivityStreams
        .putIfAbsent(
          userId,
          () => _CachedActivityListStream(
            _firestore
                .collection(FirestoreCollections.users)
                .doc(userId)
                .collection(FirestoreCollections.activities)
                .orderBy(FirestoreFields.createdAt, descending: true)
                .limit(50)
                .snapshots()
                .map((snapshot) {
                  return snapshot.docs.map((document) {
                    return ActivityMapper.fromFirestore(
                      id: document.id,
                      data: document.data(),
                    );
                  }).toList();
                }),
          ),
        )
        .watch();
  }
}

class _CachedActivityListStream {
  _CachedActivityListStream(Stream<List<ActivityItem>> source) {
    _subscription = source.listen((activities) {
      _latest = activities;
      _controller.add(activities);
    }, onError: _controller.addError);
  }

  final StreamController<List<ActivityItem>> _controller =
      StreamController<List<ActivityItem>>.broadcast();
  late final StreamSubscription<List<ActivityItem>> _subscription;
  List<ActivityItem>? _latest;

  Stream<List<ActivityItem>> watch() async* {
    final latest = _latest;
    if (latest != null) {
      yield latest;
    }

    yield* _controller.stream;
  }

  Future<void> close() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
