import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/analytics/beta_feedback_service.dart';

/// Feedback screen for beta testing
/// Allows users to submit feedback about their experience
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  FeedbackCategory _category = FeedbackCategory.general;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  BetaFeedbackService? _feedbackService;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    _feedbackService = await BetaFeedbackService.create();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _feedbackService?.submitFeedback(UserFeedback(
        rating: _rating,
        category: _category,
        comment: _commentController.text.isNotEmpty 
            ? _commentController.text 
            : null,
      ));

      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });

      // Show success and navigate back after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isSubmitted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Feedback'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 64,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Thank You!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your feedback helps us improve AI Buddy for everyone.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beta Feedback'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.science_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thank you for beta testing AI Buddy! Your feedback is invaluable.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rating section
            Text(
              'How would you rate your experience?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildRatingStars(),
            const SizedBox(height: 32),

            // Category selection
            Text(
              'What area is your feedback about?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 32),

            // Comment field
            Text(
              'Additional comments (optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Tell us what you liked, what could be better, or any bugs you found...',
                filled: true,
                fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your feedback is stored locally and never shared without your consent.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _rating = starIndex);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedScale(
              scale: _rating >= starIndex ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _rating >= starIndex ? Icons.star : Icons.star_border,
                size: 44,
                color: _rating >= starIndex
                    ? Colors.amber
                    : Theme.of(context).colorScheme.outline,
                semanticLabel: '$starIndex stars',
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      (FeedbackCategory.general, 'General', Icons.apps),
      (FeedbackCategory.chat, 'Chat', Icons.chat_bubble_outline),
      (FeedbackCategory.journal, 'Journal', Icons.book_outlined),
      (FeedbackCategory.mood, 'Mood', Icons.mood_outlined),
      (FeedbackCategory.exercises, 'Exercises', Icons.self_improvement_outlined),
      (FeedbackCategory.accessibility, 'Accessibility', Icons.accessibility_new),
      (FeedbackCategory.crisis, 'Crisis Support', Icons.health_and_safety_outlined),
      (FeedbackCategory.bug, 'Bug Report', Icons.bug_report_outlined),
      (FeedbackCategory.feature, 'Feature Request', Icons.lightbulb_outline),
      (FeedbackCategory.design, 'Design', Icons.palette_outlined),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _category == cat.$1;
        return FilterChip(
          selected: isSelected,
          showCheckmark: false,
          avatar: Icon(
            cat.$3,
            size: 18,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          label: Text(cat.$2),
          onSelected: (selected) {
            HapticFeedback.selectionClick();
            setState(() => _category = cat.$1);
          },
        );
      }).toList(),
    );
  }
}

/// Quick feedback FAB widget
/// Shows a floating button that opens feedback screen
class FeedbackFab extends StatelessWidget {
  const FeedbackFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'feedback_fab',
      tooltip: 'Send Feedback',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FeedbackScreen(),
          ),
        );
      },
      child: const Icon(Icons.feedback_outlined),
    );
  }
}

/// Bug report shortcut dialog
/// Quick way to report bugs with pre-filled category
class BugReportDialog extends StatefulWidget {
  final String? prefilledDescription;

  const BugReportDialog({
    super.key,
    this.prefilledDescription,
  });

  @override
  State<BugReportDialog> createState() => _BugReportDialogState();
}

class _BugReportDialogState extends State<BugReportDialog> {
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledDescription != null) {
      _descriptionController.text = widget.prefilledDescription!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitBugReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the bug'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = await BetaFeedbackService.create();
      await service.submitFeedback(UserFeedback(
        rating: 1, // Bug reports default to lowest rating
        category: FeedbackCategory.bug,
        comment: _descriptionController.text,
      ));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bug report submitted. Thank you!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bug_report, color: colors.error),
          const SizedBox(width: 8),
          const Text('Report a Bug'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please describe what happened:',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'What were you doing when the bug occurred?',
              filled: true,
              fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitBugReport,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

/// Shows bug report dialog
Future<bool?> showBugReportDialog(
  BuildContext context, {
  String? prefilledDescription,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => BugReportDialog(
      prefilledDescription: prefilledDescription,
    ),
  );
}
