import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';

abstract final class ActivityMapper {
  static ActivityItem fromFirestore({
    required String id,
    required Map<String, Object?> data,
  }) {
    return ActivityItem(
      id: id,
      type: _type(data['type']),
      groupId: _string(data['groupId']) ?? '',
      wagerId: _string(data['wagerId']) ?? '',
      groupName: _string(data['groupName']) ?? '',
      condition: _string(data['condition']) ?? '',
      payout: _int(data['payout']),
      createdAt: _dateTime(data['createdAt']),
    );
  }

  static ActivityType _type(Object? value) {
    return ActivityType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ActivityType.newWager,
    );
  }

  static String? _string(Object? value) => value is String ? value : null;

  static int _int(Object? value) => value is int ? value : 0;

  static DateTime? _dateTime(Object? value) {
    return value is Timestamp ? value.toDate() : null;
  }
}
