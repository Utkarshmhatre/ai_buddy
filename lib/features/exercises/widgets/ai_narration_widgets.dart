import 'package:flutter/material.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../core/theme/app_colors.dart';

/// Widget that displays AI-generated exercise narration
class AINarrationCard extends StatelessWidget {
  final ExerciseStep? currentStep;
  final String? introMessage;
  final bool isLoading;
  final bool showEncouragement;

  const AINarrationCard({
    super.key,
    this.currentStep,
    this.introMessage,
    this.isLoading = false,
    this.showEncouragement = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Badge
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'AI Guidance',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (isLoading)
            _buildLoadingState(theme)
          else if (currentStep != null)
            _buildStepContent(theme)
          else if (introMessage != null)
            _buildIntroContent(theme),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          'Preparing personalized guidance...',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroContent(ThemeData theme) {
    return Text(
      introMessage!,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.5,
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main instruction
        Text(
          currentStep!.instruction,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        
        // Guidance
        if (currentStep!.guidance != null) ...[
          const SizedBox(height: 8),
          Text(
            currentStep!.guidance!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
        
        // Encouragement
        if (showEncouragement && currentStep!.encouragement != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💚', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    currentStep!.encouragement!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Completion card shown after exercise
class ExerciseCompletionCard extends StatelessWidget {
  final String completionMessage;
  final VoidCallback? onDone;
  final VoidCallback? onRepeat;

  const ExerciseCompletionCard({
    super.key,
    required this.completionMessage,
    this.onDone,
    this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'Well Done!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Completion message
          Text(
            completionMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onRepeat != null)
                OutlinedButton.icon(
                  onPressed: onRepeat,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Repeat'),
                ),
              if (onRepeat != null && onDone != null)
                const SizedBox(width: 12),
              if (onDone != null)
                FilledButton.icon(
                  onPressed: onDone,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Done'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
