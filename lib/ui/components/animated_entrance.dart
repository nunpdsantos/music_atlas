import 'package:flutter/material.dart';

import '../../core/motion_tokens.dart';

/// A widget that animates its child with a fade and slide entrance.
///
/// Use this to add entrance animations to any widget. The animation runs
/// once when the widget is first built.
///
/// Example:
/// ```dart
/// AnimatedEntrance(
///   delay: Duration(milliseconds: 100),
///   child: MyCard(),
/// )
/// ```
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = MotionTokens.standard,
    this.curve = MotionTokens.enterCurve,
    this.slideOffset = MotionTokens.slideUpOffset,
    this.beginOpacity = MotionTokens.fadeInStart,
    this.beginScale = MotionTokens.scaleStart,
    this.slideDirection = AxisDirection.up,
    this.animate = true,
  });

  /// The widget to animate.
  final Widget child;

  /// Delay before animation starts.
  final Duration delay;

  /// Duration of the animation.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Offset for slide animation (in logical pixels).
  final double slideOffset;

  /// Starting opacity (0.0 to 1.0).
  final double beginOpacity;

  /// Starting scale (0.0 to 1.0).
  final double beginScale;

  /// Direction of slide animation.
  final AxisDirection slideDirection;

  /// Whether to animate. Set to false to skip animation.
  final bool animate;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.beginOpacity,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    final slideBegin = _getSlideOffset();
    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.animate) {
      _startAnimation();
    } else {
      _controller.value = 1.0;
    }
  }

  Offset _getSlideOffset() {
    final offset = widget.slideOffset;
    return switch (widget.slideDirection) {
      AxisDirection.up => Offset(0, offset),
      AxisDirection.down => Offset(0, -offset),
      AxisDirection.left => Offset(offset, 0),
      AxisDirection.right => Offset(-offset, 0),
    };
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A widget that staggers the entrance of its children.
///
/// Each child animates with a delay based on its index.
///
/// Example:
/// ```dart
/// StaggeredList(
///   children: chords.map((c) => ChordCard(chord: c)).toList(),
/// )
/// ```
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    required this.children,
    super.key,
    this.staggerDelay = MotionTokens.staggerDelay,
    this.initialDelay = Duration.zero,
    this.itemDuration = MotionTokens.standard,
    this.curve = MotionTokens.enterCurve,
    this.slideOffset = MotionTokens.slideUpOffset,
    this.slideDirection = AxisDirection.up,
    this.animate = true,
  });

  /// The widgets to animate.
  final List<Widget> children;

  /// Delay between each item's animation start.
  final Duration staggerDelay;

  /// Delay before the first item starts animating.
  final Duration initialDelay;

  /// Duration of each item's animation.
  final Duration itemDuration;

  /// Animation curve for each item.
  final Curve curve;

  /// Slide offset for each item.
  final double slideOffset;

  /// Direction of slide animation.
  final AxisDirection slideDirection;

  /// Whether to animate. Set to false to skip animation.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++)
          AnimatedEntrance(
            delay: initialDelay +
                Duration(milliseconds: staggerDelay.inMilliseconds * i),
            duration: itemDuration,
            curve: curve,
            slideOffset: slideOffset,
            slideDirection: slideDirection,
            animate: animate,
            child: children[i],
          ),
      ],
    );
  }
}

/// A widget that fades in its child.
///
/// Simple fade animation without slide or scale.
class FadeIn extends StatefulWidget {
  const FadeIn({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = MotionTokens.standard,
    this.curve = MotionTokens.enterCurve,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
