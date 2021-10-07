import 'package:flutter/material.dart';

class ThemeColors {
  final Color backgroundColor;
  final Color foreground;
  final Color accent;
  final Color shadow;
  final Color focusColor;
  final Color hoverColor;
  final Color mutedBg;
  final Color splashColor;
  final Color subtext;
  final Color contrastText;

  ThemeColors({
    required this.backgroundColor,
    required this.splashColor,
    required this.foreground,
    required this.accent,
    this.shadow = Colors.black26,
    required this.focusColor,
    required this.hoverColor,
    required this.mutedBg,
    required this.subtext,
    required this.contrastText,
  });

  factory ThemeColors.fromThemeColors(ThemeColors themeColors) {
    return ThemeColors(
      backgroundColor: themeColors.backgroundColor,
      splashColor: themeColors.splashColor,
      foreground: themeColors.foreground,
      accent: themeColors.accent,
      focusColor: themeColors.focusColor,
      hoverColor: themeColors.hoverColor,
      mutedBg: themeColors.mutedBg,
      subtext: themeColors.subtext,
      contrastText: themeColors.contrastText,
    );
  }
}
