import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/user_session.dart';
import 'groups/group_context.dart';
import 'groups/group_repository.dart';
import 'theme/app_theme.dart';

class GroupsTab extends StatefulWidget {
  const GroupsTab({super.key, required this.onManageGroups});

  final Future<void> Function() onManageGroups;

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  Future<List<GroupSummary>>? _groupsFuture;
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.watch<UserSession>();
    final userId = session.userId;
    if (userId != _userId) {
      _userId = userId;
      _groupsFuture = _loadGroups(userId);
    }
  }

  Future<List<GroupSummary>> _loadGroups(String? userId) {
    if (userId == null) return Future.value(const []);
    final repository = context.read<GroupRepository>();
    return repository.fetchUserGroups(userId: userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _groupsFuture = _loadGroups(_userId);
    });
    await _groupsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = _userId;
    if (userId == null) {
      return const Center(
        child: _EmptyState(
          title: 'Sign in to manage crews',
          subtitle: 'We will list the groups linked to your account here.',
        ),
      );
    }

    final activeGroupId = context.watch<GroupContext>().activeGroupId;
    return FutureBuilder<List<GroupSummary>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: _EmptyState(
              title: 'Unable to load groups',
              subtitle: 'Please pull to refresh or try again later.',
            ),
          );
        }
        final groups = snapshot.data ?? const [];
        if (groups.isNotEmpty && activeGroupId == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.read<GroupContext>().setActiveGroup(groups.first.id),
          );
        }
        return RefreshIndicator.adaptive(
          color: theme.colorScheme.primary,
          displacement: 32,
          strokeWidth: 3,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text('Your Crews', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Choose a group to start planning',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              if (groups.isEmpty) ...[
                const _EmptyState(
                  title: 'No groups yet',
                  subtitle: 'Create one to start cozy planning sessions.',
                ),
              ] else ...[
                for (final group in groups) ...[
                  _CrewCard(
                    data: group,
                    isActive: group.id == activeGroupId,
                    onTap:
                        () => context.read<GroupContext>().setActiveGroup(
                          group.id,
                        ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await widget.onManageGroups();
                    await _refresh();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Manage crews'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CrewCard extends StatelessWidget {
  const _CrewCard({
    required this.data,
    required this.onTap,
    required this.isActive,
  });

  final GroupSummary data;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final badgeColor =
        isActive ? theme.colorScheme.primary : theme.colorScheme.outline;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFEFA), Color(0xFFF2EBE1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(36),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _relativeTime(data.updatedAt),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: subtitleColor),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: badgeColor.withValues(alpha: 0.18),
                    child: Icon(Icons.groups_2_outlined, color: badgeColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      data.memberCount == null
                          ? 'Members syncing soon'
                          : '${data.memberCount} member${data.memberCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Tap to select',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        children: [
          const Icon(
            Icons.spa_outlined,
            size: 42,
            color: AppPalette.terracotta,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime? value) {
  if (value == null) return 'Moments ago';
  final diff = DateTime.now().difference(value);
  if (diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays == 1) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} days ago';
  }
  return '${diff.inDays ~/ 7} wk ago';
}
