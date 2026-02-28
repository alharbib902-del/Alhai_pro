import 'package:flutter/material.dart';

/// A drop-in replacement for ListView.builder that adds staggered
/// fade+slide entrance animations to each item.
///
/// Usage (replace ListView.builder):
/// ```dart
/// // Before:
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (ctx, i) => ItemTile(items[i]),
/// )
///
/// // After:
/// AnimatedListView(
///   itemCount: items.length,
///   itemBuilder: (ctx, i) => ItemTile(items[i]),
/// )
/// ```
class AnimatedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Duration itemDuration;
  final Duration staggerDelay;
  final int maxAnimatedItems;

  const AnimatedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.maxAnimatedItems = 15,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return ListView.builder(
      itemCount: itemCount,
      padding: padding,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        final child = itemBuilder(context, index);

        if (reduceMotion || index >= maxAnimatedItems) {
          return child;
        }

        return _StaggeredItem(
          index: index,
          duration: itemDuration,
          delay: staggerDelay * index,
          child: child,
        );
      },
    );
  }
}

/// A drop-in replacement for SliverList that adds entrance animations.
class AnimatedSliverList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Duration itemDuration;
  final Duration staggerDelay;
  final int maxAnimatedItems;

  const AnimatedSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.maxAnimatedItems = 15,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final child = itemBuilder(context, index);

          if (reduceMotion || index >= maxAnimatedItems) {
            return child;
          }

          return _StaggeredItem(
            index: index,
            duration: itemDuration,
            delay: staggerDelay * index,
            child: child,
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final int index;
  final Duration duration;
  final Duration delay;
  final Widget child;

  const _StaggeredItem({
    required this.index,
    required this.duration,
    required this.delay,
    required this.child,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
