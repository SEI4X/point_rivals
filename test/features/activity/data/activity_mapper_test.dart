import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/features/activity/data/activity_mapper.dart';
import 'package:point_rivals/features/activity/domain/activity_models.dart';

void main() {
  test('maps Firestore activity data to domain model', () {
    final createdAt = Timestamp.fromDate(DateTime.utc(2026, 4, 13));
    final activity = ActivityMapper.fromFirestore(
      id: 'activity-1',
      data: {
        'type': 'wagerResolved',
        'groupId': 'group-1',
        'wagerId': 'wager-1',
        'groupName': 'Morning rivals',
        'condition': 'Who finishes first?',
        'payout': 120,
        'createdAt': createdAt,
      },
    );

    expect(activity.id, 'activity-1');
    expect(activity.type, ActivityType.wagerResolved);
    expect(activity.groupId, 'group-1');
    expect(activity.wagerId, 'wager-1');
    expect(activity.groupName, 'Morning rivals');
    expect(activity.condition, 'Who finishes first?');
    expect(activity.payout, 120);
    expect(activity.createdAt, createdAt.toDate());
  });
}
