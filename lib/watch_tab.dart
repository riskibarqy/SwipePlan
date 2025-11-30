import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/user_id_mapper.dart';
import 'auth/user_session.dart';
import 'groups/group_context.dart';
import 'theme/app_theme.dart';

class WatchTab extends StatelessWidget {
  const WatchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final activeGroupId = context.watch<GroupContext>().activeGroupId;
    return Consumer<WatchController>(
      builder: (context, controller, _) {
        if (activeGroupId == null) {
          return const _StateCard(
            icon: Icons.groups_2,
            title: 'No active group yet',
            message:
                'Tap the group button in the corner to create a space or join your friends.',
          );
        }

        final item = controller.currentItem;
        Widget content;
        if (controller.isLoading) {
          content = const _StateCard(
            icon: Icons.slow_motion_video,
            title: 'Loading your queue',
            message: 'Give us a sec while we fetch new titles.',
            trailing: CircularProgressIndicator(),
          );
        } else if (controller.errorMessage != null) {
          content = _StateCard(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            message: controller.errorMessage!,
            actionLabel: 'Retry',
            onActionPressed: () => controller.loadItems(),
          );
        } else if (item == null) {
          content = _StateCard(
            icon: Icons.inbox,
            title: 'You are all caught up',
            message: 'Refresh the queue to see newer picks.',
            actionLabel: 'Refresh',
            onActionPressed: () => controller.loadItems(),
          );
        } else {
          content = _SwipeCard(item: item, controller: controller);
        }

        return Column(
          children: [
            _SwipeOverview(controller: controller),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                child: content,
              ),
            ),
          ],
        );
      },
    );
  }
}

class WatchItem {
  const WatchItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  factory WatchItem.fromMap(Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(
      data['payload'] as Map? ?? const {},
    );
    return WatchItem(
      id: data['id'].toString(),
      title: payload['title']?.toString() ?? 'Untitled',
      description: payload['description']?.toString() ?? '',
    );
  }
}

class _SwipeOverview extends StatelessWidget {
  const _SwipeOverview({required this.controller});

  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.surface,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swipe queue',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.queueLength == 0
                        ? 'No items yet'
                        : '${controller.queueLength} picks · '
                            '${controller.remainingCount} remaining',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Column(
                children: [
                  Text(
                    '${(controller.progress * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: controller.progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.surface,
            borderRadius: BorderRadius.all(Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: Offset(0, 18),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 18),
                  trailing!,
                ],
                if (actionLabel != null && onActionPressed != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.tonal(
                    onPressed: onActionPressed,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeCard extends StatelessWidget {
  const _SwipeCard({required this.item, required this.controller});

  final WatchItem item;
  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.surface,
            borderRadius: BorderRadius.all(Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                offset: Offset(0, 24),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'New suggestion',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  item.description.isEmpty
                      ? 'No description available yet.'
                      : item.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SwipeButton(
                      label: 'Skip',
                      icon: Icons.close_rounded,
                      color: Colors.redAccent,
                      onPressed: controller.skipCurrent,
                    ),
                    const SizedBox(width: 16),
                    _SwipeButton(
                      label: 'Save it',
                      icon: Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                      filled: true,
                      onPressed: () async {
                        final title = item.title;
                        try {
                          final matched = await controller.likeCurrent();
                          if (!context.mounted || !matched) return;
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("It's a match!"),
                                  content: Text("You matched on '$title'."),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('Love it'),
                                    ),
                                  ],
                                ),
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to record swipe'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeButton extends StatelessWidget {
  const _SwipeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Future<void> Function()? onPressed;
  final bool filled;

  void _handlePress() {
    final callback = onPressed;
    if (callback != null) {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = filled
        ? FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 18),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.6)),
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 18),
          );

    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(label),
      ],
    );

    return Expanded(
      child: filled
          ? FilledButton(
              style: style,
              onPressed: _handlePress,
              child: child,
            )
          : OutlinedButton(
              style: style,
              onPressed: _handlePress,
              child: child,
            ),
    );
  }
}

class WatchController extends ChangeNotifier {
  WatchController({
    required WatchRepository watchRepository,
    required SwipeService swipeService,
  }) : _watchRepository = watchRepository,
       _swipeService = swipeService {
    loadItems();
  }

  final WatchRepository _watchRepository;
  final SwipeService _swipeService;
  final List<WatchItem> _items = [];
  int _index = 0;
  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get errorMessage => _error;
  int get remainingCount =>
      math.max(_items.length - _index - (currentItem == null ? 0 : 1), 0);
  int get queueLength => _items.length;
  double get progress =>
      _items.isEmpty ? 0 : (_index / _items.length).clamp(0.0, 1.0);
  WatchItem? get currentItem =>
      _items.isEmpty || _index >= _items.length ? null : _items[_index];

  Future<void> loadItems() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _watchRepository.fetchItems(limit: 25);
      _items
        ..clear()
        ..addAll(data);
      _index = 0;
    } catch (_) {
      _error = 'Failed to load items';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> likeCurrent() => _recordSwipe(decision: true);

  Future<void> skipCurrent() async {
    await _recordSwipe(decision: false);
  }

  Future<bool> _recordSwipe({required bool decision}) async {
    final item = currentItem;
    final userId = _swipeService.currentUserId;
    if (item == null || userId == null) {
      return false;
    }
    try {
      final matched = await _swipeService.swipe(
        itemId: item.id,
        userId: userId,
        decision: decision,
      );
      return matched;
    } on StateError catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Failed to record swipe';
      notifyListeners();
      return false;
    } finally {
      _advance();
    }
  }

  void _advance() {
    if (_items.isEmpty) return;
    _index = math.min(_index + 1, _items.length);
    notifyListeners();
  }
}

abstract class WatchRepository {
  Future<List<WatchItem>> fetchItems({int limit = 25});
}

class SupabaseWatchRepository implements WatchRepository {
  SupabaseWatchRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<WatchItem>> fetchItems({int limit = 25}) async {
    final response = await _client
        .from('items')
        .select()
        .eq('type', 'watch')
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(
      response as List,
    ).map(WatchItem.fromMap).toList();
  }
}

abstract class SwipeService {
  String? get currentUserId;
  Future<bool> swipe({
    required String itemId,
    required String userId,
    required bool decision,
  });
}

class SupabaseSwipeService implements SwipeService {
  SupabaseSwipeService(this._client, this._session, this._groupContext);

  final SupabaseClient _client;
  final UserSession _session;
  final GroupContext _groupContext;

  @override
  String? get currentUserId => _client.auth.currentUser?.id ?? _session.userId;

  @override
  Future<bool> swipe({
    required String itemId,
    required String userId,
    required bool decision,
  }) async {
    final groupId = _groupContext.activeGroupId;
    if (groupId == null) {
      throw StateError('Select a group before swiping.');
    }

    final dbUserId = UserIdMapper.normalize(userId);
    await _client.from('swipes').upsert({
      'user_id': dbUserId,
      'group_id': groupId,
      'item_id': itemId,
      'decision': decision,
    }, onConflict: 'user_id,group_id,item_id');

    if (!decision) {
      return false;
    }

    final response = await _client.functions.invoke(
      'evaluateMatch',
      body: {'itemId': itemId, 'groupId': groupId},
    );
    final data = response.data;
    return data is Map && data['matched'] == true;
  }
}
