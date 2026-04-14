import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:point_rivals/firebase_options.dart';

abstract final class FirebaseBootstrap {
  static const String _appCheckDebugToken = String.fromEnvironment(
    'FIREBASE_APP_CHECK_DEBUG_TOKEN',
  );

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    assert(() {
      if (_appCheckDebugToken.isEmpty) {
        debugPrint('Firebase App Check debug token is not set.');
      } else {
        debugPrint('Firebase App Check debug token: $_appCheckDebugToken');
      }
      return true;
    }());
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: _androidProvider,
        providerApple: _appleProvider,
      );
    } on Object catch (error, stackTrace) {
      if (kReleaseMode) {
        rethrow;
      }

      debugPrint('Firebase App Check activation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static AndroidAppCheckProvider get _androidProvider {
    if (kReleaseMode) {
      return const AndroidPlayIntegrityProvider();
    }

    return AndroidDebugProvider(debugToken: _debugTokenOrNull);
  }

  static AppleAppCheckProvider get _appleProvider {
    if (kReleaseMode) {
      return const AppleAppAttestWithDeviceCheckFallbackProvider();
    }

    return AppleDebugProvider(debugToken: _debugTokenOrNull);
  }

  static String? get _debugTokenOrNull {
    return _appCheckDebugToken.isEmpty ? null : _appCheckDebugToken;
  }
}
