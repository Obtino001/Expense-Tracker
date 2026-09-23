import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/primary_app_bar.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const PrimaryAppBar(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.huge,
                ),
                children: <Widget>[
                  Text('Appearance', style: context.text.titleLarge),
                  const SizedBox(height: AppSizes.sm),
                  _Group(
                    children: <Widget>[
                      SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark mode',
                        subtitle: _modeLabel(mode),
                        trailing: Switch.adaptive(
                          value: mode == ThemeMode.dark,
                          activeColor: AppColors.primary,
                          onChanged: (bool v) => ref
                              .read(themeModeProvider.notifier)
                              .setMode(
                                  v ? ThemeMode.dark : ThemeMode.light),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.color_lens_outlined,
                        title: 'Theme color',
                        subtitle: 'Electric violet',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.format_size_rounded,
                        title: 'Text size',
                        subtitle: 'Default',
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSizes.xl),
                  Text('Preferences', style: context.text.titleLarge),
                  const SizedBox(height: AppSizes.sm),
                  _Group(
                    children: <Widget>[
                      SettingsTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Currency',
                        subtitle: 'USD',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'English (US)',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric login',
                        trailing: Switch.adaptive(
                          value: true,
                          activeColor: AppColors.primary,
                          onChanged: (_) {},
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push notifications',
                        trailing: Switch.adaptive(
                          value: true,
                          activeColor: AppColors.primary,
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: AppSizes.xl),
                  Text('About', style: context.text.titleLarge),
                  const SizedBox(height: AppSizes.sm),
                  _Group(
                    children: <Widget>[
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About Budget',
                        subtitle: 'Version 1.0.0',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.policy_outlined,
                        title: 'Privacy policy',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of service',
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: AppSizes.xl),
                  _Group(
                    children: <Widget>[
                      SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Sign out',
                        onTap: () =>
                            ref.read(authServiceProvider).signOut(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.dark:
        return 'On';
      case ThemeMode.light:
        return 'Off';
      case ThemeMode.system:
        return 'Follow system';
    }
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
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
