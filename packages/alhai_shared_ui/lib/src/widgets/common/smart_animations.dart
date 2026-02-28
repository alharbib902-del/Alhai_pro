import 'package:flutter/material.dart';
import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_design_system/alhai_design_system.dart';

/// مجموعة الـ Animations الذكية للـ POS
/// 
/// تحترم إعدادات المستخدم لتقليل الحركة (Reduce Motion)

/// Animation لإضافة منتج للسلة - Scale + Fade
class AddToCartAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
  final VoidCallback? onComplete;

  const AddToCartAnimation({
    super.key,
    required this.child,
    this.animate = true,
    this.duration = AlhaiDurations.slow,
    this.onComplete,
  });

  @override
  State<AddToCartAnimation> createState() => _AddToCartAnimationState();
}

class _AddToCartAnimationState extends State<AddToCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: AlhaiMotion.fadeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: AlhaiMotion.fadeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AddToCartAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // احترام إعدادات تقليل الحركة
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Animation للأرقام - Count Up/Down
/// ملاحظة: استخدم AnimatedCounter من animated_counter.dart للمزيد من الميزات
class SimpleAnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const SimpleAnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = AlhaiDurations.verySlow,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    // احترام إعدادات تقليل الحركة
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: reduceMotion ? Duration.zero : duration,
      builder: (context, val, _) {
        return Text(
          '${prefix ?? ''}$val${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// Animation للسعر - تغيير ناعم
class AnimatedPrice extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final String currency;

  const AnimatedPrice({
    super.key,
    required this.value,
    this.style,
    this.duration = AlhaiDurations.verySlow,
    this.currency = StoreSettings.defaultCurrencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: reduceMotion ? Duration.zero : duration,
      builder: (context, val, _) {
        return Text(
          '${val.toStringAsFixed(2)} $currency',
          style: style,
        );
      },
    );
  }
}

/// Success Animation - Checkmark مع scale
class SuccessAnimation extends StatefulWidget {
  final bool show;
  final Duration duration;
  final double size;
  final Color? color;

  const SuccessAnimation({
    super.key,
    required this.show,
    this.duration = AlhaiDurations.extraSlow,
    this.size = 48,
    this.color,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 0.6, curve: AlhaiMotion.spring),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1, curve: AlhaiMotion.fadeOut),
      ),
    );

    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SuccessAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    } else if (!widget.show && oldWidget.show) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    if (reduceMotion && widget.show) {
      return Icon(Icons.check_circle, size: widget.size, color: color);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_scaleAnimation.value == 0) {
          return SizedBox(width: widget.size, height: widget.size);
        }
        
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.check,
              size: widget.size * 0.6 * _checkAnimation.value,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer Loading Effect
/// ملاحظة: استخدم ShimmerLoading من shimmer_loading.dart للمزيد من الميزات
class SimpleShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const SimpleShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<SimpleShimmer> createState() => _SimpleShimmerState();
}

class _SimpleShimmerState extends State<SimpleShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AlhaiDurations.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    
    if (reduceMotion) {
      return Opacity(opacity: 0.5, child: widget.child);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).colorScheme.outline,
                Colors.white,
                Theme.of(context).colorScheme.outline,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pulse Animation للعناصر المهمة
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool pulse;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.pulse = true,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.1)
            .chain(CurveTween(curve: AlhaiMotion.fadeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1)
            .chain(CurveTween(curve: AlhaiMotion.fadeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.pulse) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _controller.repeat();
    } else if (!widget.pulse && oldWidget.pulse) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    
    if (reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
