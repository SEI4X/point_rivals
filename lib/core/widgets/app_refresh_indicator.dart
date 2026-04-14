import 'dart:async';

import 'package:flutter/material.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({required this.child, this.onRefresh, super.key});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh ?? () => _refreshScope(context),
      child: child,
    );
  }

  static Future<void> _refreshScope(BuildContext context) async {
    AppRefreshScope.refresh(context);
    await _settleRefresh();
  }

  static Future<void> _settleRefresh() {
    return Future<void>.delayed(const Duration(milliseconds: 350));
  }
}

class AppRefreshScope extends StatefulWidget {
  const AppRefreshScope({required this.child, super.key});

  final Widget child;

  static void refresh(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<_AppRefreshInherited>()
        ?.widget;
    if (widget is _AppRefreshInherited) {
      widget.state.refresh();
    }
  }

  static int revisionOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_AppRefreshInherited>()
            ?.revision ??
        0;
  }

  @override
  State<AppRefreshScope> createState() => _AppRefreshScopeState();
}

class _AppRefreshScopeState extends State<AppRefreshScope> {
  int _revision = 0;

  void refresh() {
    setState(() => _revision += 1);
  }

  @override
  Widget build(BuildContext context) {
    return _AppRefreshInherited(
      revision: _revision,
      state: this,
      child: widget.child,
    );
  }
}

class _AppRefreshInherited extends InheritedWidget {
  const _AppRefreshInherited({
    required this.revision,
    required this.state,
    required super.child,
  });

  final int revision;
  final _AppRefreshScopeState state;

  @override
  bool updateShouldNotify(_AppRefreshInherited oldWidget) {
    return revision != oldWidget.revision;
  }
}
