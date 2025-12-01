import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'auth/user_id_mapper.dart';
import 'auth/user_session.dart';
import 'groups/group_context.dart';
import 'watch_tab.dart';
import 'theme/app_theme.dart';
import 'theme/ghibli_decorations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GhibliBackdrop(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(
                    onOpenGroups: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GroupScreen()),
                      );
                    },
                    onSignOut: () => _signOut(context),
                  ),
                  const SizedBox(height: 18),
                  const _HeroBanner(),
                  const SizedBox(height: 20),
                  const _TabSelector(),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: _TabSurface(child: _HomeTabs()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final config = context.read<AppConfig>();
    if (config.usesSupabaseAuth) {
      await Supabase.instance.client.auth.signOut();
    } else {
      await ClerkAuth.of(context, listen: false).signOut();
    }
  }
}

class _TripTab extends StatelessWidget {
  const _TripTab();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderCard(
      icon: Icons.flight_takeoff,
      title: 'Trip planning is coming',
      subtitle: 'Share itineraries, travel vibes, and budgets soon.',
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderCard(
      icon: Icons.event_available,
      title: 'Schedule view in progress',
      subtitle: 'Sync swipes with calendars and reminders shortly.',
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onOpenGroups, required this.onSignOut});

  final Future<void> Function() onOpenGroups;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SwipePlan', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('Retro Ghibli watch party atelier', style: subtitleStyle),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(icon: Icons.auto_awesome, label: 'Dreamy cues'),
                  _MiniBadge(icon: Icons.local_florist, label: 'Slow living'),
                  _MiniBadge(icon: Icons.handshake, label: 'Crew sync'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _HeaderAction(
          icon: Icons.groups_2_outlined,
          label: 'Crews',
          onTap: onOpenGroups,
        ),
        const SizedBox(width: 10),
        _HeaderAction(
          icon: Icons.logout_rounded,
          label: 'Exit',
          onTap: onSignOut,
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Material(
      color: Colors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          await onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<WatchController>();
    final groupId = context.watch<GroupContext>().activeGroupId;
    final queueValue =
        controller.queueLength == 0
            ? 'Empty queue'
            : '${controller.queueLength} picks';
    final queueCaption =
        controller.queueLength == 0
            ? 'Load a fresh round'
            : '${controller.remainingCount} left';
    final progressValue = '${(controller.progress * 100).round()}%';
    final progressCaption =
        controller.queueLength == 0
            ? 'No swipes today'
            : 'of this dreamy round';
    final crewLinked = groupId != null;

    final crewValue = crewLinked ? 'Crew synced' : 'Crew needed';
    final crewCaption =
        crewLinked
            ? 'Swipes share automatically'
            : 'Tap crews to invite friends';

    final metrics = [
      _HeroMetric(
        icon: Icons.movie_filter,
        label: 'Queue',
        value: queueValue,
        caption: queueCaption,
      ),
      _HeroMetric(
        icon: Icons.timelapse,
        label: 'Progress',
        value: progressValue,
        caption: progressCaption,
      ),
      _HeroMetric(
        icon: Icons.group_work,
        label: 'Crew',
        value: crewValue,
        caption: crewCaption,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBE5CF), Color(0xFFF3D6CC), Color(0xFFBFDCC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: AppShadows.layered,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(icon: Icons.auto_awesome, label: 'Storyteller mode'),
              _MiniBadge(icon: Icons.terrain, label: 'Misty valley vibes'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Curate a cozy film ritual',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            crewLinked
                ? 'You are synced with your crew. Keep swiping until everyone hearts the same title.'
                : 'Gather your crew to sync votes. Every swipe will feel like pen pals trading tapes.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;
              if (isNarrow) {
                return Column(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      metrics[i],
                      if (i != metrics.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: metrics[0]),
                  const SizedBox(width: 12),
                  Expanded(child: metrics[1]),
                  const SizedBox(width: 12),
                  Expanded(child: metrics[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuroraGlass(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: TabBar(
          splashBorderRadius: BorderRadius.circular(999),
          indicator: BoxDecoration(
            gradient: AppGradients.accent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [AppShadows.soft],
          ),
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.primary.withValues(
            alpha: 0.5,
          ),
          tabs: const [
            Tab(text: 'Watch'),
            Tab(text: 'Trip'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs();

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        WatchTab(),
        _TripTab(),
        _ScheduleTab(),
      ],
    );
  }
}

class _TabSurface extends StatelessWidget {
  const _TabSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(40);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.surface,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: AppShadows.layered,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFCEFDA), Color(0xFFF6DDCC), Color(0xFFCFE4D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: AppShadows.layered,
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -10,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        icon,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<GroupRepository>();
    final session = context.read<UserSession>();
    final groupContext = context.read<GroupContext>();
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: ChangeNotifierProvider(
        create: (_) => GroupNotifier(repository, session, groupContext),
        child: const _GroupView(),
      ),
    );
  }
}

class _GroupView extends StatefulWidget {
  const _GroupView();

  @override
  State<_GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<_GroupView> {
  final _nameCtrl = TextEditingController();
  final _groupIdCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<GroupNotifier>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Groups'),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coordinate with your crew',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new group or hop into an existing one with the invite ID.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _GradientCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a group',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Group name',
                        prefixIcon: Icon(Icons.emoji_people),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        onPressed:
                            notifier.isLoading
                                ? null
                                : () =>
                                    notifier.createGroup(_nameCtrl.text.trim()),
                        label: const Text('Create group'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _GradientCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join with an ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _groupIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Group ID',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.login),
                        onPressed:
                            notifier.isLoading
                                ? null
                                : () => notifier.joinGroup(
                                  _groupIdCtrl.text.trim(),
                                ),
                        label: const Text('Join group'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child:
                    notifier.message == null
                        ? const SizedBox.shrink()
                        : _GradientCard(
                          key: ValueKey(notifier.message),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 12),
                              Expanded(child: Text(notifier.message!)),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCard extends StatelessWidget {
  const _GradientCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.surface,
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 24),
            color: Color(0x33000000),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class GroupNotifier extends ChangeNotifier {
  GroupNotifier(this._repository, this._session, this._groupContext);

  final GroupRepository _repository;
  final UserSession _session;
  final GroupContext _groupContext;
  bool _loading = false;
  String? _message;

  bool get isLoading => _loading;
  String? get message => _message;

  Future<void> createGroup(String name) async {
    if (name.isEmpty) return;
    final userId = _session.userId;
    if (userId == null) {
      _message = 'Unable to determine user. Please sign in again.';
      notifyListeners();
      return;
    }
    await _run(() async {
      final id = await _repository.createGroup(name: name, userId: userId);
      await _repository.joinGroup(groupId: id, userId: userId);
      _groupContext.setActiveGroup(id);
      _message = 'Created group with id: $id';
    });
  }

  Future<void> joinGroup(String id) async {
    if (id.isEmpty) return;
    final userId = _session.userId;
    if (userId == null) {
      _message = 'Unable to determine user. Please sign in again.';
      notifyListeners();
      return;
    }
    await _run(() async {
      await _repository.joinGroup(groupId: id, userId: userId);
      _groupContext.setActiveGroup(id);
      _message = 'Joined group successfully';
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _loading = true;
    _message = null;
    notifyListeners();
    try {
      await action();
    } catch (_) {
      _message = 'Operation failed. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

abstract class GroupRepository {
  Future<String> createGroup({required String name, required String userId});
  Future<void> joinGroup({required String groupId, required String userId});
}

class SupabaseGroupRepository implements GroupRepository {
  SupabaseGroupRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createGroup({
    required String name,
    required String userId,
  }) async {
    final dbUserId = UserIdMapper.normalize(userId);
    await _ensureUser(dbUserId);
    final response =
        await _client
            .from('groups')
            .insert({'name': name, 'created_by': dbUserId})
            .select()
            .single();
    return response['id'].toString();
  }

  @override
  Future<void> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    final dbUserId = UserIdMapper.normalize(userId);
    await _ensureUser(dbUserId);
    await _client.from('group_members').upsert({
      'group_id': groupId,
      'user_id': dbUserId,
    }, onConflict: 'group_id,user_id');
  }

  Future<void> _ensureUser(String userId) {
    return _client.from('users').upsert({'id': userId}, onConflict: 'id');
  }
}
