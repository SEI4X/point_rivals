import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

final class FirebasePublicProfileRepository implements PublicProfileRepository {
  FirebasePublicProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) {
            return null;
          }

          return UserProfileMapper.fromFirestore(id: snapshot.id, data: data);
        });
  }
}
