import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/animations/animation_constants.dart';
import '../../core/animations/motion.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import 'gradient_button.dart';

enum ConfettiBurstType { standard, rain }

/// Confetti burst matching TestGah's specification:
/// Standard: explosive, 18 particles, force 6-16, freq .05, gravity .25, 1800ms.
/// Rain: directional down, 6 particles, force 2-6, freq .12, gravity .12, 3200ms.
/// Gold palette: #FFD166 / #EDA100 / #FFF1C2 / #FFB84D.
/// Plays once after 250ms. Nothing drawn under Reduce motion.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    this.type = ConfettiBurstType.standard,
    this.child,
    super.key,
  });

  final ConfettiBurstType type;
  final Widget? child;

  static const goldPalette = <Color>[
    Color(0xFFFFD166),
    Color(0xFFEDA100),
    Color(0xFFFFF1C2),
    Color(0xFFFFB84D),
  ];

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> {
  late final ConfettiController _controller = ConfettiController(
    duration: widget.type == ConfettiBurstType.standard
        ? const Duration(milliseconds: 1800)
        : const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted && !Motion.reduced(context)) {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) {
      return widget.child ?? const SizedBox.shrink();
    }

    final isStandard = widget.type == ConfettiBurstType.standard;

    final confetti = ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: isStandard
          ? BlastDirectionality.explosive
          : BlastDirectionality.directional,
      blastDirection: isStandard ? -math.pi / 2 : math.pi / 2,
      numberOfParticles: isStandard ? 18 : 6,
      minBlastForce: isStandard ? 6 : 2,
      maxBlastForce: isStandard ? 16 : 6,
      emissionFrequency: isStandard ? 0.05 : 0.12,
      gravity: isStandard ? 0.25 : 0.12,
      colors: ConfettiBurst.goldPalette,
      shouldLoop: false,
    );

    if (widget.child == null) return confetti;

    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        widget.child!,
        confetti,
      ],
    );
  }
}

enum MascotMood { happy, cheer, think, sleepy }

/// Mascot ("Mo"): CustomPaint on a 3600ms repeating controller:
/// idle bob sin*2.2, blink at t 0.90-0.96, cheer mood hops with |sin|*3,
/// moods: happy, cheer, think, sleepy.
class MascotMo extends StatefulWidget {
  const MascotMo({
    this.mood = MascotMood.happy,
    this.size = 80,
    super.key,
  });

  final MascotMood mood;
  final double size;

  @override
  State<MascotMo> createState() => _MascotMoState();
}

class _MascotMoState extends State<MascotMo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Motion.reduced(context) ? 0.5 : _controller.value;
        final isBlinking = !Motion.reduced(context) && t >= 0.90 && t <= 0.96;
        final idleBob = math.sin(t * 2 * math.pi) * 2.2;
        final cheerHop = -(math.sin(t * 2 * math.pi)).abs() * 3.0;
        final dy = widget.mood == MascotMood.cheer ? cheerHop : idleBob;

        return Transform.translate(
          offset: Offset(0, dy),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _MoPainter(
              mood: widget.mood,
              blinking: isBlinking,
              primaryColor: AppColors.primary,
              accentColor: AppColors.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _MoPainter extends CustomPainter {
  const _MoPainter({
    required this.mood,
    required this.blinking,
    required this.primaryColor,
    required this.accentColor,
  });

  final MascotMood mood;
  final bool blinking;
  final Color primaryColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.44;

    // Body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [accentColor, primaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + size.height * 0.04), width: radius * 1.9, height: radius * 1.8),
      Radius.circular(radius * 0.8),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF7A6E).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(cx - radius * 0.52, cy + radius * 0.22), radius * 0.16, cheekPaint);
    canvas.drawCircle(Offset(cx + radius * 0.52, cy + radius * 0.22), radius * 0.16, cheekPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF152A26)
      ..style = PaintingStyle.fill;

    final eyeStroke = Paint()
      ..color = const Color(0xFF152A26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final leftEye = Offset(cx - radius * 0.35, cy - radius * 0.05);
    final rightEye = Offset(cx + radius * 0.35, cy - radius * 0.05);

    if (blinking) {
      canvas.drawLine(leftEye - Offset(radius * 0.12, 0), leftEye + Offset(radius * 0.12, 0), eyeStroke);
      canvas.drawLine(rightEye - Offset(radius * 0.12, 0), rightEye + Offset(radius * 0.12, 0), eyeStroke);
    } else {
      switch (mood) {
        case MascotMood.happy:
          canvas.drawCircle(leftEye, radius * 0.12, eyePaint);
          canvas.drawCircle(rightEye, radius * 0.12, eyePaint);
          // Catchlights
          canvas.drawCircle(leftEye - Offset(radius * 0.03, radius * 0.03), radius * 0.04, Paint()..color = Colors.white);
          canvas.drawCircle(rightEye - Offset(radius * 0.03, radius * 0.03), radius * 0.04, Paint()..color = Colors.white);
        case MascotMood.cheer:
          final leftPath = Path()
            ..moveTo(leftEye.dx - radius * 0.14, leftEye.dy + radius * 0.04)
            ..quadraticBezierTo(leftEye.dx, leftEye.dy - radius * 0.14, leftEye.dx + radius * 0.14, leftEye.dy + radius * 0.04);
          final rightPath = Path()
            ..moveTo(rightEye.dx - radius * 0.14, rightEye.dy + radius * 0.04)
            ..quadraticBezierTo(rightEye.dx, rightEye.dy - radius * 0.14, rightEye.dx + radius * 0.14, rightEye.dy + radius * 0.04);
          canvas.drawPath(leftPath, eyeStroke);
          canvas.drawPath(rightPath, eyeStroke);
        case MascotMood.think:
          canvas.drawCircle(leftEye, radius * 0.10, eyePaint);
          canvas.drawCircle(rightEye + Offset(radius * 0.04, -radius * 0.04), radius * 0.13, eyePaint);
        case MascotMood.sleepy:
          canvas.drawLine(leftEye - Offset(radius * 0.12, -radius * 0.04), leftEye + Offset(radius * 0.12, 0), eyeStroke);
          canvas.drawLine(rightEye - Offset(radius * 0.12, 0), rightEye + Offset(radius * 0.12, -radius * 0.04), eyeStroke);
      }
    }

    // Mouth
    final mouthStroke = Paint()
      ..color = const Color(0xFF152A26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    switch (mood) {
      case MascotMood.happy:
      case MascotMood.cheer:
        mouthPath.moveTo(cx - radius * 0.22, cy + radius * 0.32);
        mouthPath.quadraticBezierTo(cx, cy + radius * (mood == MascotMood.cheer ? 0.58 : 0.46), cx + radius * 0.22, cy + radius * 0.32);
        canvas.drawPath(mouthPath, mouthStroke);
      case MascotMood.think:
        mouthPath.moveTo(cx - radius * 0.12, cy + radius * 0.38);
        mouthPath.quadraticBezierTo(cx + radius * 0.08, cy + radius * 0.42, cx + radius * 0.22, cy + radius * 0.34);
        canvas.drawPath(mouthPath, mouthStroke);
      case MascotMood.sleepy:
        canvas.drawCircle(Offset(cx, cy + radius * 0.36), radius * 0.08, mouthStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MoPainter old) =>
      old.mood != mood || old.blinking != blinking;
}

/// showCelebration = mascot + fxEnter title (step 4) + fxEnter message (step 6, rise 0)
/// + one button, with haptic success.
Future<void> showCelebration(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'Continue',
  MascotMood mood = MascotMood.cheer,
  VoidCallback? onConfirm,
}) {
  HapticFeedback.mediumImpact();
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        child: ConfettiBurst(
          type: ConfettiBurstType.standard,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MascotMo(mood: mood, size: 88),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: dialogContext.tt.headlineSmall,
                ).fxEnter(dialogContext, step: 4),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: dialogContext.tt.bodyMedium?.copyWith(
                    color: dialogContext.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ).fxEnter(dialogContext, step: 6, rise: 0),
                const SizedBox(height: 24),
                GradientButton(
                  label: buttonText,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// showAchievementUnlock = medal fxPop(from: .2, hero, bounce) with two fxRipple rings behind it.
Future<void> showAchievementUnlock(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.emoji_events_rounded,
  String buttonText = 'Awesome',
  VoidCallback? onConfirm,
}) {
  HapticFeedback.mediumImpact();
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ringColor = AppColors.primary.withValues(alpha: 0.3);
      return Dialog(
        child: ConfettiBurst(
          type: ConfettiBurstType.standard,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 2),
                        ),
                      ).fxRipple(dialogContext, step: 0),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 2),
                        ),
                      ).fxRipple(dialogContext, step: 1),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 36),
                      ).fxPop(
                        dialogContext,
                        from: 0.2,
                        duration: Motion.hero,
                        curve: Motion.bounce,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: dialogContext.tt.headlineSmall,
                ).fxEnter(dialogContext, step: 4),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: dialogContext.tt.bodyMedium?.copyWith(
                    color: dialogContext.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ).fxEnter(dialogContext, step: 6, rise: 0),
                const SizedBox(height: 24),
                GradientButton(
                  label: buttonText,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
