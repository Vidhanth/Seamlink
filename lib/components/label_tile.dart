import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/controllers/ThemeController.dart';

class LabelTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final IconData? iconSecondary;
  final Function onTap;
  final Function? onLongPress;
  final bool? editing;

  final ThemeController themeController = Get.find();

  LabelTile({
    Key? key,
    required this.label,
    required this.isSelected,
    this.icon,
    this.iconSecondary,
    required this.onTap,
    this.onLongPress,
    this.editing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap.call();
        },
        onLongPress: () {
          onLongPress?.call();
        },
        focusColor: themeController.currentTheme.focusColor,
        splashColor: themeController.currentTheme.splashColor,
        hoverColor: themeController.currentTheme.hoverColor,
        child: GestureDetector(
          onSecondaryTap: () {
            onLongPress?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              color: isSelected ? themeController.currentTheme.splashColor : Colors.transparent,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Icon(
                      icon ?? LineIcons.tag,
                      color: themeController.currentTheme.foreground,
                    ),
                    if (iconSecondary != null)
                      Icon(
                        iconSecondary!,
                        size: 10,
                        color: themeController.currentTheme.foreground,
                      ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: themeController.currentTheme.foreground,
                  ),
                ),
                Spacer(),
                if (editing ?? false)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: FadeIn(
                        child: Icon(
                      LineIcons.pen,
                      color: themeController.currentTheme.foreground,
                      size: 20,
                    )),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
