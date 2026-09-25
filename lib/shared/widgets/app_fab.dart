import 'package:flutter/material.dart';

import '../../core/animations/animation_constants.dart';
import 'pressable.dart';

/// Floating Action Button with hover scale 1.03 (fast) and press scale 0.96.
class AppFab extends StatefulWidget {
  const AppFab({
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final fg = widget.foregroundColor ?? Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Pressable(
        scale: 0.96,
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _hovered && !Motion.reduced(context) ? 1.03 : 1.0,
          duration: Motion.of(context, Motion.fast),
          curve: Motion.out,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: bg.withValues(alpha: _hovered ? 0.38 : 0.24),
                  blurRadius: _hovered ? 20 : 12,
                  offset: Offset(0, _hovered ? 8 : 4),
                ),
              ],
            ),
            child: IconTheme(
              data: IconThemeData(color: fg, size: 24),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
