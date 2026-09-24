import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import 'pressable.dart';

/// Tiny section header used above lists ("Recent transactions" + "See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (actionLabel != null)
          Pressable(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: context.text.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
