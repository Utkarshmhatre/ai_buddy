import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// WCAG 2.1 AA Compliance Helpers for Mental Health App
/// Ensures accessibility for users with disabilities
class AccessibilityHelpers {
  AccessibilityHelpers._();

  // ============== WCAG 2.1 AA REQUIREMENTS ==============
  // 1. Perceivable - Information must be presentable
  // 2. Operable - UI components must be operable
  // 3. Understandable - Information must be understandable
  // 4. Robust - Content must be robust enough for assistive tech

  // ============== COLOR CONTRAST (WCAG 1.4.3) ==============
  
  /// Minimum contrast ratios per WCAG 2.1 AA
  static const double normalTextMinContrast = 4.5;
  static const double largeTextMinContrast = 3.0;
  static const double uiComponentMinContrast = 3.0;

  /// Calculate relative luminance of a color
  static double getRelativeLuminance(Color color) {
    double r = color.r / 255;
    double g = color.g / 255;
    double b = color.b / 255;

    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055) * ((r + 0.055) / 1.055);
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055) * ((g + 0.055) / 1.055);
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055) * ((b + 0.055) / 1.055);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculate contrast ratio between two colors
  static double getContrastRatio(Color foreground, Color background) {
    final l1 = getRelativeLuminance(foreground);
    final l2 = getRelativeLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA for normal text
  static bool meetsContrastAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= (isLargeText ? largeTextMinContrast : normalTextMinContrast);
  }

  /// Get a contrasting color that meets WCAG AA
  static Color getAccessibleTextColor(Color background, {bool preferDark = true}) {
    const white = Colors.white;
    const black = Color(0xFF1A1A1A);
    
    final whiteContrast = getContrastRatio(white, background);
    final blackContrast = getContrastRatio(black, background);
    
    if (preferDark) {
      return blackContrast >= normalTextMinContrast ? black : white;
    }
    return whiteContrast >= normalTextMinContrast ? white : black;
  }

  // ============== TOUCH TARGETS (WCAG 2.5.5) ==============
  
  /// Minimum touch target size (44x44 dp per WCAG)
  static const double minTouchTarget = 44.0;
  
  /// Recommended touch target size for better accessibility
  static const double recommendedTouchTarget = 48.0;

  /// Wrap a widget to ensure minimum touch target size
  static Widget ensureMinTouchTarget({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minTouchTarget,
            minHeight: minTouchTarget,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  // ============== SEMANTIC LABELS (WCAG 1.1.1, 4.1.2) ==============

  /// Standard semantic labels for common UI elements
  static const Map<String, String> standardLabels = {
    'send_message': 'Send message',
    'back': 'Go back',
    'close': 'Close',
    'menu': 'Open menu',
    'settings': 'Open settings',
    'help': 'Get help',
    'crisis_help': 'Get crisis support',
    'mood_happy': 'Feeling happy',
    'mood_sad': 'Feeling sad',
    'mood_anxious': 'Feeling anxious',
    'mood_angry': 'Feeling angry',
    'mood_neutral': 'Feeling neutral',
    'new_entry': 'Create new entry',
    'delete': 'Delete',
    'edit': 'Edit',
    'save': 'Save',
    'cancel': 'Cancel',
    'retry': 'Try again',
    'loading': 'Loading, please wait',
    'error': 'An error occurred',
    'success': 'Action completed successfully',
  };

  /// Create semantic wrapper for interactive elements
  static Widget semanticButton({
    required Widget child,
    required String label,
    required VoidCallback onTap,
    String? hint,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: isEnabled,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: child,
      ),
    );
  }

  /// Create semantic wrapper for text content
  static Widget semanticText({
    required Widget child,
    required String label,
    bool isHeader = false,
    bool isLiveRegion = false,
  }) {
    return Semantics(
      label: label,
      header: isHeader,
      liveRegion: isLiveRegion,
      child: child,
    );
  }

  /// Create semantic wrapper for images
  static Widget semanticImage({
    required Widget child,
    required String description,
    bool isDecorative = false,
  }) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }
    return Semantics(
      image: true,
      label: description,
      child: child,
    );
  }

  // ============== FOCUS MANAGEMENT (WCAG 2.4.3, 2.4.7) ==============

  /// Request focus on a specific widget (for screen readers)
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
    // Announce to screen reader
    SemanticsService.announce('Focus moved', TextDirection.ltr);
  }

  /// Announce a message to screen readers
  static void announce(String message, {bool isAssertive = false}) {
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: isAssertive 
          ? Assertiveness.assertive 
          : Assertiveness.polite,
    );
  }

  // ============== MOTION & ANIMATION (WCAG 2.3.3) ==============

  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get animation duration based on user preference
  static Duration getAnimationDuration(
    BuildContext context, {
    Duration normal = const Duration(milliseconds: 300),
    Duration reduced = Duration.zero,
  }) {
    return prefersReducedMotion(context) ? reduced : normal;
  }

  // ============== TEXT SCALING (WCAG 1.4.4) ==============

  /// Get scaled text size respecting user preferences
  static double getScaledFontSize(BuildContext context, double baseSize) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(baseSize);
  }

  /// Check if text is scaled beyond readable size
  static bool isTextOverScaled(BuildContext context, {double threshold = 2.0}) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(1.0) > threshold;
  }

  // ============== ACCESSIBILITY AUDIT ==============

  /// Run accessibility audit on current theme
  static AccessibilityAuditResult auditTheme({
    required Color backgroundColor,
    required Color textColor,
    required Color primaryColor,
    required Color errorColor,
  }) {
    final issues = <String>[];
    final suggestions = <String>[];

    // Check text contrast
    final textContrast = getContrastRatio(textColor, backgroundColor);
    if (textContrast < normalTextMinContrast) {
      issues.add('Text contrast ratio ($textContrast) is below WCAG AA requirement (4.5:1)');
      suggestions.add('Consider using a darker/lighter text color');
    }

    // Check primary color contrast
    final primaryContrast = getContrastRatio(primaryColor, backgroundColor);
    if (primaryContrast < uiComponentMinContrast) {
      issues.add('Primary color contrast ratio ($primaryContrast) is below WCAG AA requirement (3:1)');
      suggestions.add('Consider adjusting the primary color saturation or lightness');
    }

    // Check error color contrast
    final errorContrast = getContrastRatio(errorColor, backgroundColor);
    if (errorContrast < uiComponentMinContrast) {
      issues.add('Error color contrast ratio ($errorContrast) is below WCAG AA requirement (3:1)');
    }

    return AccessibilityAuditResult(
      passesWCAGAA: issues.isEmpty,
      issues: issues,
      suggestions: suggestions,
      contrastRatios: {
        'text': textContrast,
        'primary': primaryContrast,
        'error': errorContrast,
      },
    );
  }
}

/// Result of accessibility audit
class AccessibilityAuditResult {
  final bool passesWCAGAA;
  final List<String> issues;
  final List<String> suggestions;
  final Map<String, double> contrastRatios;

  const AccessibilityAuditResult({
    required this.passesWCAGAA,
    required this.issues,
    required this.suggestions,
    required this.contrastRatios,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Accessibility Audit Results ===');
    buffer.writeln('WCAG AA Compliant: ${passesWCAGAA ? "✓ Yes" : "✗ No"}');
    buffer.writeln('\nContrast Ratios:');
    for (final entry in contrastRatios.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value.toStringAsFixed(2)}:1');
    }
    if (issues.isNotEmpty) {
      buffer.writeln('\nIssues:');
      for (final issue in issues) {
        buffer.writeln('  • $issue');
      }
    }
    if (suggestions.isNotEmpty) {
      buffer.writeln('\nSuggestions:');
      for (final suggestion in suggestions) {
        buffer.writeln('  • $suggestion');
      }
    }
    return buffer.toString();
  }
}

/// Accessible text styles that scale properly
class AccessibleTextStyles {
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      height: 1.3, // Adequate line height for readability
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      height: 1.3,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      height: 1.5, // Comfortable reading height
      letterSpacing: 0.5, // Slight spacing for readability
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.5,
      letterSpacing: 0.25,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      height: 1.4,
      letterSpacing: 0.5,
    );
  }
}

/// Widget that adds accessibility features automatically
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isButton;
  final bool isHeader;
  final bool excludeSemantics;
  final VoidCallback? onTap;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.isButton = false,
    this.isHeader = false,
    this.excludeSemantics = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    Widget result = child;

    // Wrap with tap handler if needed
    if (onTap != null) {
      result = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    // Add semantics
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: isButton,
      header: isHeader,
      child: result,
    );
  }
}
