import 'dart:async';

import 'package:flutter/material.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({required this.child, this.onRefresh, super.key});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh ?? _settleRefresh,
      child: child,
    );
  }

  static Future<void> _settleRefresh() {
    return Future<void>.delayed(const Duration(milliseconds: 350));
  }
}
