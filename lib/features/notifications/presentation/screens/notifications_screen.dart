import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/primary_app_bar.dart';
import '../../../../shared/widgets/skeleton_loader.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<NotificationModel>> async =
        ref.watch(notificationsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const PrimaryAppBar(title: 'Notifications'),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: async.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: SkeletonBox(
                        height: 78, radius: AppSizes.radiusLg),
                  ),
                ),
                error: (Object e, _) => Center(child: Text('Error: $e')),
                data: (List<NotificationModel> items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text("You're all caught up",
                          style: context.text.bodyMedium),
                    );
                  }
                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        0,
                        AppSizes.lg,
                        AppSizes.huge,
                      ),
                      itemCount: items.length,
                      itemBuilder: (BuildContext c, int i) =>
                          AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 350),
                        child: SlideAnimation(
                          verticalOffset: 24,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSizes.md),
                              child: _NotificationCard(item: items[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final NotificationModel item;

  Color _color() {
    switch (item.type) {
      case NotificationType.info:
        return AppColors.info;
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.alert:
        return AppColors.danger;
    }
  }

  IconData _icon() {
    switch (item.type) {
      case NotificationType.info:
        return Icons.info_outline_rounded;
      case NotificationType.success:
        return Icons.check_circle_outline_rounded;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.alert:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color c = _color();
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: item.isRead
            ? null
            : Border.all(color: c.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(_icon(), color: c, size: 20),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.title,
                        style: context.text.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.message, style: context.text.bodyMedium),
                const SizedBox(height: AppSizes.xs),
                Text(
                  Formatters.relativeDay(item.time),
                  style: context.text.bodySmall?.copyWith(
                    color: context.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
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
