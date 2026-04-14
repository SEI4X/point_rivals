import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

abstract final class StakeMapper {
  static Stake fromFirestore({
    required String userId,
    required Map<String, Object?> data,
  }) {
    return Stake(
      userId: userId,
      side: _side(data['side']),
      amount: _int(data['amount']),
      odds: _double(data['odds']),
    );
  }

  static Map<String, Object?> toFirestore(Stake stake) {
    return {
      'userId': stake.userId,
      'side': stake.side.name,
      'amount': stake.amount,
      if (stake.odds != null) 'odds': stake.odds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static int _int(Object? value) => value is int ? value : 0;

  static double? _double(Object? value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }

    return null;
  }

  static WagerSide _side(Object? value) {
    return WagerSide.values.firstWhere(
      (side) => side.name == value,
      orElse: () => WagerSide.left,
    );
  }
}
