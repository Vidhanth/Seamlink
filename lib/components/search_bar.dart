import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/utils.dart';

class SearchBar extends StatefulWidget {
  SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();

  final homeController = Get.find<HomeController>();
  final themeController = Get.find<ThemeController>();

  Animation<double>? _menuIconAnim;

  @override
  void initState() {
    if (isMobile) {
      homeController.menuIconController =
          AnimationController(vsync: this, duration: 800.milliseconds);
      _menuIconAnim = homeController.menuIconController!
          .drive(CurveTween(curve: Curves.easeInOut));
    }
    super.initState();
  }

  @override
  void dispose() {
    homeController.menuIconController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputField(
            cursorColor: themeController.currentTheme.subtext,
            bgColor: themeController.currentTheme.mutedBg,
            focusNode: homeController.searchFocus,
            hint: "Search",
            radius: 15,
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
            prefixIcon: isDesktop
                ? null
                : Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        if (isMobile) {
                          hideKeyboard(context);
                          homeController.toggleSidebar();
                          Get.find<SidebarController>().editMode(false);
                        }
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: AnimatedIcon(
                          progress: _menuIconAnim!,
                          icon: AnimatedIcons.menu_close,
                          color: themeController.currentTheme.foreground,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
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
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              hideKeyboard(context, delay: 0.seconds);
              showSortingMenu(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10),
              child: Icon(
                Icons.sort,
                color: themeController.currentTheme.foreground,
              ),
            ),
          ),
        )
      ],
    );
  }
}
