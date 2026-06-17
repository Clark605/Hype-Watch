import 'package:flutter/material.dart';

/// App-wide color palette with semantic naming for better maintainability.
/// Colors are organized by their usage context rather than Material naming.
class AppColors {
  // ── Base Colors ──────────────────────────────────────────────────────────────

  /// Main screen background color.
  static const Color screenBackground = Color(0xFFF7F9FB);

  /// Primary text color for titles and important content.
  static const Color textPrimary = Color(0xFF191C1E);

  /// Secondary text and icon color for supporting content.
  static const Color textSecondary = Color(0xFF5C403F);

  /// Card and container background color.
  static const Color cardBackground = Color(0xFFECEEF0);

  /// Elevated card background (slightly different shade).
  static const Color cardBackgroundElevated = Color(0xFFE0E3E5);

  /// Border and divider color for subtle separation.
  static const Color border = Color(0xFFE5BDBB);

  // ── Brand Colors ──────────────────────────────────────────────────────────────

  /// Main brand color (World Cup red).
  static const Color brandRed = Color(0xFF9E001F);

  /// Text/icon color on top of brand red.
  static const Color onBrandRed = Color(0xFFFFFFFF);

  // ── State Colors ────────────────────────────────────────────────────────────

  /// Background color for active/selected states.
  static const Color activeBackground = Color(0xFFFFDAD8);

  /// Background color for selected filter buttons.
  static const Color selectedButtonBackground = Color(0xFF85C4FD);

  /// Border color for selected filter buttons.
  static const Color selectedButtonBorder = Color(0xFFCEE5FF);

  /// Text color on selected backgrounds.
  static const Color selectedText = Color(0xFF001D32);

  /// Accent color for shadows and highlights.
  static const Color accentGreen = Color(0xFF70FF82);

  // ── Semantic Aliases (for Material compatibility) ───────────────────────────

  /// Background alias for Scaffold and general use.
  static const Color background = screenBackground;

  /// On-surface alias for primary text.
  static const Color onSurface = textPrimary;

  /// On-surface-variant alias for secondary text.
  static const Color onSurfaceVariant = textSecondary;

  /// Surface-variant alias.
  static const Color surfaceVariant = cardBackgroundElevated;

  /// Surface-container alias for cards.
  static const Color surfaceContainer = cardBackground;

  /// Surface-container-low alias.
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);

  /// Surface-container-highest alias.
  static const Color surfaceContainerHighest = cardBackgroundElevated;

  /// Outline-variant alias.
  static const Color outlineVariant = border;

  /// Outline alias.
  static const Color outline = Color(0xFF906F6E);

  /// Primary alias for brand color.
  static const Color primary = brandRed;

  /// On-primary alias.
  static const Color onPrimary = onBrandRed;

  /// Primary-fixed alias.
  static const Color primaryFixed = activeBackground;

  /// Secondary-fixed alias.
  static const Color secondaryFixed = selectedButtonBorder;

  /// On-secondary-fixed alias.
  static const Color onSecondaryFixed = selectedText;

  /// Secondary-container alias.
  static const Color secondaryContainer = selectedButtonBackground;

  /// Tertiary alias.
  static const Color tertiary = Color(0xFF005A1C);

  /// Tertiary-fixed alias.
  static const Color tertiaryFixed = accentGreen;

  /// On-tertiary-fixed alias.
  static const Color onTertiaryFixed = Color(0xFF002106);

  /// On-tertiary-fixed-variant alias.
  static const Color onTertiaryFixedVariant = Color(0xFF005319);

  /// Error color.
  static const Color error = Color(0xFFBA1A1A);

  /// Error container background.
  static const Color errorContainer = Color(0xFFFFDAD6);

  /// On-error-container text color.
  static const Color onErrorContainer = Color(0xFF93000A);
}
