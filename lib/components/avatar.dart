import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/utils.dart';

import '../controllers/UserController.dart';

class Avatar extends StatelessWidget {
  Avatar({Key? key}) : super(key: key);

  final controller = Get.find<SidebarController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Get.find<ThemeController>().currentTheme.splashColor,
      ),
      child: Obx(
        () => InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            switchUserDialog(
              context,
              'Switch user',
              "You're logged in as ${Get.find<UserController>().username}",
            );
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child: controller.userAvatar.value.length == 0
                ? Icon(LineIcons.user)
                : SvgPicture.memory(
                    controller.userAvatar.value,
                    height: 30,
                  ),
          ),
        ),
      ),
    );
  }
}
