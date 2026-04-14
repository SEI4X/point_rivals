import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/wagers/data/mappers/stake_mapper.dart';
import 'package:point_rivals/features/wagers/data/mappers/wager_mapper.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

class FirebaseWagerRepository implements WagerRepository {
  FirebaseWagerRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  static const int _groupWagersLimit = 80;
  static const int _activeWagersLimit = 30;
  static const int _archiveWagersLimit = 50;
  static const int _userWagersLimit = 80;
  static const int _stakesPerWagerLimit = 100;

  @override
  Stream<Wager> watchWager({required String groupId, required String wagerId}) {
    final wagerReference = _wagersCollection(groupId).doc(wagerId);
    return wagerReference.snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      if (data == null) {
        throw StateError('Wager was not found.');
      }

      final stakesSnapshot = await wagerReference
          .collection(FirestoreCollections.stakes)
          .get();
      final stakes = stakesSnapshot.docs.map((stakeDocument) {
        return StakeMapper.fromFirestore(
          userId: stakeDocument.id,
          data: stakeDocument.data(),
        );
      }).toList();

      return WagerMapper.fromFirestore(
        id: snapshot.id,
        data: data,
        stakes: stakes,
      );
    });
  }

  @override
  Stream<List<Wager>> watchGroupWagers(String groupId) {
    return _wagersCollection(groupId)
        .where(
          'status',
          whereIn: [
            WagerStatus.active.name,
            WagerStatus.resolved.name,
            WagerStatus.cancelled.name,
          ],
        )
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .limit(_groupWagersLimit)
        .snapshots()
        .asyncMap(_wagersFromSnapshot);
  }

  @override
  Stream<List<Wager>> watchActiveWagers(String groupId) {
    return _watchWagersByStatus(
      groupId,
      WagerStatus.active,
      orderByField: FirestoreFields.createdAt,
    );
  }

  @override
  Stream<List<Wager>> watchResolvedWagers(String groupId) {
    return _watchWagersByStatus(
      groupId,
      WagerStatus.resolved,
      orderByField: FirestoreFields.updatedAt,
    );
  }

  @override
  Stream<List<Wager>> watchArchivedWagers(String groupId) {
    return _wagersCollection(groupId)
        .where(
          'status',
          whereIn: [WagerStatus.resolved.name, WagerStatus.cancelled.name],
        )
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .limit(_archiveWagersLimit)
        .snapshots()
        .asyncMap(_wagersFromSnapshot);
  }

  @override
  Stream<List<Wager>> watchUserWagers(String userId) {
    return _firestore
        .collectionGroup(FirestoreCollections.stakes)
        .where('userId', isEqualTo: userId)
        .limit(_userWagersLimit)
        .snapshots()
        .asyncMap((snapshot) async {
          final wagers = <Wager>[];
          final seenWagerIds = <String>{};

          for (final stakeDocument in snapshot.docs) {
            final wagerReference = stakeDocument.reference.parent.parent;
            if (wagerReference == null ||
                !seenWagerIds.add(wagerReference.path)) {
              continue;
            }

            final wagerSnapshot = await wagerReference.get();
            final wagerData = wagerSnapshot.data();
            if (wagerData == null) {
              continue;
            }

            final stakesSnapshot = await wagerReference
                .collection(FirestoreCollections.stakes)
                .limit(_stakesPerWagerLimit)
                .get();
            final stakes = stakesSnapshot.docs.map((document) {
              return StakeMapper.fromFirestore(
                userId: document.id,
                data: document.data(),
              );
            }).toList();

            wagers.add(
              WagerMapper.fromFirestore(
                id: wagerSnapshot.id,
                data: wagerData,
                stakes: stakes,
              ),
            );
          }

          wagers.sort((left, right) {
            if (left.status == right.status) {
              return left.condition.compareTo(right.condition);
            }

            return left.status == WagerStatus.active ? -1 : 1;
          });

          return wagers;
        });
  }

  Stream<List<Wager>> _watchWagersByStatus(
    String groupId,
    WagerStatus status, {
    required String orderByField,
  }) {
    return _wagersCollection(groupId)
        .where('status', isEqualTo: status.name)
        .orderBy(orderByField, descending: true)
        .limit(
          status == WagerStatus.active
              ? _activeWagersLimit
              : _archiveWagersLimit,
        )
        .snapshots()
        .asyncMap(_wagersFromSnapshot);
  }

  Future<List<Wager>> _wagersFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final wagers = <Wager>[];

    for (final wagerDocument in snapshot.docs) {
      final stakesSnapshot = await wagerDocument.reference
          .collection(FirestoreCollections.stakes)
          .limit(_stakesPerWagerLimit)
          .get();
      final stakes = stakesSnapshot.docs.map((stakeDocument) {
        return StakeMapper.fromFirestore(
          userId: stakeDocument.id,
          data: stakeDocument.data(),
        );
      }).toList();

      wagers.add(
        WagerMapper.fromFirestore(
          id: wagerDocument.id,
          data: wagerDocument.data(),
          stakes: stakes,
        ),
      );
    }

    return wagers;
  }

  @override
  Future<Wager> createWager(WagerDraft draft) async {
    final groupReference = _firestore
        .collection(FirestoreCollections.groups)
        .doc(draft.groupId);
    final wagerReference = groupReference
        .collection(FirestoreCollections.wagers)
        .doc();

    await _firestore.runTransaction((transaction) async {
      transaction.set(wagerReference, WagerMapper.draftToFirestore(draft));
      transaction.update(groupReference, {
        'activeWagerCount': FieldValue.increment(1),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    });

    return draft.toWager(id: wagerReference.id);
  }

  @override
  Future<void> placeStake({
    required String groupId,
    required String wagerId,
    required Stake stake,
  }) async {
    final callable = _functions.httpsCallable('placeStake');
    await callable.call<void>({
      'groupId': groupId,
      'wagerId': wagerId,
      'side': stake.side.name,
      'amount': stake.amount,
    });
  }

  @override
  Future<void> resolveWager({
    required String groupId,
    required String wagerId,
    required WagerSide winningSide,
    required String adminUserId,
  }) async {
    final callable = _functions.httpsCallable('resolveWager');
    await callable.call<void>({
      'groupId': groupId,
      'wagerId': wagerId,
      'winningSide': winningSide.name,
    });
  }

  @override
  Future<void> cancelWager({
    required String groupId,
    required String wagerId,
    required String adminUserId,
  }) async {
    final callable = _functions.httpsCallable('cancelWager');
    await callable.call<void>({'groupId': groupId, 'wagerId': wagerId});
  }

  CollectionReference<Map<String, dynamic>> _wagersCollection(String groupId) {
    return _firestore
        .collection(FirestoreCollections.groups)
        .doc(groupId)
        .collection(FirestoreCollections.wagers);
  }
}
