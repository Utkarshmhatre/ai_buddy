import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Row of quick action buttons
class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onChatTap;
  final VoidCallback? onMoodTap;
  final VoidCallback? onBreatheTap;

  const QuickActionsRow({
    super.key,
    this.onChatTap,
    this.onMoodTap,
    this.onBreatheTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Talk',
            color: AppColors.primary, // Use solid primary instead of empathyTint
            onTap: onChatTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_reaction_outlined,
            label: 'Check In',
            color: AppColors.primaryAlt, // Use solid primaryAlt instead of encouragementTint
            onTap: onMoodTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.air_rounded,
            label: 'Breathe',
            color: AppColors.secondary, // Use solid secondary instead of calmTint
            onTap: onBreatheTap,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Use solid colors that are visible in both themes
    final iconColor = isDark ? color : color.withValues(alpha: 0.9);
    final bgColor = isDark 
        ? color.withValues(alpha: 0.3) 
        : color.withValues(alpha: 0.15);
    
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
