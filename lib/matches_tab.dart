import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  final List<String> _filters = const ['All', 'Trip', 'Watch', 'Plan'];
  String _selected = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data =
        _selected == 'All'
            ? _matchStories
            : _matchStories.where((m) => m.category == _selected).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppPalette.terracotta),
              const SizedBox(width: 8),
              Text('Your Matches', style: theme.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${data.length} adventures everyone loves',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                _filters.map((filter) {
                  final selected = filter == _selected;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) => setState(() => _selected = filter),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color:
                          selected ? Colors.white : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          for (final match in data) ...[
            _MatchCard(data: match),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.data});

  final MatchStory data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: AppShadows.layered,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: data.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(data.icon, color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.timeline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: AppPalette.terracotta,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.participants,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.secondary.withValues(
                alpha: 0.2,
              ),
              child: Icon(Icons.more_horiz, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchStory {
  const MatchStory({
    required this.title,
    required this.timeline,
    required this.participants,
    required this.category,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String timeline;
  final String participants;
  final String category;
  final IconData icon;
  final List<Color> colors;
}

const _matchStories = [
  MatchStory(
    title: 'Mountain Hiking Adventure',
    timeline: 'Today',
    participants: 'You, Sarah, Mike',
    category: 'Trip',
    icon: Icons.terrain,
    colors: [Color(0xFFB6C7BE), Color(0xFF8AA690)],
  ),
  MatchStory(
    title: 'Spirited Away Rewatch',
    timeline: 'Yesterday',
    participants: 'You, Sarah',
    category: 'Watch',
    icon: Icons.movie,
    colors: [Color(0xFFE8DFC9), Color(0xFFD4BBA0)],
  ),
  MatchStory(
    title: 'Saturday Brunch Plans',
    timeline: '2 days ago',
    participants: 'You, Sarah, Mike...',
    category: 'Plan',
    icon: Icons.brunch_dining,
    colors: [Color(0xFFF3E3CD), Color(0xFFDAC0A2)],
  ),
];
