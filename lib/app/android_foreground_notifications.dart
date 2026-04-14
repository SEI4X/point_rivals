import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';

const _androidNotificationChannelId = 'point_rivals_alerts';
const _androidNotificationIcon = 'ic_notification';

final class AndroidForegroundNotifications {
  AndroidForegroundNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int _nextNotificationId = 1;

  Future<void> initialize({required ValueChanged<String> onOpenGroup}) async {
    if (!_supportsAndroidNotifications || _initialized) {
      return;
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidNotificationIcon),
      ),
      onDidReceiveNotificationResponse: (response) {
        final groupId = response.payload;
        if (groupId != null && groupId.isNotEmpty) {
          onOpenGroup(groupId);
        }
      },
    );
    _initialized = true;
  }

  Future<void> show({
    required IncomingNotification notification,
    required String channelName,
    required ValueChanged<String> onOpenGroup,
  }) async {
    if (!_supportsAndroidNotifications) {
      return;
    }

    await initialize(onOpenGroup: onOpenGroup);
    await _plugin.show(
      id: _nextNotificationId++,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidNotificationChannelId,
          channelName,
          icon: _androidNotificationIcon,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
        ),
      ),
      payload: notification.groupId,
    );
  }

  bool get _supportsAndroidNotifications {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }
}
