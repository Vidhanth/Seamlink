import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seamlink/constants/strings.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/utils.dart';

class SortingMenu extends StatelessWidget {
  SortingMenu({Key? key}) : super(key: key);

  final ThemeController themeController = Get.find();
  final HomeController homeController = Get.find();

  Widget buildSortingMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Text(
            'Sort By',
            style: TextStyle(
              color: themeController.currentTheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: sortByColumns.keys
              .map(
                (key) => ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  trailing: Icon(
                    Icons.check,
                    color: sortByColumns.keys.toList().indexOf(key) ==
                            homeController.sortBy
                        ? themeController.currentTheme.foreground
                        : Colors.transparent,
                  ),
                  onTap: () {
                    homeController.updateSortingMethod(
                      sortByColumns.keys.toList().indexOf(key),
                      homeController.ascending,
                    );
                    Get.back();
                  },
                  leading: Text(
                    sortByColumns[key]!,
                    style: TextStyle(
                      color: themeController.currentTheme.foreground,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Divider(),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [false, true]
              .map(
                (ascending) => ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  trailing: Icon(
                    Icons.check,
                    color: ascending == homeController.ascending
                        ? themeController.currentTheme.foreground
                        : Colors.transparent,
                  ),
                  onTap: () {
                    homeController.updateSortingMethod(
                      homeController.sortBy,
                      ascending,
                    );
                    Get.back();
                  },
                  leading: Text(
                    ascending ? 'Oldest First' : 'Newest First',
                    style: TextStyle(
                      color: themeController.currentTheme.foreground,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isScreenWide(context) || (Get.isDialogOpen ?? false)) {
      return AlertDialog(
        backgroundColor: themeController.currentTheme.backgroundColor,
        contentPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: buildSortingMenu(),
      );
    }

    return BottomSheet(
      backgroundColor: themeController.currentTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      onClosing: () {},
      enableDrag: false,
      builder: (context) => SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: buildSortingMenu(),
          ),
        ),
      ),
    );
  }
}
