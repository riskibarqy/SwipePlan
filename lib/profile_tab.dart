import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/user_session.dart';
import 'theme/app_theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<UserSession>();
    final alias = session.userId?.substring(0, 6) ?? 'traveler';
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Profile', style: theme.textTheme.headlineSmall),
          Text(
            'Manage your account',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          _ProfileCard(alias: alias),
          const SizedBox(height: 24),
          Text('Settings', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            trailing: Switch.adaptive(
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
          ),
          const SizedBox(height: 10),
          const _SettingTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.alias});

  final String alias;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: AppShadows.layered,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFB6C7CE), Color(0xFF8FB5AE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text('🌸', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traveler',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$alias@swipeplan.app',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            const Row(
              children: [
                _ProfileStat(value: '3', label: 'Groups'),
                _ProfileStat(value: '23', label: 'Matches'),
                _ProfileStat(value: '156', label: 'Swipes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: AppShadows.layered,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
