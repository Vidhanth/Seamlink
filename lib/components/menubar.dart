import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/controllers/UserController.dart';

import '../services/utils.dart';

class MenuBar extends StatelessWidget {
  final Widget child;
  final bool enable;

  const MenuBar({Key? key, required this.child, required this.enable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (enable)
      return Obx(() {
        bool isLoggedIn = Get.find<UserController>().username.isNotEmpty;

        return PlatformMenuBar(
          menus: <PlatformMenuItem>[
            PlatformMenu(
              label: 'Seamlink',
              menus: <PlatformMenuItem>[
                if (isLoggedIn) ...Get.find<HomeController>().getMenuItems(),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: ThemeController.isAuto
                          ? 'Light Mode'
                          : ThemeController.isDark
                              ? 'System Theme'
                              : 'Dark Mode',
                      onSelected: () async {
                        await Get.find<ThemeController>().switchTheme();
                      },
                      shortcut: const SingleActivator(
                        LogicalKeyboardKey.keyT,
                        meta: true,
                      ),
                    ),
                  ],
                ),
                if (isLoggedIn)
                  PlatformMenuItemGroup(
                    members: [
                      PlatformMenuItem(
                        label: 'Log Out',
                        onSelected: () async {
                          await logout();
                        },
                        shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyL,
                          meta: true,
                        ),
                      ),
                    ],
                  ),
                if (PlatformProvidedMenuItem.hasMenu(PlatformProvidedMenuItemType.servicesSubmenu))
                  const PlatformMenuItemGroup(
                    members: [
                      PlatformProvidedMenuItem(
                        type: PlatformProvidedMenuItemType.servicesSubmenu,
                      )
                    ],
                  ),
                if (PlatformProvidedMenuItem.hasMenu(PlatformProvidedMenuItemType.quit))
                  const PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
              ],
            ),
          ],
          child: child,
        );
      });
    return child;
  }
}
