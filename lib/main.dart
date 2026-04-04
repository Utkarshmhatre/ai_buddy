import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/ai/enhanced_gemini_service.dart';
import 'core/ai/gemini_service.dart';
import 'core/router/app_router.dart';
import 'core/security/database_service.dart';
import 'core/security/encryption_service.dart';
import 'core/services/api_key_service.dart';
import 'core/services/app_lock_service.dart';
import 'core/services/emotion_state_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/widgets/session_lock_screen.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/journal_repository.dart';
import 'data/repositories/mood_repository.dart';
import 'features/analytics/bloc/analytics_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/bloc/chat_event.dart';
import 'features/exercises/bloc/exercise_bloc.dart';
import 'features/insights/bloc/insights_bloc.dart';
import 'features/journal/bloc/journal_bloc.dart';
import 'features/mood/bloc/mood_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize theme notifier
  await ThemeNotifier.instance.initialize();

  runApp(const AIBuddyApp());
}

class AIBuddyApp extends StatefulWidget {
  const AIBuddyApp({super.key});

  @override
  State<AIBuddyApp> createState() => _AIBuddyAppState();
}

class _AIBuddyAppState extends State<AIBuddyApp> with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _showOnboarding = false;
  bool _isLocked = false;
  String? _apiKey;
  late DatabaseService _databaseService;
  final ApiKeyService _apiKeyService = ApiKeyService();
  final AppLockService _appLockService = AppLockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to theme changes
    ThemeNotifier.instance.addListener(_onThemeChanged);
    // Listen to app lock changes
    _appLockService.addListener(_onAppLockChanged);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemeNotifier.instance.removeListener(_onThemeChanged);
    _appLockService.removeListener(_onAppLockChanged);
    super.dispose();
  }

  void _onAppLockChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      EmotionStateService.instance.checkAndResetIfStale();
    }

    // Lock app when it goes to background (if app lock is enabled)
    if (state == AppLifecycleState.paused &&
        _appLockService.appLockEnabled &&
        _isInitialized) {
      setState(() => _isLocked = true);
    }
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeApp() async {
    // Initialize encryption and database
    final encryptionService = EncryptionService();
    await encryptionService.initialize();

    _databaseService = await DatabaseService.getInstance(
      encryptionService: encryptionService,
    );

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    _showOnboarding = !(prefs.getBool('onboarding_completed') ?? false);

    // Get API key from secure storage or environment
    _apiKey = await _apiKeyService.getApiKey();

    // Initialize app lock service
    await _appLockService.initialize();
    _isLocked =
        _appLockService.appLockEnabled; // Start locked if app lock is enabled

    // Debug: Print to console
    debugPrint('=== AI BUDDY DEBUG ===');
    debugPrint(
      'API Key loaded: \${_apiKey?.isNotEmpty == true ? "Yes (\${_apiKey!.length} chars)" : "NO - EMPTY!"}',
    );
    if (_apiKey?.isNotEmpty == true) {
      debugPrint(
        'API Key prefix: \${_apiKey!.substring(0, _apiKey!.length > 10 ? 10 : _apiKey!.length)}...',
      );
    }
    debugPrint('App Lock enabled: ${_appLockService.appLockEnabled}');
    debugPrint('======================');

    setState(() {
      _isInitialized = true;
    });
  }

  /// Called when API key is saved from the setup screen
  void _onApiKeySaved(String apiKey) {
    setState(() {
      _apiKey = apiKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (!_isInitialized) {
      return MaterialApp(
        title: 'AI Buddy',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }

    // Show lock screen if app is locked
    if (_isLocked && _appLockService.appLockEnabled) {
      return MaterialApp(
        title: 'AI Buddy',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeNotifier.instance.themeMode,
        home: SessionLockScreen(
          appName: 'AI Buddy',
          onUnlocked: () {
            setState(() => _isLocked = false);
          },
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    // Check if API key is configured
    if (_apiKey == null || _apiKey!.isEmpty) {
      return MaterialApp(
        title: 'AI Buddy',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeNotifier.instance.themeMode,
        home: ApiKeySetupScreen(onApiKeySaved: _onApiKeySaved),
        debugShowCheckedModeBanner: false,
      );
    }

    // Create repositories
    final chatRepository = ChatRepository();
    final moodRepository = MoodRepository(_databaseService);
    final journalRepository = JournalRepository(_databaseService);
    final geminiService = GeminiService(apiKey: _apiKey!);
    final enhancedGeminiService = EnhancedGeminiService(apiKey: _apiKey!);

    // Create router (set showOnboarding based on SharedPreferences)
    final router = AppRouter.router(showOnboarding: _showOnboarding);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GeminiService>.value(value: geminiService),
        RepositoryProvider<EnhancedGeminiService>.value(
          value: enhancedGeminiService,
        ),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
        RepositoryProvider<MoodRepository>.value(value: moodRepository),
        RepositoryProvider<JournalRepository>.value(value: journalRepository),
        RepositoryProvider<ApiKeyService>.value(value: _apiKeyService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              geminiService: geminiService,
              enhancedService: enhancedGeminiService,
              chatRepository: chatRepository,
            )..add(const LoadConversation()),
          ),
          BlocProvider<MoodBloc>(
            create: (context) => MoodBloc(
              moodRepository: moodRepository,
              geminiService: geminiService,
            ),
          ),
          BlocProvider<JournalBloc>(
            create: (context) => JournalBloc(
              journalRepository: journalRepository,
              aiService: enhancedGeminiService,
            ),
          ),
          BlocProvider<InsightsBloc>(
            create: (context) => InsightsBloc(
              moodRepository: moodRepository,
              aiService: enhancedGeminiService,
            ),
          ),
          BlocProvider<ExerciseBloc>(
            create: (context) => ExerciseBloc(aiService: enhancedGeminiService),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              moodRepository: moodRepository,
              aiService: enhancedGeminiService,
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'AI Buddy',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeNotifier.instance.themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
        ),
      ),
    );
  }
}

/// Screen for setting up the Gemini API key
class ApiKeySetupScreen extends StatefulWidget {
  final Function(String) onApiKeySaved;

  const ApiKeySetupScreen({super.key, required this.onApiKeySaved});

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _apiKeyService = ApiKeyService();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiKey = _apiKeyController.text.trim();

    // Save the API key
    final success = await _apiKeyService.saveApiKey(apiKey);

    if (success) {
      widget.onApiKeySaved(apiKey);
    } else {
      setState(() {
        _errorMessage = 'Failed to save API key. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // App icon and title
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Welcome to AI Buddy',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Your private AI companion for mental wellness',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // API Key Setup Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.key_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Setup API Key',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'AI Buddy uses Google Gemini AI to provide supportive conversations. '
                          'You\'ll need a free API key to get started.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // API Key Input
                        TextFormField(
                          controller: _apiKeyController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Gemini API Key',
                            hintText: 'Enter your API key',
                            prefixIcon: const Icon(Icons.vpn_key_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your API key';
                            }
                            if (!_apiKeyService.isValidApiKeyFormat(
                              value.trim(),
                            )) {
                              return 'API key appears to be invalid';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Get API Key Help Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline_rounded,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'How to get a free API key',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildStep(theme, '1', 'Go to Google AI Studio'),
                        _buildStep(
                          theme,
                          '2',
                          'Sign in with your Google account',
                        ),
                        _buildStep(
                          theme,
                          '3',
                          'Click "Get API Key" or "Create API Key"',
                        ),
                        _buildStep(theme, '4', 'Copy your new API key'),
                        _buildStep(theme, '5', 'Paste it in the field above'),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(
                              'https://aistudio.google.com/app/apikey',
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open browser. Visit: aistudio.google.com/app/apikey',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Google AI Studio'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                FilledButton.icon(
                  onPressed: _isLoading ? null : _saveApiKey,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isLoading ? 'Saving...' : 'Get Started'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your API key is stored securely on your device and never shared.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData theme, String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
