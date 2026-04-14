import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _tokenRefreshUserId;

  @override
  Future<bool> requestPermission() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final settings = await _messaging.requestPermission();

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<void> registerDeviceToken(String userId) async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final token = await _readMessagingToken();
    if (token == null) {
      return;
    }

    await _saveDeviceToken(userId: userId, token: token);
    _listenForTokenRefresh(userId);
  }

  Future<String?> _readMessagingToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      for (var attempt = 0; attempt < 10; attempt += 1) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          break;
        }

        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }

    try {
      return await _messaging.getToken();
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('FCM token was not available: ${error.code}');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> unregisterDeviceToken(String userId) async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _tokenRefreshUserId = null;

    final token = await _messaging.getToken();
    if (token == null) {
      return;
    }

    await _deviceTokenDocument(userId: userId, token: token).delete();
  }

  Future<void> _saveDeviceToken({
    required String userId,
    required String token,
  }) async {
    await _deviceTokenDocument(userId: userId, token: token).set({
      'token': token,
      'locale': _notificationLocale(),
      'platform': _notificationPlatform(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _deviceTokenDocument({
    required String userId,
    required String token,
  }) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.deviceTokens)
        .doc(token);
  }

  void _listenForTokenRefresh(String userId) {
    if (_tokenRefreshUserId == userId && _tokenRefreshSubscription != null) {
      return;
    }

    unawaited(_tokenRefreshSubscription?.cancel());
    _tokenRefreshUserId = userId;
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      unawaited(_saveDeviceToken(userId: userId, token: token));
    });
  }

  @override
  Future<String?> initialNotificationGroupId() async {
    final message = await _messaging.getInitialMessage();
    return _groupIdFromMessage(message);
  }

  @override
  Stream<String> notificationGroupOpenRequests() {
    return FirebaseMessaging.onMessageOpenedApp
        .map(_groupIdFromMessage)
        .where((groupId) => groupId != null)
        .cast<String>();
  }

  @override
  Stream<IncomingNotification> foregroundNotifications() {
    return FirebaseMessaging.onMessage
        .map((message) {
          return IncomingNotification(
            groupId: _groupIdFromMessage(message),
            title: message.notification?.title ?? '',
            body: message.notification?.body ?? '',
          );
        })
        .where(
          (notification) =>
              notification.title.isNotEmpty || notification.body.isNotEmpty,
        );
  }

  @override
  Future<void> setNotificationsEnabled({
    required String userId,
    required bool enabled,
  }) async {
    if (!enabled) {
      await unregisterDeviceToken(userId);
    }

    await _firestore.collection(FirestoreCollections.users).doc(userId).set({
      'notificationsEnabled': enabled,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String? _groupIdFromMessage(RemoteMessage? message) {
    final groupId = message?.data['groupId'];
    if (groupId is String && groupId.isNotEmpty) {
      return groupId;
    }

    return null;
  }

  String _notificationLocale() {
    final languageCode = PlatformDispatcher.instance.locale.languageCode
        .toLowerCase();
    return languageCode == 'ru' ? 'ru' : 'en';
  }

  String _notificationPlatform() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}
