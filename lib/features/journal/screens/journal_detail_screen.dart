import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/journal_entry.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../widgets/rich_text_editor.dart';

/// Screen to view a journal entry detail
class JournalDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const JournalDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late JournalEntry _entry;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<JournalBloc, JournalState>(
      listenWhen: (previous, current) {
        // Only listen for states relevant to this screen
        return current is JournalEntryAnalyzed ||
               current is JournalEntryDeleted ||
               current is JournalError ||
               (current is JournalLoading && _isAnalyzing);
      },
      listener: (context, state) {
        if (state is JournalEntryAnalyzed) {
          // Update the entry with AI analysis results
          if (state.entry.id == _entry.id) {
            setState(() {
              _entry = state.entry;
              _isAnalyzing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI analysis complete!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (state is JournalEntryDeleted) {
          if (state.entryId == _entry.id) {
            context.pop();
          }
        } else if (state is JournalError) {
          setState(() => _isAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar.large(
              title: Text(_entry.type.label),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'analyze') {
                      _analyzeEntry();
                    } else if (value == 'delete') {
                      _showDeleteDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'analyze',
                      child: ListTile(
                        leading: Icon(Icons.auto_awesome_rounded),
                        title: Text('Analyze with AI'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        title: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Stats
                    _buildMetadata(context),
                    
                    const SizedBox(height: 24),
                    
                    // Prompt (if any)
                    if (_entry.prompt != null) ...[
                      _buildPromptSection(context),
                      const SizedBox(height: 24),
                    ],
                    
                    // Content
                    _buildContentSection(context),
                    
                    // AI Analysis
                    if (_isAnalyzing) ...[
                      const SizedBox(height: 24),
                      _buildAnalyzingIndicator(context),
                    ] else if (_entry.aiAnalysis != null) ...[
                      const SizedBox(height: 24),
                      _buildAnalysisSection(context),
                    ],
                    
                    // Themes
                    if (_entry.themes?.isNotEmpty == true) ...[
                      const SizedBox(height: 24),
                      _buildThemesSection(context),
                    ],
                    
                    // Emotions
                    if (_entry.emotions?.isNotEmpty == true) ...[
                      const SizedBox(height: 24),
                      _buildEmotionsSection(context),
                    ],
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _entry.aiAnalysis == null && !_isAnalyzing
            ? FloatingActionButton.extended(
                onPressed: _analyzeEntry,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Get AI Insights'),
              )
            : null,
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getTypeColor(_entry.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _entry.type.label,
            style: TextStyle(
              color: _getTypeColor(_entry.type),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(_entry.createdAt),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_entry.wordCount} words • ${_formatDuration(_entry.writingDurationSeconds ?? 0)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromptSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Prompt',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _entry.prompt!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Entry',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_entry.hasRichText) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rich Text',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _entry.hasRichText
              ? RichTextViewer(deltaJson: _entry.richTextDelta!)
              : SelectableText(
                  _entry.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Text(
            'Analyzing your entry...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = _entry.aiAnalysis!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'AI Insights',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Score (derived from entry if available)
              if (_entry.derivedMoodScore != null)
                _AnalysisItem(
                  icon: Icons.mood_rounded,
                  title: 'Mood Score',
                  content: _getMoodLabel(_entry.derivedMoodScore!.toDouble()),
                  color: _getMoodColor(_entry.derivedMoodScore!.toDouble()),
                ),
              
              if (_entry.derivedMoodScore != null)
                const SizedBox(height: 16),
              
              // AI Analysis text
              Text(
                analysis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemesSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Themes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _entry.themes!.map((theme) => Chip(
            label: Text(theme),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildEmotionsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotions Detected',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _entry.emotions!.map((emotion) => Chip(
            avatar: Text(_getEmotionEmoji(emotion)),
            label: Text(emotion),
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          )).toList(),
        ),
      ],
    );
  }

  void _analyzeEntry() {
    setState(() => _isAnalyzing = true);
    context.read<JournalBloc>().add(AnalyzeEntry(entryId: _entry.id));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<JournalBloc>().add(DeleteJournalEntry(entryId: _entry.id));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }

  String _getMoodLabel(double score) {
    if (score >= 4) return 'Very Positive';
    if (score >= 3) return 'Positive';
    if (score >= 2) return 'Neutral';
    if (score >= 1) return 'Low';
    return 'Very Low';
  }

  Color _getMoodColor(double score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.lightGreen;
    if (score >= 2) return Colors.amber;
    if (score >= 1) return Colors.orange;
    return Colors.red;
  }

  String _getEmotionEmoji(String emotion) {
    final emojiMap = {
      'happy': '😊',
      'sad': '😢',
      'anxious': '😰',
      'angry': '😠',
      'peaceful': '😌',
      'excited': '🤩',
      'grateful': '🙏',
      'hopeful': '✨',
      'tired': '😴',
      'stressed': '😫',
      'content': '😊',
      'frustrated': '😤',
      'lonely': '🥺',
      'loved': '🥰',
    };
    return emojiMap[emotion.toLowerCase()] ?? '💭';
  }
}

/// Analysis item widget
class _AnalysisItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _AnalysisItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(content, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
