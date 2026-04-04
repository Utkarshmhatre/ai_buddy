import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for WCAG 2.2 AA compliance
/// Provides helpers for semantic labels, focus management, and screen reader support
class AccessibilityHelper {
  AccessibilityHelper._();

  /// Standard minimum touch target size (48x48 dp)
  static const double minTouchTargetSize = 48.0;

  /// Minimum color contrast ratio for normal text (AA standard)
  static const double contrastRatioAA = 4.5;

  /// Minimum color contrast ratio for large text (AA standard)
  static const double contrastRatioAALarge = 3.0;

  /// Announce a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Request focus on a specific widget
  static void requestFocus(FocusNode node) {
    node.requestFocus();
  }

  /// Move focus to next element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Check if reduced motion is preferred
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get animation duration based on reduced motion preference
  static Duration getAnimationDuration(
    BuildContext context, {
    Duration normal = const Duration(milliseconds: 300),
    Duration reduced = Duration.zero,
  }) {
    return prefersReducedMotion(context) ? reduced : normal;
  }

  /// Check if bold text is preferred
  static bool prefersBoldText(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Check if high contrast is preferred
  static bool prefersHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Generate semantic label for mood score
  static String moodScoreLabel(int score) {
    String level;
    if (score >= 8) {
      level = 'very positive';
    } else if (score >= 6) {
      level = 'positive';
    } else if (score >= 4) {
      level = 'neutral';
    } else if (score >= 2) {
      level = 'low';
    } else {
      level = 'very low';
    }
    return 'Mood score $score out of 10, $level mood';
  }

  /// Generate semantic label for streak
  static String streakLabel(int days) {
    if (days == 0) {
      return 'No current streak';
    } else if (days == 1) {
      return '1 day streak';
    } else {
      return '$days day streak';
    }
  }

  /// Generate semantic label for exercise
  static String exerciseLabel(String name, int durationMinutes) {
    return '$name exercise, approximately $durationMinutes minutes';
  }

  /// Generate semantic label for progress
  static String progressLabel(double progress, String context) {
    final percentage = (progress * 100).round();
    return '$context progress: $percentage percent complete';
  }
}

/// Accessible button that ensures minimum touch target size
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? semanticHint;
  final bool excludeFromSemantics;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      hint: semanticHint,
      excludeSemantics: excludeFromSemantics,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AccessibilityHelper.minTouchTargetSize,
              minHeight: AccessibilityHelper.minTouchTargetSize,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Accessible icon button with proper semantic label
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color? color;
  final double size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.semanticLabel,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: AccessibilityHelper.minTouchTargetSize,
          minHeight: AccessibilityHelper.minTouchTargetSize,
        ),
      ),
    );
  }
}

/// Container with focus trap for modal dialogs
class AccessibleModal extends StatefulWidget {
  final Widget child;
  final String title;
  final String? description;

  const AccessibleModal({
    super.key,
    required this.child,
    required this.title,
    this.description,
  });

  @override
  State<AccessibleModal> createState() => _AccessibleModalState();
}

class _AccessibleModalState extends State<AccessibleModal> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      autofocus: true,
      child: Semantics(
        namesRoute: true,
        scopesRoute: true,
        label: widget.title,
        hint: widget.description,
        child: widget.child,
      ),
    );
  }
}

/// Accessible loading indicator with announcement
class AccessibleLoadingIndicator extends StatefulWidget {
  final String? message;

  const AccessibleLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  State<AccessibleLoadingIndicator> createState() => _AccessibleLoadingIndicatorState();
}

class _AccessibleLoadingIndicatorState extends State<AccessibleLoadingIndicator> {
  @override
  void initState() {
    super.initState();
    // Announce loading state to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityHelper.announce(
        context, 
        widget.message ?? 'Loading, please wait',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.message ?? 'Loading',
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Semantic wrapper for live regions (content that updates)
class AccessibleLiveRegion extends StatelessWidget {
  final Widget child;
  final String label;
  final bool liveRegionPolite;

  const AccessibleLiveRegion({
    super.key,
    required this.child,
    required this.label,
    this.liveRegionPolite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}

/// Skip link for keyboard navigation
class AccessibleSkipLink extends StatelessWidget {
  final FocusNode targetFocus;
  final String label;

  const AccessibleSkipLink({
    super.key,
    required this.targetFocus,
    this.label = 'Skip to main content',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            if (!hasFocus) return const SizedBox.shrink();
            
            return Positioned(
              top: 0,
              left: 0,
              child: Material(
                child: InkWell(
                  onTap: () => targetFocus.requestFocus(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(label),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Extension to add accessibility features to TextStyle
extension AccessibleTextStyle on TextStyle {
  /// Ensure minimum font size for readability
  TextStyle ensureMinimumSize(double minSize) {
    if ((fontSize ?? 14) < minSize) {
      return copyWith(fontSize: minSize);
    }
    return this;
  }

  /// Apply bold text preference
  TextStyle withBoldPreference(BuildContext context) {
    if (AccessibilityHelper.prefersBoldText(context)) {
      return copyWith(fontWeight: FontWeight.bold);
    }
    return this;
  }
}

/// Heading widget with proper semantic heading level
class AccessibleHeading extends StatelessWidget {
  final String text;
  final int level;
  final TextStyle? style;

  const AccessibleHeading({
    super.key,
    required this.text,
    this.level = 1,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: style ?? _getDefaultStyle(context),
      ),
    );
  }

  TextStyle _getDefaultStyle(BuildContext context) {
    final theme = Theme.of(context);
    switch (level) {
      case 1:
        return theme.textTheme.headlineLarge!;
      case 2:
        return theme.textTheme.headlineMedium!;
      case 3:
        return theme.textTheme.headlineSmall!;
      case 4:
        return theme.textTheme.titleLarge!;
      case 5:
        return theme.textTheme.titleMedium!;
      default:
        return theme.textTheme.titleSmall!;
    }
  }
}

/// Accessible form field with error announcements
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: labelText,
      hint: hintText,
      value: controller?.text,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (value) {
          // Announce error if present
          if (errorText != null) {
            AccessibilityHelper.announce(context, 'Error: $errorText');
          }
          onChanged?.call(value);
        },
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
        ),
      ),
    );
  }
}

/// Image with required alt text
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String altText;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isDecorative;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.altText,
    this.width,
    this.height,
    this.fit,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: isDecorative ? '' : altText,
      excludeSemantics: isDecorative,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: isDecorative ? null : altText,
      ),
    );
  }
}
