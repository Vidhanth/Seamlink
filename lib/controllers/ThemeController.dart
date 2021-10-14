import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:seamlink/models/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Mode {
  LIGHT,
  DARK,
  SYSTEM,
}

class ThemeController extends GetxController {
  static bool isDark = false;
  static Mode mode = Mode.LIGHT;
  static bool get isAuto => mode == Mode.SYSTEM;
  static Function enterWipe = () {};
  static Function exitWipe = () {};

  static ThemeColors lightTheme = ThemeColors(
    backgroundColor: Color(0xFFE9E9E9),
    foreground: Colors.black.withOpacity(0.9),
    accent: Colors.black,
    focusColor: Colors.black.withOpacity(0.05),
    hoverColor: Colors.black.withOpacity(0.05),
    splashColor: Colors.black12,
    mutedBg: Color(0xFFD3D3D3),
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

  ThemeColors currentTheme = ThemeColors.fromThemeColors(isAuto
      ? _getAutoTheme()
      : isDark
          ? darkTheme
          : lightTheme);

  Future<void> switchTheme() async {
    if (mode == Mode.LIGHT) {
      await setDark();
      mode = Mode.DARK;
    } else if (mode == Mode.DARK) {
      if (WidgetsBinding.instance?.window.platformBrightness ==
          Brightness.dark) {
        if (!isDark) await setDark();
      } else {
        if (isDark) await setLight();
      }
      mode = Mode.SYSTEM;
    } else {
      await setLight();
      mode = Mode.LIGHT;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('auto_mode', isAuto);
    refresh();
  }

  Future<void> setLight() async {
    if (isDark) {
      await enterWipe.call();
      isDark = false;
      currentTheme = ThemeColors.fromThemeColors(lightTheme);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', isDark);
      refresh();
      await exitWipe.call();
    }
  }

  Future<void> setDark() async {
    if (!isDark) {
      await enterWipe.call();
      isDark = true;
      currentTheme = ThemeColors.fromThemeColors(darkTheme);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', isDark);
      refresh();
      await exitWipe.call();
    }
  }

  static ThemeColors _getAutoTheme() {
    if (WidgetsBinding.instance?.window.platformBrightness == Brightness.dark)
      return darkTheme;
    return lightTheme;
  }
}
