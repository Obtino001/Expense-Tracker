import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/animations/animation_constants.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/preferences_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/primary_app_bar.dart';
import '../../../../shared/widgets/pressable.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(body: SafeArea(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PrimaryAppBar(title: 'Settings'),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            Text('Make it yours.', style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -.8)),
            const SizedBox(height: 8),
            Text('A little more you. A lot more clarity.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
            const SettingsSection('Appearance'),
            Row(children: [
              for (final value in ThemeMode.values) ...[
                if (value != ThemeMode.system) const SizedBox(width: 10),
                Expanded(child: _ThemeOption(mode: value, selected: mode == value,
                  onTap: () {
                    notifier.selectionFeedback();
                    ref.read(themeModeProvider.notifier).setMode(value);
                  })),
              ],
            ]),
            const SizedBox(height: 16),
            SettingsGroup(children: [
              SettingsTile(icon: Icons.palette_outlined, title: 'Accent color',
                subtitle: _accentLabel(prefs.accent),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 20, height: 20,
                    decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 20, color: colors.onSurfaceVariant),
                ]),
                onTap: () => _showAccent(context, ref)),
              SettingsTile(icon: Icons.text_fields_rounded, title: 'Text size',
                subtitle: _scaleLabel(prefs.textScale),
                onTap: () => _showTextSize(context, ref)),
            ]),
            const SettingsSection('Preferences'),
            SettingsGroup(children: [
              SettingsTile(icon: Icons.payments_outlined, title: 'Currency',
                subtitle: '${prefs.currencyCode} · ${_currencyNames[prefs.currencyCode]}',
                onTap: () => _showCurrency(context, ref)),
              SettingsTile(icon: Icons.language_rounded, title: 'Language',
                subtitle: 'English', onTap: () => showInformationSheet(context,
                  title: 'Language', icon: Icons.language_rounded, sections: const [
                    (title: 'English', body: 'Budget is currently available in English. Dates and numbers use English formatting. Other languages are not available in this version.'),
                  ])),
              SettingsTile(icon: Icons.notifications_none_rounded, title: 'In-app notifications',
                subtitle: 'Show your activity inbox and unread alerts',
                trailing: Switch.adaptive(value: prefs.notificationsEnabled,
                  onChanged: notifier.setNotifications)),
            ]),
            const SettingsSection('Feel & accessibility'),
            SettingsGroup(children: [
              SettingsTile(icon: Icons.touch_app_outlined, title: 'Haptic feedback',
                subtitle: 'Gentle taps on supported mobile devices',
                trailing: Switch.adaptive(value: prefs.hapticsEnabled,
                  onChanged: notifier.setHaptics)),
              SettingsTile(icon: Icons.motion_photos_off_outlined, title: 'Reduce motion',
                subtitle: 'Simpler transitions with less movement',
                trailing: Switch.adaptive(value: prefs.reducedMotion,
                  onChanged: notifier.setReducedMotion)),
            ]),
            const SettingsSection('Good to know'),
            SettingsGroup(children: [
              SettingsTile(icon: Icons.shield_outlined, title: 'Privacy & storage',
                subtitle: 'Understand where your information lives',
                onTap: () => showPrivacySheet(context)),
              SettingsTile(icon: Icons.help_outline_rounded, title: 'Help & support',
                onTap: () => showHelpSheet(context)),
              SettingsTile(icon: Icons.info_outline_rounded, title: 'About Budget',
                subtitle: 'Version 1.0.0',
                onTap: () => showInformationSheet(context, title: 'Room for what matters.',
                  icon: Icons.auto_awesome_outlined, sections: const [
                    (title: 'Budget · 1.0.0', body: 'A calmer way to see your money. Track the everyday, plan ahead, and understand your spending with a little more perspective.'),
                    (title: 'Your numbers, in context', body: 'Insights are calculated from your recorded transactions. Budget does not connect to your bank or provide financial advice.'),
                  ])),
            ]),
            const SizedBox(height: 24),
            if (ref.watch(currentUserProvider) != null)
              SettingsGroup(children: [SettingsTile(icon: Icons.logout_rounded,
                title: 'Sign out', destructive: true,
                onTap: () => confirmSignOut(context, ref))])
            else
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Your preferences are saved on this device.',
                  textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant))),
          ],
        )),
      ],
    )));
  }
}

String _accentLabel(String value) => switch (value) {
  'blue' => 'Coastal blue', 'violet' => 'Soft iris', _ => 'Signature mint',
};
String _scaleLabel(double value) => value == 1.3 ? 'Largest' : value == 1.15 ? 'Larger' : 'Default';
const _currencyNames = {
  'USD': 'US Dollar', 'EUR': 'Euro', 'GBP': 'British Pound', 'PKR': 'Pakistani Rupee',
  'AED': 'UAE Dirham', 'INR': 'Indian Rupee', 'CAD': 'Canadian Dollar', 'AUD': 'Australian Dollar',
};

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.mode, required this.selected, required this.onTap});
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = switch (mode) {ThemeMode.system => 'System', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark'};
    final dark = mode == ThemeMode.dark;
    return Semantics(button: true, selected: selected, label: '$label appearance',
      child: Material(color: colors.surface, borderRadius: BorderRadius.circular(20),
        child: Pressable(onTap: onTap, borderRadius: BorderRadius.circular(20),
          mergeSemantics: false,
          child: AnimatedContainer(duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero : Motion.of(context, Motion.base),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 1.8 : .8)),
            child: Column(children: [
              Container(height: 68, width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: mode == ThemeMode.system ? const LinearGradient(
                    colors: [Color(0xFFF2F3F0), Color(0xFFF2F3F0), Color(0xFF1B2926), Color(0xFF1B2926)],
                    stops: [0, .5, .5, 1]) : null,
                  color: mode == ThemeMode.system ? null : dark ? const Color(0xFF1B2926) : const Color(0xFFF2F3F0),
                  borderRadius: BorderRadius.circular(11)),
                child: Padding(padding: const EdgeInsets.all(10), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 18, height: 5, decoration: BoxDecoration(
                      color: colors.primary, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(height: 9),
                    Container(height: 16, decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .28), borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 5),
                    Container(height: 5, width: 30, decoration: BoxDecoration(
                      color: dark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(3))),
                  ]))),
              const SizedBox(height: 12),
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? colors.primary : colors.onSurface,
                fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}

Future<void> _showAccent(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context, showDragHandle: true, useSafeArea: true,
  builder: (context) => Consumer(builder: (context, ref, _) {
    final prefs = ref.watch(preferencesProvider);
    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your signature color', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('A subtle accent, throughout your day.'),
          const SizedBox(height: 20),
          for (final entry in {'mint': const Color(0xFF147D64), 'blue': const Color(0xFF3E72BB),
            'violet': const Color(0xFF8062B7)}.entries)
            ListTile(contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: entry.value, radius: 16,
                child: prefs.accent == entry.key ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null),
              title: Text(_accentLabel(entry.key)),
              selected: prefs.accent == entry.key,
              onTap: () async {
                await ref.read(preferencesProvider.notifier).setAccent(entry.key);
                if (context.mounted) Navigator.pop(context);
              }),
        ]));
  }));

Future<void> _showTextSize(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context, showDragHandle: true, useSafeArea: true,
  builder: (context) => Consumer(builder: (context, ref, _) {
    final prefs = ref.watch(preferencesProvider);
    return RadioGroup<double>(groupValue: prefs.textScale,
      onChanged: (value) => ref.read(preferencesProvider.notifier).setTextScale(value!),
      child: Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comfortably readable', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Text size works alongside your device settings.'),
          const SizedBox(height: 16),
          for (final scale in [1.0, 1.15, 1.3])
            RadioListTile<double>(contentPadding: EdgeInsets.zero, value: scale,
              title: Text(_scaleLabel(scale))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () => Navigator.pop(context), child: const Text('Done'))),
        ])));
  }));

Future<void> _showCurrency(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context, showDragHandle: true, useSafeArea: true, isScrollControlled: true,
  builder: (context) => Consumer(builder: (context, ref, _) {
    final code = ref.watch(preferencesProvider.select((p) => p.currencyCode));
    return RadioGroup<String>(groupValue: code,
      onChanged: (value) async {
        await ref.read(preferencesProvider.notifier).setCurrency(value!);
        if (context.mounted) Navigator.pop(context);
      },
      child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
      child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Text('Currency', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Sets the display currency for all amounts. Existing amounts are not converted.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          for (final entry in _currencyNames.entries)
            RadioListTile<String>(contentPadding: EdgeInsets.zero, value: entry.key,
              title: Text(entry.value), secondary: Text(entry.key)),
        ])));
  }));

Future<void> showPrivacySheet(BuildContext context) => showInformationSheet(context,
  title: 'Privacy & storage', icon: Icons.shield_outlined, sections: const [
    (title: 'On this device', body: 'Your appearance preferences, local profile, and local workspace records are stored on this device. Clearing browser or app data removes local information. Local preferences are not encrypted.'),
    (title: 'When you sign in', body: 'Connected accounts use Firebase authentication and cloud storage where configured. Account records can be stored with that service. Budget never asks for your bank password.'),
    (title: 'Notifications & security', body: 'The inbox preference controls in-app alerts. It does not grant operating system push permission. Device authentication and biometric locking are not available in this version.'),
  ]);

Future<void> showHelpSheet(BuildContext context) => showInformationSheet(context,
  title: 'A little guidance', icon: Icons.help_outline_rounded, sections: const [
    (title: 'Start with the everyday', body: 'Tap the plus button to add income or an expense. Choose a category, add an amount, and select a date. Your overview updates with each transaction.'),
    (title: 'Make space for your goals', body: 'Create a budget for a category to keep spending in view. Analytics helps you see where your money goes over time.'),
    (title: 'Change your mind', body: 'Swipe a transaction to remove it, then use Undo to bring it back. Use the search and filters in Transactions to find a record quickly.'),
    (title: 'Keep your data', body: 'Local data stays in this app or browser. Clearing its storage removes it. A different browser or device has a separate local workspace.'),
  ]);

Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
    title: const Text('Sign out of Budget?'),
    content: const Text('Your saved records and preferences will stay here.'),
    actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay here')),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out'))],
  ));
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) context.go(RouteNames.login);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not sign out. Please try again.')));
    }
  }
}
