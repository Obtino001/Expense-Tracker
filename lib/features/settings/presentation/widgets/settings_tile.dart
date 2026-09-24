import 'package:flutter/material.dart';
import '../../../../shared/widgets/pressable.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({required this.icon, required this.title, this.subtitle,
    this.trailing, this.onTap, this.destructive = false, super.key});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tint = destructive ? colors.error : colors.primary;
    return Material(
      color: Colors.transparent,
      child: Pressable(
        mergeSemantics: false,
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: tint.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: tint, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600, color: destructive ? tint : null)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant, height: 1.45)),
                ],
              ])),
            const SizedBox(width: 8),
            trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded,
              size: 20, color: colors.onSurfaceVariant.withValues(alpha: .65))
              : const SizedBox.shrink()),
          ]),
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .5)),
    ),
    child: Column(children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) Padding(padding: const EdgeInsets.only(left: 70, right: 16),
          child: Divider(height: 1, thickness: .5,
            color: Theme.of(context).dividerColor.withValues(alpha: .65))),
        children[i],
      ],
    ]),
  );
}

class SettingsSection extends StatelessWidget {
  const SettingsSection(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 28, 4, 12),
    child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 1.7, fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}

Future<void> showInformationSheet(BuildContext context, {required String title,
  required IconData icon, required List<({String title, String body})> sections}) =>
  showModalBottomSheet<void>(context: context, isScrollControlled: true,
    showDragHandle: true, useSafeArea: true,
    builder: (context) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final section in sections) ...[
            const SizedBox(height: 16),
            Text(section.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(section.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.65, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () => Navigator.pop(context), child: const Text('Got it'))),
        ]),
    ));
