import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/wagers/domain/wager_models.dart';

abstract final class WagerMapper {
  static Wager fromFirestore({
    required String id,
    required Map<String, Object?> data,
    List<Stake> stakes = const [],
  }) {
    return Wager(
      id: id,
      groupId: _string(data['groupId']) ?? '',
      creatorUserId: _string(data['creatorUserId']) ?? '',
      condition: _string(data['condition']) ?? '',
      type: _enumValue(WagerType.values, data['type'], WagerType.yesNo),
      leftOption: WagerOption(
        side: WagerSide.left,
        label: _string(data['leftLabel']) ?? '',
      ),
      rightOption: WagerOption(
        side: WagerSide.right,
        label: _string(data['rightLabel']) ?? '',
      ),
      excludedUserIds: _stringSet(data['excludedUserIds']),
      stakes: stakes,
      status: _enumValue(
        WagerStatus.values,
        data['status'],
        WagerStatus.active,
      ),
      winningSide: _nullableEnumValue(WagerSide.values, data['winningSide']),
      settlement: _settlement(data['settlement']),
      createdAt: _dateTime(data['createdAt']),
      resolvedAt: _dateTime(data['resolvedAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static Map<String, Object?> toFirestore(Wager wager) {
    return {
      'groupId': wager.groupId,
      'creatorUserId': wager.creatorUserId,
      'condition': wager.condition,
      'type': wager.type.name,
      'leftLabel': wager.leftOption.label,
      'rightLabel': wager.rightOption.label,
      'excludedUserIds': wager.excludedUserIds.toList()..sort(),
      'status': wager.status.name,
      'winningSide': wager.winningSide?.name,
      'settlement': wager.settlement == null
          ? null
          : {
              'totalPool': wager.settlement!.totalPool,
              'winningSideTotal': wager.settlement!.winningSideTotal,
              'payouts': wager.settlement!.payouts,
            },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object?> draftToFirestore(WagerDraft draft) {
    return {
      'groupId': draft.groupId,
      'creatorUserId': draft.creatorUserId,
      'condition': draft.condition,
      'type': draft.type.name,
      'leftLabel': draft.leftOption.label,
      'rightLabel': draft.rightOption.label,
      'excludedUserIds': draft.excludedUserIds.toList()..sort(),
      'status': WagerStatus.active.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String? _string(Object? value) => value is String ? value : null;

  static Set<String> _stringSet(Object? value) {
    if (value is! List<Object?>) {
      return const {};
    }

    return value.whereType<String>().toSet();
  }

  static WagerSettlement? _settlement(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return null;
    }

    return WagerSettlement(
      totalPool: _int(value['totalPool']),
      winningSideTotal: _int(value['winningSideTotal']),
      payouts: _intMap(value['payouts']),
    );
  }

  static Map<String, int> _intMap(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return const {};
    }

    return {
      for (final entry in value.entries)
        if (entry.key is String && entry.value is int)
          entry.key! as String: entry.value! as int,
    };
  }

  static int _int(Object? value) => value is int ? value : 0;

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

  static T? _nullableEnumValue<T extends Enum>(List<T> values, Object? value) {
    if (value == null) {
      return null;
    }

    for (final item in values) {
      if (item.name == value) {
        return item;
      }
    }

    return null;
  }
}
