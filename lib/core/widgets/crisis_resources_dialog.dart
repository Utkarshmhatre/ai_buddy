import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/models.dart';
import '../safety/crisis_detection_service.dart';
import '../theme/app_colors.dart';

/// Enhanced crisis resources dialog with better UX and international support
class CrisisResourcesDialog extends StatelessWidget {
  final CrisisSeverity severity;
  final String? countryCode;
  final VoidCallback? onDismiss;
  final VoidCallback? onResourceTapped;

  const CrisisResourcesDialog({
    super.key,
    required this.severity,
    this.countryCode,
    this.onDismiss,
    this.onResourceTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCritical = severity == CrisisSeverity.critical;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCritical ? AppColors.crisis : AppColors.warning,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCritical ? AppColors.crisis : AppColors.warning)
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, isCritical, isDark),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supportive message
                    _buildSupportiveMessage(theme),
                    const SizedBox(height: 20),
                    
                    // Primary action - Call
                    _buildPrimaryAction(context, isDark),
                    const SizedBox(height: 12),
                    
                    // Emergency 911 Button
                    _buildEmergency911Button(context, isDark),
                    const SizedBox(height: 12),
                    
                    // Secondary actions
                    _buildSecondaryActions(context, isDark),
                    const SizedBox(height: 16),
                    
                    // Additional resources
                    _buildAdditionalResources(context, theme),
                    const SizedBox(height: 20),
                    
                    // Continue talking option
                    _buildContinueOption(context, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCritical, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isCritical ? AppColors.crisis : AppColors.warning)
            .withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCritical ? AppColors.crisis : AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCritical ? Icons.emergency_rounded : Icons.favorite_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical ? 'We\'re Here For You' : 'Support Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You don\'t have to face this alone',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportiveMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'What you\'re feeling is valid. Reaching out takes courage, and trained counselors are ready to help you through this moment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction(BuildContext context, bool isDark) {
    final resources = CrisisResourcesProvider.countryResources[countryCode ?? 'US'] 
        ?? CrisisResourcesProvider.countryResources['US']!;
    
    return Material(
      color: AppColors.crisis,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _callNumber(resources['main']!),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Call Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resources['main']} • ${resources['name']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Free • Confidential • 24/7',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergency911Button(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEmergencyConfirmation(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE53935), // Emergency red
              width: 2,
            ),
            color: const Color(0xFFE53935).withOpacity(0.1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Call 911 Emergency',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'For immediate life-threatening emergencies',
                      style: TextStyle(
                        color: isDark 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFE53935),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emergency_rounded,
              color: const Color(0xFFE53935),
            ),
            const SizedBox(width: 12),
            const Text('Call 911?'),
          ],
        ),
        content: const Text(
          'You are about to call emergency services (911). This should only be used for immediate life-threatening situations.\n\nIf you need to talk to someone, please use the crisis helpline instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _callNumber('911');
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call 911'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context, bool isDark) {
    final resources = CrisisResourcesProvider.countryResources[countryCode ?? 'US'] 
        ?? CrisisResourcesProvider.countryResources['US']!;
    
    return Row(
      children: [
        // Text option
        if (resources['text'] != null) ...[
          Expanded(
            child: _ActionCard(
              icon: Icons.textsms_rounded,
              title: 'Text',
              subtitle: resources['text']!,
              color: AppColors.primary,
              onTap: () => _sendText(resources['text']!),
            ),
          ),
          const SizedBox(width: 12),
        ],
        // Chat/Web option
        Expanded(
          child: _ActionCard(
            icon: Icons.language_rounded,
            title: 'Online Chat',
            subtitle: 'findahelpline.com',
            color: AppColors.primaryAlt,
            onTap: () => _openUrl(CrisisResourcesProvider.internationalUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalResources(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Resources',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _ResourceTile(
          icon: Icons.military_tech_rounded,
          title: 'Veterans Crisis Line',
          subtitle: '988 then press 1',
          onTap: () => _callNumber('988'),
        ),
        _ResourceTile(
          icon: Icons.diversity_3_rounded,
          title: 'LGBTQ+ Support (Trevor)',
          subtitle: '1-866-488-7386',
          onTap: () => _callNumber(CrisisResourcesProvider.usLGBTQ),
        ),
        _ResourceTile(
          icon: Icons.home_rounded,
          title: 'Domestic Violence',
          subtitle: '1-800-799-7233',
          onTap: () => _callNumber(CrisisResourcesProvider.usDomesticViolence),
        ),
        _ResourceTile(
          icon: Icons.public_rounded,
          title: 'International Resources',
          subtitle: 'Find help in your country',
          onTap: () => _openUrl(CrisisResourcesProvider.internationalUrl),
          showArrow: true,
        ),
      ],
    );
  }

  Widget _buildContinueOption(BuildContext context, ThemeData theme) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          onDismiss?.call();
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.chat_bubble_outline_rounded, 
            color: AppColors.textSecondaryLight),
        label: Text(
          'Continue talking with AI Buddy',
          style: TextStyle(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Future<void> _callNumber(String number) async {
    onResourceTapped?.call();
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendText(String info) async {
    onResourceTapped?.call();
    // Parse text info like "HOME to 741741"
    final parts = info.split(' to ');
    if (parts.length == 2) {
      final uri = Uri.parse('sms:${parts[1]}?body=${parts[0]}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> _openUrl(String url) async {
    onResourceTapped?.call();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Show the crisis dialog
  static Future<void> show(
    BuildContext context, {
    required CrisisSeverity severity,
    String? countryCode,
    VoidCallback? onDismiss,
    VoidCallback? onResourceTapped,
  }) {
    // Haptic feedback for urgency
    HapticFeedback.heavyImpact();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => CrisisResourcesDialog(
        severity: severity,
        countryCode: countryCode,
        onDismiss: onDismiss,
        onResourceTapped: onResourceTapped,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _ResourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark 
            ? AppColors.cardDark 
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? AppColors.textSecondaryDark 
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  showArrow 
                      ? Icons.open_in_new_rounded 
                      : Icons.phone_rounded,
                  size: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
