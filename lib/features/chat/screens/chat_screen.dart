import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/pinned_aura_indicator.dart';
import '../widgets/typing_indicator.dart';

/// Main chat screen with AI companion
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load or start new conversation
    context.read<ChatBloc>().add(const LoadConversation());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCrisisDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: AppColors.crisis),
            const SizedBox(width: 8),
            const Text('You\'re Not Alone'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'It sounds like you might be going through a really difficult time. Please know that help is available.',
            ),
            const SizedBox(height: 16),
            _buildCrisisButton(
              context,
              icon: Icons.phone,
              label: 'Call 988 (Suicide & Crisis Lifeline)',
              onTap: () => _launchPhone('988'),
            ),
            const SizedBox(height: 8),
            _buildCrisisButton(
              context,
              icon: Icons.message,
              label: 'Text HOME to 741741',
              onTap: () => _launchSms('741741', 'HOME'),
            ),
            const SizedBox(height: 8),
            _buildCrisisButton(
              context,
              icon: Icons.language,
              label: 'Find International Help',
              onTap: () => _launchUrl(AppConstants.internationalResourcesUrl),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChatBloc>().add(const DismissCrisisAlert());
            },
            child: const Text('I understand'),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.crisisBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.crisis, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.crisis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.crisis, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSms(String number, String body) async {
    final uri = Uri.parse('sms:$number?body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.showCrisisAlert != current.showCrisisAlert ||
          previous.messages.length != current.messages.length,
      listener: (context, state) {
        // Show crisis dialog when needed
        if (state.showCrisisAlert) {
          _showCrisisDialog(context);
        }
        // Scroll to bottom on new messages
        if (state.messages.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text('AI Buddy'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_comment_outlined),
                onPressed: () {
                  context.read<ChatBloc>().add(const StartNewConversation());
                },
                tooltip: 'New conversation',
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Show options menu
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Animated background GIF
              Positioned.fill(
                child: Opacity(
                  opacity: isDark ? 0.15 : 0.25,
                  child: Image.asset(
                    'assets/gifs/Bg.gif',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              ),
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    const PinnedAuraIndicator(),
                    // Chat messages
                    Expanded(
                      child: state.isEmpty
                          ? _buildWelcomeView(context)
                          : _buildMessageList(context, state),
                    ),
                    // Error banner
                    if (state.hasError)
                      _buildErrorBanner(
                        context,
                        state.error ?? 'Something went wrong',
                      ),
                    // Input field
                    ChatInput(
                      onSend: (message) {
                        context.read<ChatBloc>().add(SendMessage(message));
                      },
                      isEnabled: !state.isSending,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text('Hi there! 👋', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              "I'm here to listen and support you. Share what's on your mind - there's no judgment here.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Conversation starters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildStarterChip(context, "How are you feeling today?"),
                _buildStarterChip(context, "I need someone to talk to"),
                _buildStarterChip(context, "I'm feeling anxious"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarterChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ActionChip(
      label: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isDark
          ? AppColors.primary.withOpacity(0.2)
          : AppColors.primaryLight.withOpacity(0.4),
      side: BorderSide(color: AppColors.primary, width: 1.5),
      onPressed: () {
        context.read<ChatBloc>().add(SendMessage(text));
      },
    );
  }

  Widget _buildMessageList(BuildContext context, ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.messages.length + (state.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator at the end when sending
        if (state.isSending && index == state.messages.length) {
          return const TypingIndicator();
        }

        final message = state.messages[index];

        // Skip loading placeholder messages (we use TypingIndicator instead)
        if (message.isLoading) {
          return const SizedBox.shrink();
        }

        return ChatBubble(
          message: message,
          onSuggestedActionTap: (action) {
            // Send the suggested action as a new message
            context.read<ChatBloc>().add(SendMessage(action));
          },
        );
      },
    );
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.error.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(const RetryLastMessage());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
