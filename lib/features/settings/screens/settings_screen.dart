import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/demo/demo_data_service.dart';
import '../../../core/services/api_key_service.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/services/data_export_service.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/mood_repository.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/bloc/chat_event.dart';
import 'feedback_screen.dart';
import 'professional_review_screen.dart';

/// Settings screen with working functionality
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedTheme = 'system';
  bool _appLockEnabled = false;
  bool _biometricEnabled = false;
  final AppLockService _appLockService = AppLockService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final appLockEnabled = await _appLockService.isAppLockEnabled();
    final biometricEnabled = await _appLockService.isBiometricEnabled();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedTheme = prefs.getString('theme_mode') ?? 'system';
      _appLockEnabled = appLockEnabled;
      _biometricEnabled = biometricEnabled;
    });
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', theme);
    // Update the ThemeNotifier to apply theme change immediately
    ThemeNotifier.instance.setThemeMode(theme);
    setState(() {
      _selectedTheme = theme;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to ${theme.capitalize()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _showDeleteDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your conversations, mood entries, and app data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteAllData();
    }
  }

  Future<void> _deleteAllData() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Clear chat history
      final chatRepository = context.read<ChatRepository>();
      await chatRepository.clearAllMessages();

      // Clear mood data
      final moodRepository = context.read<MoodRepository>();
      await moodRepository.clearAllMoodEntries();

      // Clear SharedPreferences (except onboarding flag)
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;
      await prefs.clear();
      if (onboardingCompleted) {
        await prefs.setBool('onboarding_completed', true);
      }

      // Reload chat state
      if (mounted) {
        context.read<ChatBloc>().add(const LoadConversation());
      }

      // Dismiss loading
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showThemeDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System Default'),
              subtitle: const Text('Follow device settings'),
              value: 'system',
              groupValue: _selectedTheme,
              onChanged: (value) {
                Navigator.of(context).pop();
                _saveTheme(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                Navigator.of(context).pop();
                _saveTheme(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                Navigator.of(context).pop();
                _saveTheme(value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPersonalInfoDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final currentName = prefs.getString('user_name') ?? '';
    final controller = TextEditingController(text: currentName);

    if (!mounted) return;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Info'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name (optional)',
            hintText: 'How should AI Buddy address you?',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && mounted) {
      await prefs.setString('user_name', newName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newName.isEmpty ? 'Name cleared' : 'Name saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showNotificationsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Daily check-in reminders'),
              value: _notificationsEnabled,
              onChanged: (value) {
                _toggleNotifications(value);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Notification scheduling requires additional setup '
              'and may not work on all devices.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppLockDialog() async {
    // Check biometric availability
    final isBiometricSupported = await _appLockService.isBiometricSupported();
    final availableBiometrics = await _appLockService.getAvailableBiometrics();
    
    String biometricTypeLabel = 'Biometrics';
    if (availableBiometrics.isNotEmpty) {
      biometricTypeLabel = availableBiometrics
          .map((t) => _appLockService.getBiometricTypeName(t))
          .join(', ');
    }
    
    if (!mounted) return;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('App Lock'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Lock toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable App Lock'),
                  subtitle: const Text('Require authentication to open app'),
                  value: _appLockEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // Verify biometrics first when enabling
                      final result = await _appLockService.authenticate(
                        reason: 'Verify your identity to enable app lock',
                      );
                      if (result.success) {
                        await _appLockService.setAppLockEnabled(true);
                        setState(() => _appLockEnabled = true);
                        setDialogState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('App lock enabled'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else if (result.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.error!),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      await _appLockService.setAppLockEnabled(false);
                      setState(() {
                        _appLockEnabled = false;
                        _biometricEnabled = false;
                      });
                      setDialogState(() {});
                    }
                  },
                ),
                
                if (_appLockEnabled) ...[
                  const Divider(),
                  
                  // Biometric toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Use $biometricTypeLabel'),
                    subtitle: Text(
                      isBiometricSupported
                          ? 'Quick unlock with biometrics'
                          : 'Not available on this device',
                    ),
                    value: _biometricEnabled && isBiometricSupported,
                    onChanged: isBiometricSupported
                        ? (value) async {
                            if (value) {
                              final result = await _appLockService.authenticate(
                                reason: 'Verify your identity to enable biometric unlock',
                              );
                              if (result.success) {
                                await _appLockService.setBiometricEnabled(true);
                                setState(() => _biometricEnabled = true);
                                setDialogState(() {});
                              } else if (result.error != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.error!),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              await _appLockService.setBiometricEnabled(false);
                              setState(() => _biometricEnabled = false);
                              setDialogState(() {});
                            }
                          }
                        : null,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _appLockEnabled
                              ? 'Your app will be locked when you leave or after inactivity.'
                              : 'Enable app lock to protect your private data.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (!isBiometricSupported) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Biometric authentication is not available. Please set up fingerprint or face unlock in your device settings.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportDialog() async {
    bool includeJournal = true;
    bool includeMood = true;
    bool includeChat = true;
    bool isExporting = false;
    ExportResult? exportResult;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Export Data'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exportResult == null && !isExporting) ...[
                  Text(
                    'Select what data to export:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Journal Entries'),
                    subtitle: const Text('Your journal entries and AI insights'),
                    value: includeJournal,
                    onChanged: (v) => setDialogState(() => includeJournal = v ?? true),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mood History'),
                    subtitle: const Text('Mood check-ins and patterns'),
                    value: includeMood,
                    onChanged: (v) => setDialogState(() => includeMood = v ?? true),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Chat History'),
                    subtitle: const Text('Conversations with AI Buddy'),
                    value: includeChat,
                    onChanged: (v) => setDialogState(() => includeChat = v ?? true),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your data will be exported as a JSON file that you can save or share.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isExporting) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Exporting your data...'),
                  ),
                  const SizedBox(height: 20),
                ] else if (exportResult != null) ...[
                  if (exportResult!.success) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Export Successful!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${exportResult!.recordCount ?? 0} records exported',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'File size: ${exportResult!.fileSizeFormatted}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final exportService = DataExportService(
                            journalRepository: _tryGetRepository<JournalRepository>(),
                            moodRepository: _tryGetRepository<MoodRepository>(),
                            chatRepository: _tryGetRepository<ChatRepository>(),
                          );
                          await exportService.shareExportedData(exportResult!.filePath!);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share Export'),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Export Failed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exportResult!.error ?? 'Unknown error',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            if (!isExporting) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(exportResult != null ? 'Close' : 'Cancel'),
              ),
              if (exportResult == null)
                FilledButton(
                  onPressed: (!includeJournal && !includeMood && !includeChat)
                      ? null
                      : () async {
                          setDialogState(() => isExporting = true);
                          
                          final exportService = DataExportService(
                            journalRepository: _tryGetRepository<JournalRepository>(),
                            moodRepository: _tryGetRepository<MoodRepository>(),
                            chatRepository: _tryGetRepository<ChatRepository>(),
                          );
                          
                          final result = await exportService.exportAllData(
                            includeJournal: includeJournal,
                            includeMood: includeMood,
                            includeChat: includeChat,
                          );
                          
                          setDialogState(() {
                            isExporting = false;
                            exportResult = result;
                          });
                        },
                  child: const Text('Export'),
                ),
            ],
          ],
        ),
      ),
    );
  }
  
  T? _tryGetRepository<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _showApiKeyDialog() async {
    final apiKeyService = ApiKeyService();
    final hasKey = await apiKeyService.hasApiKey();
    final controller = TextEditingController();
    bool obscureText = true;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.key_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('API Key'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasKey) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('API key is configured')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter a new API key to replace the existing one, or leave blank to keep it.',
                    style: TextStyle(fontSize: 13),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('No API key configured')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter your Gemini API key to enable AI features.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key',
                    hintText: 'Enter API key',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get a free API key:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visit makersuite.google.com/app/apikey',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (hasKey)
              TextButton(
                onPressed: () async {
                  // Confirm deletion
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove API Key?'),
                      content: const Text(
                        'This will remove your API key. AI features will stop working until you add a new key.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await apiKeyService.deleteApiKey();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'API key removed. Restart the app to apply changes.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Remove Key',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newKey = controller.text.trim();
                if (newKey.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                if (!apiKeyService.isValidApiKeyFormat(newKey)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key appears to be invalid'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final success = await apiKeyService.saveApiKey(newKey);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'API key saved. Restart the app to apply changes.'
                            : 'Failed to save API key',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
  }

  Future<void> _showAboutDialog() async {
    showAboutDialog(
      context: context,
      applicationName: 'AI Buddy',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.psychology_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'AI Buddy is a privacy-first mental wellness companion that uses '
          'AI to provide supportive conversations while keeping your data secure.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Built with Flutter and Google Gemini AI.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    // For now, show a dialog with privacy info
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• All conversations are stored locally on your device\n'
                '• Data is encrypted using AES-256 encryption\n'
                '• No personal data is shared with third parties\n'
                '• Conversations are processed by Google Gemini AI\n'
                '• You can delete all data at any time\n'
                '• No account or sign-up required',
              ),
              SizedBox(height: 16),
              Text(
                'AI Processing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your messages are sent to Google Gemini for AI responses. '
                'Google may process this data according to their privacy policy.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchTermsOfService() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Important Disclaimer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'AI Buddy is NOT a replacement for professional mental health care. '
                'The AI provides general supportive responses but is not a licensed therapist.',
              ),
              SizedBox(height: 16),
              Text(
                'In Case of Emergency',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Call 911 for immediate emergencies\n'
                '• Call 988 for the Suicide & Crisis Lifeline\n'
                '• Text HOME to 741741 for Crisis Text Line',
              ),
              SizedBox(height: 16),
              Text(
                'Usage Agreement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'By using this app, you acknowledge that AI responses are '
                'informational only and should not be considered medical advice.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDemoModeDialog() async {
    final isDemoEnabled = await DemoDataService.isDemoModeEnabled();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.science_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Demo Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDemoEnabled
                  ? 'Demo mode is currently ENABLED. Sample data has been loaded for presentation.'
                  : 'Demo mode loads sample data including:\n\n'
                        '• 14 days of mood entries\n'
                        '• 6 journal entries with various themes\n'
                        '• Sample chat conversation\n\n'
                        'This is useful for demos and presentations.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDemoEnabled
                          ? 'Clearing demo data will remove all sample entries.'
                          : 'Enabling demo mode may add data to your existing entries.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (isDemoEnabled) {
                await _clearDemoData();
              } else {
                await _enableDemoMode();
              }
            },
            child: Text(isDemoEnabled ? 'Clear Demo Data' : 'Enable Demo Mode'),
          ),
        ],
      ),
    );
  }

  Future<void> _enableDemoMode() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatRepository = context.read<ChatRepository>();
      final moodRepository = context.read<MoodRepository>();
      JournalRepository? journalRepository;
      try {
        journalRepository = context.read<JournalRepository>();
      } catch (_) {
        // JournalRepository might not be provided
      }

      final demoService = DemoDataService(
        chatRepository: chatRepository,
        moodRepository: moodRepository,
        journalRepository: journalRepository,
      );

      await demoService.enableDemoMode();

      // Refresh chat
      if (mounted) {
        context.read<ChatBloc>().add(const LoadConversation());
      }

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demo mode enabled! Sample data loaded.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading demo data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearDemoData() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatRepository = context.read<ChatRepository>();
      final moodRepository = context.read<MoodRepository>();
      JournalRepository? journalRepository;
      try {
        journalRepository = context.read<JournalRepository>();
      } catch (_) {}

      final demoService = DemoDataService(
        chatRepository: chatRepository,
        moodRepository: moodRepository,
        journalRepository: journalRepository,
      );

      await demoService.clearDemoData();

      // Refresh chat
      if (mounted) {
        context.read<ChatBloc>().add(const LoadConversation());
      }

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demo data cleared.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing demo data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Profile section
          _SettingsSection(
            title: 'Profile',
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal Info',
                subtitle: 'Name, preferences',
                onTap: _showPersonalInfoDialog,
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                onTap: _showNotificationsDialog,
              ),
            ],
          ),

          // Appearance section
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: _selectedTheme.capitalize(),
                onTap: _showThemeDialog,
              ),
            ],
          ),

          // Privacy section
          _SettingsSection(
            title: 'Privacy & Security',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'App Lock',
                subtitle: _appLockEnabled 
                    ? (_biometricEnabled ? 'Biometrics enabled' : 'Enabled')
                    : 'Disabled',
                onTap: _showAppLockDialog,
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                subtitle: 'Download your data',
                onTap: _showExportDialog,
              ),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete All Data',
                subtitle: 'Clear conversations and mood data',
                onTap: _showDeleteDataDialog,
                isDestructive: true,
              ),
            ],
          ),

          // API Configuration section
          _SettingsSection(
            title: 'AI Configuration',
            children: [
              _SettingsTile(
                icon: Icons.key_rounded,
                title: 'Gemini API Key',
                subtitle: 'Manage your API key',
                onTap: _showApiKeyDialog,
              ),
            ],
          ),

          // About section
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About AI Buddy',
                subtitle: 'Version 1.0.0-beta',
                onTap: _showAboutDialog,
              ),
              _SettingsTile(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                onTap: _launchPrivacyPolicy,
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: _launchTermsOfService,
              ),
            ],
          ),

          // Beta Testing section
          _SettingsSection(
            title: 'Beta Testing',
            children: [
              _SettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve AI Buddy',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                subtitle: 'Let us know about issues',
                onTap: () => showBugReportDialog(context),
              ),
              _SettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Professional Review',
                subtitle: 'For mental health professionals',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfessionalReviewScreen(),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.science_outlined,
                title: 'Demo Mode',
                subtitle: 'Load sample data for presentation',
                onTap: _showDemoModeDialog,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notice',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Buddy is not a substitute for professional mental health treatment. '
                    'If you are in crisis, please contact emergency services (911) or '
                    'the 988 Suicide & Crisis Lifeline.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
