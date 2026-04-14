import 'dart:async';

import 'package:flutter/material.dart';

class AppLoadingSwitcher extends StatelessWidget {
  const AppLoadingSwitcher({
    required this.isLoading,
    required this.loading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<bool>(isLoading),
        child: isLoading ? loading : child,
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    this.itemCount = 4,
    this.showHeader = false,
    this.bottomPadding = 24,
    super.key,
  });

  final int itemCount;
  final bool showHeader;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottomPadding),
        children: [
          if (showHeader) ...[
            const AppSkeletonBox(width: 128, height: 18),
            const SizedBox(height: 12),
          ],
          for (var index = 0; index < itemCount; index += 1) ...[
            const AppSkeletonCard(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({this.height = 112, this.hasAvatar = true, super.key});

  final double height;
  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (hasAvatar) ...[
                const AppSkeletonBox(width: 42, height: 42, radius: 999),
                const SizedBox(width: 12),
              ],
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(width: double.infinity, height: 16),
                    SizedBox(height: 10),
                    AppSkeletonBox(width: 180, height: 12),
                    SizedBox(height: 10),
                    AppSkeletonBox(width: 96, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSkeletonGrid extends StatelessWidget {
  const AppSkeletonGrid({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          for (var index = 0; index < itemCount; index += 1)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSkeletonBox(width: 36, height: 36, radius: 999),
                    SizedBox(height: 12),
                    AppSkeletonBox(width: 72, height: 22),
                    SizedBox(height: 8),
                    AppSkeletonBox(width: 96, height: 12),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = colors.surfaceContainerHighest.withValues(alpha: 0.42);
    final highlight = colors.onSurface.withValues(alpha: 0.10);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 + slide, -0.4),
              end: Alignment(1 + slide, 0.4),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
