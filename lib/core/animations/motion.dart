import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'animation_constants.dart';

extension MotionWidget on Widget {
  Widget fxEnter(BuildContext context,
      {int step = 0,
      double rise = 8,
      Duration duration = Motion.slow,
      Key? key}) {
    if (Motion.reduced(context)) return this;
    return Animate(key: key, delay: Motion.stagger * step, child: this)
        .fadeIn(duration: duration, curve: Motion.out)
        .move(
            begin: Offset(0, rise),
            end: Offset.zero,
            duration: duration,
            curve: Motion.out);
  }

  Widget fxPop(BuildContext context,
      {int step = 0,
      double from = .8,
      Duration duration = Motion.slow,
      Curve curve = Motion.spring,
      Key? key}) {
    if (Motion.reduced(context)) return this;
    return Animate(key: key, delay: Motion.stagger * step, child: this)
        .fadeIn(duration: Motion.base, curve: Motion.out)
        .scale(
            begin: Offset(from, from),
            end: const Offset(1, 1),
            duration: duration,
            curve: curve);
  }

  Widget fxPulse(BuildContext context,
      {double from = 1, double to = 1.04, Duration period = Motion.pulse}) {
    if (Motion.reduced(context)) return this;
    return Animate(
            child: this,
            onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
            begin: Offset(from, from),
            end: Offset(to, to),
            duration: period,
            curve: Motion.inOut);
  }

  Widget fxFloat(BuildContext context,
      {double dy = 3, Duration period = Motion.drift}) {
    if (Motion.reduced(context)) return this;
    return Animate(
            child: this,
            onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: dy, end: -dy, duration: period, curve: Motion.inOut);
  }

  Widget fxShake(BuildContext context) {
    if (Motion.reduced(context)) return this;
    return Animate(child: this)
        .fadeIn(duration: Motion.base)
        .shake(hz: 3, duration: Motion.slow);
  }

  Widget fxRipple(BuildContext context, {int step = 0}) {
    if (Motion.reduced(context)) return const SizedBox.shrink();
    return Animate(
            delay: Motion.base * (step + 1),
            onPlay: (controller) => controller.repeat(),
            child: this)
        .scale(
            begin: const Offset(.55, .55),
            end: const Offset(1.15, 1.15),
            duration: Motion.pulse)
        .fadeOut(duration: Motion.pulse);
  }
}

class Reveal extends StatelessWidget {
  const Reveal(
      {required this.index, required this.child, this.dy = 12, super.key});
  final int index;
  final double dy;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      child.fxEnter(context, step: index.clamp(0, 10), rise: dy);
}

class SmoothSize extends StatelessWidget {
  const SmoothSize({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Motion.reduced(context)
      ? child
      : AnimatedSize(duration: Motion.base, curve: Motion.out, child: child);
}

class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber(this.value, {this.style, super.key});
  final String value;
  final TextStyle? style;

  static final _number = RegExp(r'^(\D*?)(-?\d[\d,]*(?:\.\d+)?)(\D*)$');

  @override
  Widget build(BuildContext context) {
    final match = _number.firstMatch(value);
    if (match == null) return Text(value, style: style);
    final raw = match.group(2)!;
    final target = double.tryParse(raw.replaceAll(',', ''));
    if (target == null || Motion.reduced(context)) {
      return Text(value, style: style);
    }
    final decimals = raw.contains('.') ? raw.split('.').last.length : 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: Motion.hero,
      curve: Motion.out,
      builder: (context, current, _) {
        final fixed = current.toStringAsFixed(decimals).split('.');
        final sign = fixed.first.startsWith('-') ? '-' : '';
        final digits = fixed.first.replaceFirst('-', '');
        final grouped = digits.replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
        final number = '$sign$grouped${decimals == 0 ? '' : '.${fixed.last}'}';
        return Text('${match.group(1)}$number${match.group(3)}',
            style: (style ?? Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]));
      },
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({this.color, super.key});
  final Color? color;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.hero,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = Motion.reduced(context)
                ? 1.0
                : (_controller.value - i * .16 + 1) % 1;
            final lift = (1 - (2 * t - 1).abs()).clamp(0.0, 1.0);
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                    offset: Offset(0, -3 * lift),
                    child: Opacity(
                        opacity: Motion.reduced(context) ? 1 : .35 + .65 * lift,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: const SizedBox(width: 6, height: 6)))));
          })),
    );
  }
}

void selectionTick() => HapticFeedback.selectionClick();
