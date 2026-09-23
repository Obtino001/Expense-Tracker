import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';

/// Wraps [TextFormField] with a leading icon, suffix, and consistent styling.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.hint,
    this.controller,
    this.icon,
    this.suffix,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.text.bodyMedium?.copyWith(
          color: dark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(
                  left: AppSizes.lg,
                  right: AppSizes.sm,
                ),
                child: Icon(icon, size: 20),
              ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
      ),
    );
  }
}
