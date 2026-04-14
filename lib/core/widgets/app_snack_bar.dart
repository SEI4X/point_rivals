import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  return messenger.showSnackBar(
    SnackBar(content: Text(message), duration: duration),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
showAppSnackBarOnMessenger({
  required ScaffoldMessengerState messenger,
  required String message,
  Duration duration = const Duration(seconds: 4),
}) {
  messenger.clearSnackBars();

  return messenger.showSnackBar(
    SnackBar(content: Text(message), duration: duration),
  );
}
