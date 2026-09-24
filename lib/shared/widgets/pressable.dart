import 'package:flutter/material.dart';

import '../../core/animations/animation_constants.dart';

/// Shared pointer and keyboard feedback for custom tappable surfaces.
class Pressable extends StatefulWidget {
  const Pressable(
      {required this.child,
      required this.onTap,
      this.scale = .97,
      this.borderRadius,
    this.onHover,
    this.mergeSemantics = true,
      super.key});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;
  final ValueChanged<bool>? onHover;
  final bool mergeSemantics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: .6);
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _hovered = true);
        widget.onHover?.call(true);
      },
      onExit: (_) {
        if (enabled) setState(() => _hovered = false);
        widget.onHover?.call(false);
      },
      child: FocusableActionDetector(
        enabled: enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: widget.mergeSemantics ? MergeSemantics(child: _surface(context, enabled, color))
            : _surface(context, enabled, color),
      ),
    );
  }

  Widget _surface(BuildContext context, bool enabled, Color color) => Semantics(
            button: true,
            enabled: enabled,
            onTap: widget.onTap,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown:
                  enabled ? (_) => setState(() => _pressed = true) : null,
              onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
              onTapCancel:
                  enabled ? () => setState(() => _pressed = false) : null,
              onTap: widget.onTap,
              child: AnimatedScale(
                scale: _pressed && !Motion.reduced(context) ? widget.scale : 1,
                duration: Motion.of(context, Motion.instant),
                curve: Motion.out,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    color: _hovered ? Theme.of(context).hoverColor : null,
                    border:
                        _focused ? Border.all(color: color, width: 2) : null,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
}
