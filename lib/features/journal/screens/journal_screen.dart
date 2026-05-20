import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/journal_entry.dart';
import '../../../data/repositories/journal_repository.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

/// Main journal screen showing entry list with search and filter
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _searchController = TextEditingController();
  JournalEntryType? _selectedType;
  final List<String> _selectedMoodTags = [];
  bool _isSearchVisible = false;

  static const List<String> _availableMoodTags = [
    'Happy', 'Sad', 'Anxious', 'Calm', 'Stressed', 'Grateful',
    'Hopeful', 'Angry', 'Peaceful', 'Excited', 'Tired', 'Motivated'
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadEntries() {
    context.read<JournalBloc>().add(const LoadJournalEntries());
  }

  void _performSearch() {
    if (_searchController.text.isEmpty && 
        _selectedType == null && 
        _selectedMoodTags.isEmpty) {
      _loadEntries();
      return;
    }

    context.read<JournalBloc>().add(SearchJournalEntries(
      query: _searchController.text,
      filterType: _selectedType,
      filterMoodTags: _selectedMoodTags.isEmpty ? null : _selectedMoodTags,
    ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _selectedMoodTags.clear();
      _isSearchVisible = false;
    });
    context.read<JournalBloc>().add(const ClearJournalFilters());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _clearFilters();
                }
              });
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Journal Insights coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Journal Insights',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          if (_isSearchVisible) _buildSearchSection(context),
          
          // Main content
          Expanded(
            child: BlocConsumer<JournalBloc, JournalState>(
              listener: (context, state) {
                if (state is JournalEntrySaved ||
                    state is JournalEntryAnalyzed ||
                    state is JournalEntryDeleted ||
                    state is JournalEntryUpdated ||
                    state is PromptGenerated ||
                    state is JournalWritingState) {
                  context.read<JournalBloc>().add(const LoadJournalEntries());
                }
              },
              builder: (context, state) {
                if (state is JournalEntriesLoaded) {
                  return _buildContent(context, state.entries, state.statistics);
                }

                if (state is JournalSearchResults) {
                  return _buildSearchResults(context, state);
                }

                if (state is JournalError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadEntries,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is JournalInitial) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadEntries();
                  });
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search journal entries...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (_) => _performSearch(),
          ),
          const SizedBox(height: 12),

          // Type filter chips
          Text(
            'Filter by type',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    setState(() => _selectedType = null);
                    _performSearch();
                  },
                ),
                const SizedBox(width: 8),
                ...JournalEntryType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.label),
                    selected: _selectedType == type,
                    selectedColor: _getTypeColor(type).withOpacity(0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                      _performSearch();
                    },
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mood tag filter
          Text(
            'Filter by mood',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableMoodTags.map((tag) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(tag),
                  selected: _selectedMoodTags.contains(tag),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMoodTags.add(tag);
                      } else {
                        _selectedMoodTags.remove(tag);
                      }
                    });
                    _performSearch();
                  },
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Clear filters button
          if (_searchController.text.isNotEmpty ||
              _selectedType != null ||
              _selectedMoodTags.isNotEmpty)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, JournalSearchResults state) {
    final theme = Theme.of(context);

    if (state.entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No entries found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${state.totalResults} ${state.totalResults == 1 ? 'result' : 'results'}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = state.entries[index];
              return _JournalEntryCard(
                entry: entry,
                searchQuery: state.query,
                onTap: () => _viewEntry(context, entry),
                onEdit: () => _editEntry(context, entry),
              );
            },
            childCount: state.entries.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<JournalEntry> entries, JournalStatistics? statistics) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return CustomScrollView(
      slivers: [
        // Stats Card
        if (statistics != null)
          SliverToBoxAdapter(
            child: _buildStatsCard(context, statistics),
          ),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Prompt',
                    color: AppColors.primary,
                    onTap: () => _generatePromptAndStart(context, JournalEntryType.prompted),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.favorite_rounded,
                    label: 'Gratitude',
                    color: AppColors.secondary,
                    onTap: () => _generatePromptAndStart(context, JournalEntryType.gratitude),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.edit_note_rounded,
                    label: 'Free Write',
                    color: AppColors.primaryAlt,
                    onTap: () => _startEntry(context, JournalEntryType.free, null),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Recent Entries Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Recent Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Entries List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = entries[index];
              return _JournalEntryCard(
                entry: entry,
                onTap: () => _viewEntry(context, entry),
                onEdit: () => _editEntry(context, entry),
              );
            },
            childCount: entries.length,
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, JournalStatistics stats) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Journey',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.book_rounded,
                  value: '${stats.totalEntries}',
                  label: 'Entries',
                ),
                _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '${stats.streakDays}',
                  label: 'Day Streak',
                ),
                _StatItem(
                  icon: Icons.text_fields_rounded,
                  value: '${stats.totalWords}',
                  label: 'Words',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Your Journal',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Journaling helps you process emotions, track patterns, and gain insights into your well-being.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showEntryTypeSheet(context),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Write Your First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _EntryTypeSheet(
        onTypeSelected: (type) {
          Navigator.pop(context);
          if (type == JournalEntryType.free) {
            _startEntry(context, type, null);
          } else {
            _generatePromptAndStart(context, type);
          }
        },
      ),
    );
  }

  void _generatePromptAndStart(BuildContext context, JournalEntryType type) {
    context.read<JournalBloc>().add(GeneratePrompt(type: type));
    context.push('/journal/write', extra: {'type': type});
  }

  void _startEntry(BuildContext context, JournalEntryType type, String? prompt) {
    context.read<JournalBloc>().add(StartJournalEntry(type: type, prompt: prompt));
    context.push('/journal/write', extra: {'type': type, 'prompt': prompt});
  }

  void _viewEntry(BuildContext context, JournalEntry entry) {
    context.push('/journal/view', extra: {'entry': entry});
  }

  void _editEntry(BuildContext context, JournalEntry entry) {
    context.push('/journal/write', extra: {
      'type': entry.type,
      'prompt': entry.prompt,
      'entry': entry,
      'isEditing': true,
    });
  }

  Color _getTypeColor(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.free:
        return AppColors.primaryAlt;
      case JournalEntryType.prompted:
        return AppColors.primary;
      case JournalEntryType.gratitude:
        return AppColors.secondary;
      case JournalEntryType.reflection:
        return Colors.purple;
      case JournalEntryType.goalSetting:
        return Colors.orange;
      case JournalEntryType.emotionExplorer:
        return Colors.pink;
    }
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Journal entry card with edit support
class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final String? searchQuery;

  const _JournalEntryCard({
    required this.entry,
    required this.onTap,
    this.onEdit,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: InkWell(
          onTap: onTap,
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(entry.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.type.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(entry.type),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: onEdit,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Edit entry',
                      ),
                    Text(
                      _formatDate(entry.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildHighlightedText(
                  context,
                  entry.content.length > 150
                      ? '${entry.content.substring(0, 150)}...'
                      : entry.content,
                ),
                if (entry.themes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: entry.themes!.take(3).map((theme) => Chip(
                      label: Text(theme),
                      labelStyle: const TextStyle(fontSize: 10),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
                if (entry.emotions?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: entry.emotions!.take(3).map((emotion) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.text_fields_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.wordCount} words',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (entry.aiAnalysis != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Analyzed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text) {
    final theme = Theme.of(context);
    
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: theme.textTheme.bodyMedium,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    final queryLower = searchQuery!.toLowerCase();
    final textLower = text.toLowerCase();
    final spans = <TextSpan>[];
    
    int start = 0;
    int index;
    
    while ((index = textLower.indexOf(queryLower, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery!.length),
        style: TextStyle(
          backgroundColor: AppColors.primary.withOpacity(0.3),
          fontWeight: FontWeight.w600,
        ),
      ));
      start = index + searchQuery!.length;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: spans,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getTypeColor(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.free:
        return AppColors.primaryAlt;
      case JournalEntryType.prompted:
        return AppColors.primary;
      case JournalEntryType.gratitude:
        return AppColors.secondary;
      case JournalEntryType.reflection:
        return Colors.purple;
      case JournalEntryType.goalSetting:
        return Colors.orange;
      case JournalEntryType.emotionExplorer:
        return Colors.pink;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Entry type selection sheet
class _EntryTypeSheet extends StatelessWidget {
  final Function(JournalEntryType) onTypeSelected;

  const _EntryTypeSheet({required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Entry Type',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...JournalEntryType.values.map((type) => ListTile(
            leading: Icon(_getTypeIcon(type), color: _getTypeColor(type)),
            title: Text(type.label),
            subtitle: Text(type.description),
            onTap: () => onTypeSelected(type),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getTypeIcon(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.free:
        return Icons.edit_note_rounded;
      case JournalEntryType.prompted:
        return Icons.auto_awesome_rounded;
      case JournalEntryType.gratitude:
        return Icons.favorite_rounded;
      case JournalEntryType.reflection:
        return Icons.psychology_rounded;
      case JournalEntryType.goalSetting:
        return Icons.flag_rounded;
      case JournalEntryType.emotionExplorer:
        return Icons.emoji_emotions_rounded;
    }
  }

  Color _getTypeColor(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.free:
        return AppColors.primaryAlt;
      case JournalEntryType.prompted:
        return AppColors.primary;
      case JournalEntryType.gratitude:
        return AppColors.secondary;
      case JournalEntryType.reflection:
        return Colors.purple;
      case JournalEntryType.goalSetting:
        return Colors.orange;
      case JournalEntryType.emotionExplorer:
        return Colors.pink;
    }
  }
}
