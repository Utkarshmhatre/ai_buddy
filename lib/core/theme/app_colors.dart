import 'package:flutter/material.dart';

/// App color palette following the calming design guidelines
/// for mental health support applications
class AppColors {
  AppColors._();

  // ============== PRIMARY COLORS ==============
  /// Soft Teal - Calming, trustworthy (Primary)
  static const Color primary = Color(0xFF5DADE2);
  static const Color primaryLight = Color(0xFF85C1E9);
  static const Color primaryDark = Color(0xFF3498DB);

  /// Sage Green - Growth, healing, nature (Primary Alt)
  static const Color primaryAlt = Color(0xFF82C785);
  static const Color primaryAltLight = Color(0xFFA9DFAB);
  static const Color primaryAltDark = Color(0xFF5DBF60);

  // ============== SECONDARY COLORS ==============
  /// Warm Lavender - Reflective, spiritual
  static const Color secondary = Color(0xFFB19CD9);
  static const Color secondaryLight = Color(0xFFD4C4E8);
  static const Color secondaryDark = Color(0xFF9B7FC9);

  // ============== BACKGROUND COLORS ==============
  /// Light Mode Backgrounds
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Dark Mode Backgrounds - Deep Navy for calming evening use
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF2D2D44);
  static const Color cardDark = Color(0xFF2D2D44);

  // ============== TEXT COLORS ==============
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF7F8C8D);
  static const Color textTertiaryLight = Color(0xFFBDC3C7);

  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);
  static const Color textTertiaryDark = Color(0xFF6B6B6B);

  // ============== SEMANTIC COLORS ==============
  /// Success - Soft Green for achievements, progress
  static const Color success = Color(0xFF7DCEA0);
  static const Color successLight = Color(0xFFA9DFAB);
  static const Color successDark = Color(0xFF52BE80);

  /// Warning - Warm Amber for gentle alerts
  static const Color warning = Color(0xFFF5B041);
  static const Color warningLight = Color(0xFFF8C471);
  static const Color warningDark = Color(0xFFE59829);

  /// Error - Muted coral (not harsh red to avoid anxiety triggers)
  static const Color error = Color(0xFFE57373);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFD32F2F);

  /// Accent/CTA - Coral for action, warmth (use sparingly)
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8A8A);
  static const Color accentDark = Color(0xFFE54545);

  // ============== CHAT BUBBLE COLORS ==============
  static const Color aiBubbleLight = Color(0xFFF0F4F8);
  static const Color aiBubbleDark = Color(0xFF2D2D44);

  static const Color userBubbleLight = Color(0xFF5DADE2);
  static const Color userBubbleDark = Color(0xFF3D7EA6);

  // ============== DIVIDER COLORS ==============
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF3D3D5C);

  // ============== CRISIS/URGENT COLORS ==============
  /// Used only for crisis situations - still muted to avoid panic
  static const Color crisis = Color(0xFFE57373);
  static const Color crisisBackground = Color(0xFFFFF3E0);

  // ============== EMOTION GIF OVERLAY COLORS ==============
  /// Subtle background tints for emotion states
  static const Color empathyTint = Color(0x1A5DADE2);
  static const Color encouragementTint = Color(0x1A82C785);
  static const Color calmTint = Color(0x1AB19CD9);
  static const Color celebrationTint = Color(0x1AF5B041);
  static const Color thoughtfulTint = Color(0x1A5DADE2);
  static const Color supportiveTint = Color(0x1AE57373);
}
