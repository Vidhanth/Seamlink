import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:seamlink/models/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static bool isDark = false;

  static Function enterWipe = () {};
  static Function exitWipe = () {};

  static ThemeColors lightTheme = ThemeColors(
    backgroundColor: Color(0xFFF0F0F0),
    foreground: Colors.black.withOpacity(0.9),
    accent: Colors.black,
    focusColor: Colors.black.withOpacity(0.05),
    hoverColor: Colors.black.withOpacity(0.05),
    splashColor: Colors.black12,
    mutedBg: Color(0xFFDFDFDF),
    subtext: Colors.grey.shade700,
    contrastText: Colors.white.withOpacity(0.9),
  );

  static ThemeColors darkTheme = ThemeColors(
    backgroundColor: Color(0xFF222222),
    foreground: Colors.white.withOpacity(0.9),
    accent: Colors.white,
    focusColor: Colors.white.withOpacity(0.05),
    hoverColor: Colors.white.withOpacity(0.05),
    splashColor: Colors.white12,
    mutedBg: Color(0xFF353535),
    subtext: Colors.white60,
    contrastText: Colors.black.withOpacity(0.9),
  );

  ThemeColors currentTheme =
      ThemeColors.fromThemeColors(isDark ? darkTheme : lightTheme);

  Future<void> switchTheme() async {
    await enterWipe.call();
    isDark = !isDark;
    currentTheme = ThemeColors.fromThemeColors(
      isDark ? darkTheme : lightTheme,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
    refresh();
    await exitWipe.call();
  }
}
