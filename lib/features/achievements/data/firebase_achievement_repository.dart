import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/achievements/domain/achievement_models.dart';

class FirebaseAchievementRepository implements AchievementRepository {
  FirebaseAchievementRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<Set<AchievementId>> watchEarnedAchievements(String userId) {
    return _achievementCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((document) => _achievementId(document.id))
          .nonNulls
          .toSet();
    });
  }

  @override
  Future<List<AchievementId>> syncEarnedAchievements({
    required String userId,
    required List<AchievementCardModel> cards,
  }) async {
    final earnedCards = cards.where((card) => card.isCurrentlyEarned).toList();
    if (earnedCards.isEmpty) {
      return const [];
    }

    final collection = _achievementCollection(userId);
    final snapshot = await collection.get();
    final existingIds = snapshot.docs.map((document) => document.id).toSet();
    final missingCards = earnedCards.where((card) {
      return !existingIds.contains(card.id.name);
    }).toList();
    if (missingCards.isEmpty) {
      return const [];
    }

    final batch = _firestore.batch();
    for (final card in missingCards) {
      batch.set(collection.doc(card.id.name), {
        'id': card.id.name,
        'earnedAt': FieldValue.serverTimestamp(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return missingCards.map((card) => card.id).toList();
  }

  CollectionReference<Map<String, dynamic>> _achievementCollection(
    String userId,
  ) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.achievements);
  }

  AchievementId? _achievementId(String value) {
    for (final id in AchievementId.values) {
      if (id.name == value) {
        return id;
      }
    }

    return null;
  }
}
