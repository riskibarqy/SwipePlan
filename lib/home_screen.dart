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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SwipePlan', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                  'Plan better watch parties together',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton.filledTonal(
                tooltip: 'Groups',
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GroupScreen()),
                    ),
                icon: const Icon(Icons.group),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Sign out',
                onPressed: () async {
                  final config = context.read<AppConfig>();
                  if (config.usesSupabaseAuth) {
                    await Supabase.instance.client.auth.signOut();
                  } else {
                    await ClerkAuth.of(context, listen: false).signOut();
                  }
                },
                icon: const Icon(Icons.logout),
              ),
              const SizedBox(width: 12),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'Watch'),
                      Tab(text: 'Trip'),
                      Tab(text: 'Schedule'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: TabBarView(
              children: [WatchTab(), _TripTab(), _ScheduleTab()],
            ),
          ),
        ),
      ),
    );
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
            gradient: AppGradients.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                offset: const Offset(0, 24),
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new group or hop into an existing one with the invite ID.',
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
              ),
              const SizedBox(height: 24),
              _GradientCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a group',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                                : () => notifier.createGroup(
                                      _nameCtrl.text.trim(),
                                    ),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
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
