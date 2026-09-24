import 'package:budget_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/animations/motion.dart';
import '../../../../shared/widgets/pressable.dart';

/// Deep black hero Balance Card matching the reference Picky design:
/// - "Main balance ˇ" dropdown + sparkle icon
/// - "Total balance" label
/// - Large "$4,820.50" with .50 superscript scale
/// - "↑ 2.4% this month" trend badge
/// - 4 circular action buttons: Add (+), Send (↑), Top up (↓), More (:::)
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.balance,
    super.key,
  });

  final double balance;

  @override
  Widget build(BuildContext context) {
    // Format balance into dollar integer and cents
    final String formatted = Formatters.currency(balance);
    final List<String> parts = formatted.split('.');
    final String mainPart = parts.isNotEmpty ? parts[0] : formatted;
    final String decimalPart = parts.length > 1 ? '.${parts[1]}' : '.00';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top row: [Main balance ˇ] pill + [✦] sparkle icon
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              // Main balance selector pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkPill,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: AppColors.darkPillBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(child: Text(
                      'Main balance',
                      style: context.tt.labelMedium!.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),

              // Sparkle icon button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.darkPill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.darkPillBorder,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white70,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // "Total balance" label
          Text(
            'Total balance',
            style: context.tt.bodySmall!.copyWith(color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 6),

          // Big financial figure "$4,820.50"
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              AnimatedNumber(
                mainPart,
                style: context.tt.displayMedium!.copyWith(color: Colors.white),
              ),
              Text(
                decimalPart,
                style: context.tt.headlineMedium!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          )),
          const SizedBox(height: 8),

          // Trend indicator: "↑ 2.4% this month"
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: <Widget>[
              const Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: Color(0xFF34C759),
              ),
              const SizedBox(width: 4),
              Text(
                '2.4% this month',
                style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.65)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons: [Add (+)], [Send (↑)], [Top up (↓)], [More (:::)]
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 20,
            runSpacing: 12,
            children: <Widget>[
              _ActionButton(
                icon: Icons.add_rounded,
                label: 'Add',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteNames.addTransaction);
                },
              ),
              _ActionButton(
                icon: Icons.arrow_upward_rounded,
                label: 'Send',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Send transfer feature')),
                  );
                },
              ),
              _ActionButton(
                icon: Icons.arrow_downward_rounded,
                label: 'Top up',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Top up feature')),
                  );
                },
              ),
              _ActionButton(
                icon: Icons.grid_view_rounded,
                label: 'More',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteNames.categories);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.darkPill,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.darkPillBorder,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.tt.bodySmall!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
