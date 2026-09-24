import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/animations/animation_constants.dart';
import '../../core/animations/motion.dart';
import 'pressable.dart';

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
    this.loading = false,
    this.success = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final double height;
  final bool expand;
  final bool loading;
  final bool success;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  void _setHovered(bool v) => setState(() => _hovered = v);

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null;
    return Pressable(
      scale: .975,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      onHover: _setHovered,
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.fast),
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
          boxShadow: disabled || Theme.of(context).brightness == Brightness.dark
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: _hovered ? .38 : .24),
                    blurRadius: _hovered ? 20 : 12,
                    offset: Offset(0, _hovered ? 8 : 4),
                  ),
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: Motion.of(context, Motion.base),
            switchInCurve: Motion.out,
            child: widget.loading
                ? const LoadingDots(key: ValueKey('loading'), color: Colors.white)
                : widget.success
                ? const Icon(Icons.check_rounded, color: Colors.white,
                    key: ValueKey('success'))
                    .fxPop(context, from: 0, duration: Motion.base)
                : Wrap(
                    key: const ValueKey('label'),
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSizes.sm,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, color: Colors.white, size: 20),
              ],
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
