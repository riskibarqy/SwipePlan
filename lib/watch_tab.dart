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

        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Swipe', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'A weekend ritual through scenic stories',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              _SwipeOverview(controller: controller),
              const SizedBox(height: 18),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: content,
                ),
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final summary =
        controller.queueLength == 0
            ? 'No items in the queue yet'
            : '${controller.currentPosition}/${controller.queueLength} in rotation';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: AppShadows.layered,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Queue status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(summary, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0, end: controller.progress),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value.clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: Colors.black.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation(
                            theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.queueLength == 0
                      ? '—'
                      : '${(controller.progress * 100).round()}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.queueLength == 0
                      ? 'Load picks'
                      : '${controller.remainingCount} left',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GhibliCardShell extends StatelessWidget {
  const _GhibliCardShell({required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.surface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: AppShadows.layered,
      ),
      child: Padding(padding: const EdgeInsets.all(28), child: child),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
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
        child: _GhibliCardShell(
          gradient: const LinearGradient(
            colors: [Color(0xFFFBEFE0), Color(0xFFF3E1D5), Color(0xFFD7E8D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.15),
                ),
                child: Icon(
                  icon,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (trailing != null) ...[const SizedBox(height: 18), trailing!],
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(height: 22),
                FilledButton.tonal(
                  onPressed: onActionPressed,
                  child: Text(actionLabel!),
                ),
              ],
            ],
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
    final theme = Theme.of(context);
    final imageUrl = 'https://picsum.photos/seed/${item.id}/700/900';
    final total = controller.queueLength == 0 ? 1 : controller.queueLength;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    boxShadow: AppShadows.layered,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFC2CEBF),
                                        Color(0xFFE7D7C8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          color: AppPalette.parchment,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(36),
                            bottomRight: Radius.circular(36),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description.isEmpty
                                  ? 'No description available yet. Add a blurb so your crew knows the vibe.'
                                  : item.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: _buildHighlightChips(item.description),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [AppShadows.soft],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Trip',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${controller.currentPosition}/$total',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SwipeButton(
                  label: 'Skip',
                  icon: Icons.close_rounded,
                  color: theme.colorScheme.secondary,
                  onPressed: controller.skipCurrent,
                ),
                const SizedBox(width: 16),
                _SwipeButton(
                  label: 'Save it',
                  icon: Icons.favorite,
                  color: theme.colorScheme.primary,
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
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Love it'),
                                ),
                              ],
                            ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to record swipe')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHighlightChips(String description) {
    final descriptionHighlights = _extractHighlights(description);
    return descriptionHighlights
        .map((label) => _TagChip(label: label))
        .toList();
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
    final borderRadius = BorderRadius.circular(26);
    final ButtonStyle style =
        filled
            ? FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            )
            : OutlinedButton.styleFrom(
              foregroundColor: color,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.2),
              minimumSize: const Size.fromHeight(56),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            );

    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon), const SizedBox(width: 8), Text(label)],
    );

    return Expanded(
      child:
          filled
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

List<String> _extractHighlights(String description) {
  final cleaned = description.trim();
  if (cleaned.isEmpty) {
    return const ['Comfort pick', 'Fresh drop'];
  }
  final words = cleaned
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9 ]'), ' ')
      .split(RegExp(r'\s+'));
  final highlights = <String>[];
  for (final word in words) {
    if (word.isEmpty || word.length < 4) continue;
    final formatted = word[0].toUpperCase() + word.substring(1);
    if (!highlights.contains(formatted)) {
      highlights.add(formatted);
    }
    if (highlights.length == 3) break;
  }
  return highlights.isEmpty ? const ['Comfort pick', 'Fresh drop'] : highlights;
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
  int get currentPosition {
    if (_items.isEmpty) return 0;
    return currentItem == null
        ? _items.length
        : math.min(_index + 1, _items.length);
  }

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
