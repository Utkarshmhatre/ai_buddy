import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Chat input field with send button and optional voice input
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isEnabled;
  final String? hintText;
  final VoidCallback? onVoicePressed;
  final bool showVoiceButton;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isEnabled = true,
    this.hintText,
    this.onVoicePressed,
    this.showVoiceButton = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSend(text);
      _controller.clear();
      // Keep keyboard open for continued conversation
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewPadding.bottom > 0 ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Voice button (optional)
            if (widget.showVoiceButton)
              IconButton(
                onPressed: widget.isEnabled ? widget.onVoicePressed : null,
                icon: Icon(
                  Icons.mic_outlined,
                  color: widget.isEnabled
                      ? AppColors.textSecondaryLight
                      : AppColors.textTertiaryLight,
                ),
                tooltip: 'Voice input',
              ),
            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight),
                    width: _focusNode.hasFocus ? 2 : 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.isEnabled,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? "How are you feeling today?",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _hasText && widget.isEnabled
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _hasText && widget.isEnabled ? _handleSend : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.send_rounded,
                      color: _hasText && widget.isEnabled
                          ? Colors.white
                          : (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
