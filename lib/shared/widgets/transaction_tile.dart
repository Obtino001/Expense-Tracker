import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';

/// Single-row transaction tile matching the Picky editorial aesthetic:
/// - Circular icon avatar with distinctive dark/brand tint
/// - Bold merchant title
/// - Category & time subtitle
/// - High contrast bold financial figure
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.onTap,
    super.key,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;

  Color _avatarBg() {
    if (transaction.title.toLowerCase().contains('coffee') ||
        transaction.title.toLowerCase().contains('bottle') ||
        transaction.title.toLowerCase().contains('cafe')) {
      return const Color(0xFF2C221D);
    }
    if (transaction.title.toLowerCase().contains('whole foods') ||
        transaction.category.id == 'c3') {
      return const Color(0xFF133E2B);
    }
    if (transaction.category.id == 'c1') {
      return const Color(0xFF1A355E);
    }
    return transaction.category.color.withValues(alpha: 0.18);
  }

  Color _avatarIconColor() {
    if (transaction.title.toLowerCase().contains('coffee') ||
        transaction.title.toLowerCase().contains('bottle')) {
      return const Color(0xFFD4A373);
    }
    if (transaction.title.toLowerCase().contains('whole foods') ||
        transaction.category.id == 'c3') {
      return const Color(0xFF4ADE80);
    }
    if (transaction.category.id == 'c1') {
      return const Color(0xFF60A5FA);
    }
    return transaction.category.color;
  }

  String _timeString(DateTime dt) {
    final DateTime now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final String minute = dt.minute.toString().padLeft(2, '0');
      final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    }
    final int diffDays = now.difference(dt).inDays;
    if (diffDays <= 1) return 'Yesterday';
    return Formatters.relativeDay(dt);
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final bool income = transaction.isIncome;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
          child: Row(
            children: <Widget>[
              // Circular merchant / category avatar
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: _avatarBg(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    transaction.category.icon,
                    color: _avatarIconColor(),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md + 2),

              // Title + category & timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: dark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${transaction.category.name} · ${_timeString(transaction.date)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.md),

              // Amount (-$5.40)
              Text(
                '${income ? '+' : '-'}${Formatters.currency(transaction.amount)}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: -0.3,
                  color: income
                      ? AppColors.success
                      : (dark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
