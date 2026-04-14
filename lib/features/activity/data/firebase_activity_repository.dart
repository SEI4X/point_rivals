import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/activity/data/activity_mapper.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';

class FirebaseActivityRepository implements ActivityRepository {
  FirebaseActivityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ActivityItem>> watchUserActivities(String userId) {
    return _firestore
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
        });
  }
}
