import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';import '../../../core/theme/app_colors.dart';
import '../../../data/models/journal_entry.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../widgets/rich_text_editor.dart';

/// Screen for writing a new journal entry
class JournalWriteScreen extends StatefulWidget {
  final JournalEntryType type;
  final String? initialPrompt;

  const JournalWriteScreen({
    super.key,
    required this.type,
    this.initialPrompt,
  });

  @override
  State<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends State<JournalWriteScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<RichTextJournalEditorState> _richEditorKey = GlobalKey();
  
  String? _prompt;
  bool _isLoading = false;
  bool _isSaving = false;
  int _wordCount = 0;
  DateTime? _startTime;
  Timer? _autoSaveTimer;
  bool _useRichText = true; // Default to rich text mode

  @override
  void initState() {
    super.initState();
    _prompt = widget.initialPrompt;
    _startTime = DateTime.now();
    
    _controller.addListener(_onTextChanged);
    
    // Auto-save every 30 seconds
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _autoSave();
    });
    
    // Generate prompt if needed and not provided
    if (widget.type != JournalEntryType.free && _prompt == null) {
      _generatePrompt();
    }
    
    // Focus the text field after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final words = _useRichText 
        ? (_richEditorKey.currentState?.getWordCount() ?? 0)
        : _controller.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words != _wordCount) {
      setState(() {
        _wordCount = words;
      });
    }
  }

  void _generatePrompt() {
    setState(() => _isLoading = true);
    context.read<JournalBloc>().add(GeneratePrompt(type: widget.type));
  }

  void _autoSave() {
    if (_controller.text.trim().isNotEmpty) {
      // Could implement auto-save to local storage here
      debugPrint('Auto-saving journal entry...');
    }
  }

  Future<void> _saveEntry() async {
    final content = _useRichText 
        ? (_richEditorKey.currentState?.getPlainText() ?? '')
        : _controller.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    final writingDuration = _startTime != null 
        ? DateTime.now().difference(_startTime!).inSeconds 
        : 0;
    
    // Get rich text delta if using rich text editor
    final delta = _useRichText 
        ? _richEditorKey.currentState?.getDeltaJson()
        : null;

    context.read<JournalBloc>().add(SaveJournalEntry(
      content: content,
      richTextDelta: delta,
      type: widget.type,
      prompt: _prompt,
      writingDurationSeconds: writingDuration,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final hasContent = _useRichText
            ? (_richEditorKey.currentState?.hasContent() ?? false)
            : _controller.text.trim().isNotEmpty;
        
        if (hasContent) {
          final shouldDiscard = await _showDiscardDialog();
          if (shouldDiscard && context.mounted) {
            context.pop();
          }
        } else {
          context.pop();
        }
      },
      child: BlocListener<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state is PromptGenerated) {
            setState(() {
              _prompt = state.prompt.prompt;
              _isLoading = false;
            });
          } else if (state is JournalEntrySaved) {
            setState(() => _isSaving = false);
            // Ask if user wants AI analysis
            _showAnalysisDialog(state.entry);
          } else if (state is JournalError) {
            setState(() {
              _isLoading = false;
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.type.label} Entry'),
            actions: [
              if (_wordCount > 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '$_wordCount words',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              IconButton(
                onPressed: _isSaving ? null : _saveEntry,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                tooltip: 'Save Entry',
              ),
            ],
          ),
          body: Column(
            children: [
              // Prompt Section
              if (_isLoading)
                const LinearProgressIndicator()
              else if (_prompt != null)
                _PromptCard(prompt: _prompt!),
              
              // Writing Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _useRichText
                      ? RichTextJournalEditor(
                          key: _richEditorKey,
                          placeholder: _getHintText(),
                          autoFocus: true,
                          onContentChanged: (_) => _onTextChanged(),
                        )
                      : TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: _getHintText(),
                            border: InputBorder.none,
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                ),
              ),
              
              // Bottom Toolbar
              _WritingToolbar(
                useRichText: _useRichText,
                onToggleRichText: () {
                  setState(() => _useRichText = !_useRichText);
                },
                onInsertTimestamp: () {
                  final timestamp = TimeOfDay.now().format(context);
                  if (_useRichText) {
                    // For rich text, we'd need to insert at cursor
                    // For now, show a snackbar with the timestamp
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Timestamp: $timestamp')),
                    );
                  } else {
                    _controller.text = '${_controller.text}\n[$timestamp] ';
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  }
                },
                onNewPrompt: widget.type != JournalEntryType.free 
                    ? _generatePrompt 
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHintText() {
    switch (widget.type) {
      case JournalEntryType.free:
        return 'Start writing whatever comes to mind...';
      case JournalEntryType.prompted:
        return 'Reflect on the prompt above...';
      case JournalEntryType.gratitude:
        return 'What are you grateful for today?';
      case JournalEntryType.reflection:
        return 'Take a moment to reflect...';
      case JournalEntryType.goalSetting:
        return 'What goals do you want to achieve?';
      case JournalEntryType.emotionExplorer:
        return 'How are you feeling right now?';
    }
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Entry?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Writing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAnalysisDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Entry Saved!'),
          ],
        ),
        content: const Text(
          'Would you like AI to analyze your journal entry? This can help identify patterns and provide insights.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Navigate to journal screen (forces fresh load)
              context.go(AppRoutes.journal);
            },
            child: const Text('No Thanks'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Start analysis, then navigate to journal
              context.read<JournalBloc>().add(AnalyzeEntry(entryId: entry.id));
              context.go(AppRoutes.journal);
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }
}

/// Prompt display card
class _PromptCard extends StatelessWidget {
  final String prompt;

  const _PromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
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
            prompt,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Writing toolbar
class _WritingToolbar extends StatelessWidget {
  final bool useRichText;
  final VoidCallback onToggleRichText;
  final VoidCallback onInsertTimestamp;
  final VoidCallback? onNewPrompt;

  const _WritingToolbar({
    required this.useRichText,
    required this.onToggleRichText,
    required this.onInsertTimestamp,
    this.onNewPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // Rich text toggle
          Tooltip(
            message: useRichText ? 'Switch to plain text' : 'Switch to rich text',
            child: IconButton(
              onPressed: onToggleRichText,
              icon: Icon(
                useRichText ? Icons.text_format_rounded : Icons.format_bold_rounded,
                size: 20,
                color: useRichText ? AppColors.primary : null,
              ),
              tooltip: useRichText ? 'Rich text on' : 'Plain text',
            ),
          ),
          if (!useRichText) ...[
            IconButton(
              onPressed: onInsertTimestamp,
              icon: const Icon(Icons.schedule_rounded, size: 20),
              tooltip: 'Insert Timestamp',
            ),
          ],
          if (onNewPrompt != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onNewPrompt,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'New Prompt',
            ),
          ],
          const Spacer(),
          Text(
            useRichText ? 'Rich text enabled' : 'Tip: Just let your thoughts flow',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
