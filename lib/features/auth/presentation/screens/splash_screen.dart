import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../core/animations/motion.dart';
import '../../../../core/constants/app_colors.dart';

/// Shown while the auth state resolves.
class SplashScreen extends StatefulWidget {
  const SplashScreen({this.entrance = true, super.key});

  final bool entrance;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _loop = AnimationController(
    vsync: this, duration: Motion.splashLoop,
  );

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: Motion.hero,
      value: widget.entrance ? 0 : 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _in.value = 1;
      _loop.stop();
    } else if (widget.entrance && _in.value == 0) {
      _in.forward().then((_) {
        if (mounted && !Motion.reduced(context)) _loop.repeat(reverse: true);
      });
    } else if (!_loop.isAnimating) {
      _loop.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  double _phase(double start, double end) =>
      ((_in.value - start) / (end - start)).clamp(0, 1);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GradientBackground(
      child: AnimatedBuilder(
        animation: Listenable.merge([_in, _loop]),
        builder: (context, _) {
          final reduced = Motion.reduced(context);
          final logoPhase = _phase(0, .5);
          final wordPhase = Motion.out.transform(_phase(.3, .75));
          final dotsPhase = _phase(.65, 1);
          final breath = reduced ? 0.0 : _loop.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (!reduced) Container(
                width: 460 + 40 * breath,
                height: 460 + 40 * breath,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.primary.withValues(alpha: .06 + .06 * breath),
                    Colors.transparent,
                  ]),
                ),
              ),
              if (!reduced) Opacity(
                opacity: (1 - _phase(.15, 1)).clamp(0, 1),
                child: Transform.scale(
                  scale: 1 + .9 * _phase(.15, 1),
                  child: Container(width: 96, height: 96,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2))),
                ),
              ),
              Transform.scale(
                scale: (1 + .08 * math.sin(math.pi * logoPhase)) *
                    (1 + .025 * breath),
                child: Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withValues(alpha: .4),
                      blurRadius: 30, spreadRadius: 4,
                    )],
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 48),
                ),
              ),
              Transform.translate(
                offset: Offset(0, 86 + 14 * (1 - wordPhase)),
                child: Opacity(opacity: wordPhase,
                  child: Text('Budget',
                    style: Theme.of(context).textTheme.headlineLarge)),
              ),
              Transform.translate(
                offset: const Offset(0, 142),
                child: Opacity(opacity: dotsPhase,
                  child: const LoadingDots()),
              ),
            ],
          );
        },
      ),
    ),
  );
}
