import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/user_session.dart';
import 'groups/group_context.dart';
import 'groups/group_repository.dart';
import 'watch_tab.dart';
import 'theme/app_theme.dart';
import 'theme/ghibli_decorations.dart';
import 'groups_tab.dart';
import 'matches_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.groups_3_outlined, label: 'Groups'),
    _NavItem(icon: Icons.terrain, label: 'Swipe'),
    _NavItem(icon: Icons.favorite_border, label: 'Matches'),
    _NavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GroupsTab(onManageGroups: _openGroupManager),
      const WatchTab(),
      const MatchesTab(),
      ProfileTab(onSignOut: _signOut),
    ];
  }

  void _handleNav(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  Future<void> _openGroupManager() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GroupScreen()));
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return GhibliBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _pages),
                ),
                const SizedBox(height: 16),
                _GhibliBottomNav(
                  items: _navItems,
                  selectedIndex: _currentIndex,
                  onItemSelected: _handleNav,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _GhibliBottomNav extends StatelessWidget {
  const _GhibliBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: AppShadows.layered,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _BottomNavItem(
                  item: items[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onItemSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = isSelected ? colorScheme.primary : colorScheme.outline;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.secondary.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.secondary.withValues(alpha: 0.4)
                    : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: baseColor),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: baseColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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
