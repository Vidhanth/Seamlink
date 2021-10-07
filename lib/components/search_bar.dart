import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/ThemeController.dart';

class SearchBar extends StatefulWidget {
  SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController controller = TextEditingController();

  final homeController = Get.find<HomeController>();
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return InputField(
      cursorColor: themeController.currentTheme.subtext,
      bgColor: themeController.currentTheme.mutedBg,
      focusNode: homeController.searchFocus,
      hint: "Search",
      style: GoogleFonts.poppins(
        fontSize: 18,
        color: themeController.currentTheme.foreground,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 18,
        color: themeController.currentTheme.foreground.withOpacity(0.5),
      ),
      onChanged: (query) {
        homeController.searchText.value = query.toLowerCase().trim();
      },
      controller: controller,
      suffix: Obx(
        () => homeController.searchText.value.trim().isEmpty
            ? SizedBox()
            : InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  homeController.searchText.value = '';
                  controller.clear();
                },
                child: Icon(
                  LineIcons.backspace,
                  color: themeController.currentTheme.foreground,
                ),
              ),
      ),
    );
  }
}
