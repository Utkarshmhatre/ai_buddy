import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system following accessibility guidelines
/// - Minimum 16px body text
/// - 1.5 line height for readability
/// - Maximum 65-75 characters per line
class AppTypography {
  AppTypography._();

  // Font family - using system default for performance
  // Can be replaced with Inter or Nunito for friendlier feel
  static const String fontFamily = 'Roboto';

  /// Light theme text styles
  static TextTheme get lightTextTheme => TextTheme(
        // Display styles (large headers)
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.2,
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.25,
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryLight,
        ),

        // Headline styles
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),

        // Title styles
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.textPrimaryLight,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.textPrimaryLight,
        ),

        // Body styles - minimum 16px for accessibility
        bodyLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textSecondaryLight,
        ),

        // Label styles
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textSecondaryLight,
        ),
      );

  /// Dark theme text styles
  static TextTheme get darkTextTheme => TextTheme(
        // Display styles
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.2,
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.25,
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryDark,
        ),

        // Headline styles
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryDark,
        ),

        // Title styles
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.textPrimaryDark,
        ),

        // Body styles
        bodyLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textSecondaryDark,
        ),

        // Label styles
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryDark,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textSecondaryDark,
        ),
      );
}
