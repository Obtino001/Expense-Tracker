import 'package:flutter/material.dart';
import 'package:budget_app/core/animations/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/user_model.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../widgets/profile_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserModel?> userAsync = ref.watch(userProvider);
    final ({double balance, double expense, double income}) totals =
        ref.watch(totalsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            120,
          ),
          children: <Widget>[
            Text('Profile', style: context.text.displayMedium)
                .fxEnter(context, step: 0),
            const SizedBox(height: AppSizes.xl),

            // Identity card
            userAsync.when(
              loading: () => const _ProfileSkeleton(),
              error: (_, __) => const SizedBox.shrink(),
              data: (UserModel? u) => u == null
                  ? const _ProfileSkeleton()
                  : _ProfileHeader(user: u, balance: totals.balance)
                      .fxEnter(context, step: 2),
            ),

            const SizedBox(height: AppSizes.xl),

            // Stats row
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatBox(
                    label: 'Income',
                    value: Formatters.compactCurrency(totals.income),
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _StatBox(
                    label: 'Expense',
                    value: Formatters.compactCurrency(totals.expense),
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _StatBox(
                    label: 'Saved',
                    value: Formatters.compactCurrency(totals.balance),
                    icon: Icons.savings_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ).fxEnter(context, step: 4),

            const SizedBox(height: AppSizes.xxl),

            // Section
            Text('Account', style: context.text.titleLarge),
            const SizedBox(height: AppSizes.sm),
            _GroupedTiles(
              children: <Widget>[
                ProfileTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal information',
                  onTap: () {},
                ),
                ProfileTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () => context.push(RouteNames.notifications),
                ),
                ProfileTile(
                  icon: Icons.category_rounded,
                  title: 'Categories',
                  onTap: () => context.push(RouteNames.categories),
                ),
                ProfileTile(
                  icon: Icons.security_rounded,
                  title: 'Security',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl),
            Text('General', style: context.text.titleLarge),
            const SizedBox(height: AppSizes.sm),
            _GroupedTiles(
              children: <Widget>[
                ProfileTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => context.push(RouteNames.settings),
                ),
                ProfileTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & support',
                  onTap: () {},
                ),
                ProfileTile(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  destructive: true,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.balance});

  final UserModel user;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: AppSizes.avatarLg,
            width: AppSizes.avatarLg,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 2),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: context.tt.headlineLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.name,
                  style: context.tt.titleLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  user.email,
                  style: context.tt.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Premium member',
                        style: context.tt.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSizes.sm),
          Text(label, style: context.text.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style:
                context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _GroupedTiles extends StatelessWidget {
  const _GroupedTiles({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
      ),
    );
  }
}
