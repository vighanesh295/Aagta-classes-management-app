import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

// Simple local theme provider
final _themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(currentUserProvider).valueOrNull;
    final themeMode = ref.watch(_themeModeProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile info card
          PremiumCard(
            showGoldBorder: true,
            child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                child: Text(
                  (user?.name ?? 'U')[0].toUpperCase(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? 'User', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(user?.email ?? '', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text((user?.role.name ?? '').toUpperCase(),
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          _sectionTitle(context, 'Appearance'),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.dark_mode_rounded, color: Theme.of(context).colorScheme.secondary),
                title: const Text(AppStrings.darkMode),
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (v) => ref.read(_themeModeProvider.notifier).state =
                      v ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          _sectionTitle(context, 'Notifications'),
          const PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              _SettingsTile(Icons.notifications_active_rounded, 'Push Notifications', true),
              Divider(height: 1),
              _SettingsTile(Icons.payment_rounded, 'Fee Reminders', true),
              Divider(height: 1),
              _SettingsTile(Icons.campaign_rounded, 'Announcements', true),
            ]),
          ),
          const SizedBox(height: 16),

          _sectionTitle(context, 'Account'),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.lock_outline_rounded, color: Theme.of(context).colorScheme.secondary),
                title: const Text('Change Password'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.help_outline_rounded, color: Theme.of(context).colorScheme.secondary),
                title: const Text('Help & Support'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.secondary),
                title: const Text('About'),
                subtitle: const Text(AppStrings.appVersion, style: TextStyle(fontSize: 11)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 8),
                      Image.asset(AppAssets.logo, height: 60, fit: BoxFit.contain),
                      const SizedBox(height: 20),
                      Text('Learn Today, Lead Tomorrow',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          )),
                      const SizedBox(height: 12),
                      Text(AppStrings.appVersion,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 4),
                      Text('Since 2014 Â· Trusted by thousands',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          )),
                    ]),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          PremiumCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
              title: Text(AppStrings.logout,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                }
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8, left: 4),
  child: Text(title, style: TextStyle(
    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ?? Colors.grey, fontWeight: FontWeight.w700, fontSize: 12,
    letterSpacing: 0.8,
  )),
);

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool initial;
  const _SettingsTile(this.icon, this.title, this.initial);
  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  late bool _value;
  @override
  void initState() { super.initState(); _value = widget.initial; }
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(widget.icon, color: Theme.of(context).colorScheme.secondary),
    title: Text(widget.title),
    trailing: Switch(value: _value, activeThumbColor: Theme.of(context).colorScheme.secondary, onChanged: (v) => setState(() => _value = v)),
  );
}
