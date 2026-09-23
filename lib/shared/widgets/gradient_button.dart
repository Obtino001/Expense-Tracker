import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Primary CTA button with a gradient fill, soft glow, and press scale.
/// Use [icon] for leading icons (e.g. "Continue with Google" patterns).
class GradientButton extends StatefulWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppColors.primaryGradient,
    this.height = AppSizes.buttonHeight,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final double height;
  final bool expand;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          width: widget.expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.expand ? 0 : AppSizes.xxl,
          ),
          decoration: BoxDecoration(
            gradient: disabled
                ? LinearGradient(colors: <Color>[
                    Colors.grey.shade400,
                    Colors.grey.shade500,
                  ])
                : widget.gradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: disabled
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: _pressed ? 8 : 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.icon != null) ...<Widget>[
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: AppSizes.sm),
                ],
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
