import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menubar/menubar.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/constants/strings.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';
import 'package:seamlink/services/navigation.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/views/new_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  var linksList = <Link>[].obs;
  var searchText = ''.obs;
  var isLoading = true.obs;
  var showSidebar = false.obs;
  var pendingSharedLink = '';
  int sortBy = 0;
  bool ascending = false;
  Function openNewLink = () {};
  FocusNode searchFocus = FocusNode();

  void linkAdded(link, {String? uid}) {
    if (uid == null) {
      linksList.add(link);
    } else {
      int index = linksList.indexWhere((ele) => ele.uid == link.uid);
      linksList[index] = link;
    }
    sortList();
  }

  Future<void> deleteLink(context, uid) async {
    int index = linksList.indexWhere((link) => link.uid == uid);
    Link link = linksList.removeAt(index);
    Result result = await Client.deleteLink(link.uid);
    if (!result.success) {
      showSnackBar('There was an error.', error: true);
      linksList.insert(index, link);
    }
  }

  void updateSortingMethod(int sortingMethod, bool isAscending) async {
    if (sortingMethod != sortBy || isAscending != ascending) {
      final prefs = await SharedPreferences.getInstance();
      sortBy = sortingMethod;
      ascending = isAscending;
      prefs.setInt('sort_by', sortBy);
      prefs.setBool('ascending', ascending);
      sortList();
    }
  }

  void sortList() {
    linksList.sort(
        (link1, link2) => compareLinksList(link1, link2, sortBy, ascending));
  }

  void refreshLinks() async {
    updateMenubar();
    isLoading(true);
    Get.find<SidebarController>().refreshLabels();
    final list = await Client.fetchLinks(
        sortBy: sortByColumns.keys.toList()[sortBy], ascending: ascending);
    if (list is List<dynamic>) {
      var newList = linkFromJson(list);
      linksList.value = newList;
    } else {
      showSnackBar(
        "Please make sure you have internet connectivity.",
        title: "Connection error",
        error: true,
      );
    }
    isLoading(false);
  }

  void updateMenubar() {
    if (isMobile || isWindows) return;
    setApplicationMenu([
      Submenu(
        label: "Actions",
        children: [
          MenuItem(
            label: 'Search',
            enabled: true,
            onClicked: () {
              searchFocus.requestFocus();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.keyS,
            }),
          ),
          MenuDivider(),
          MenuItem(
            label: 'New Note',
            enabled: true,
            onClicked: () {
              openNewLink.call();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.keyN,
              LogicalKeyboardKey.meta,
            }),
          ),
          MenuItem(
            label: 'New Note from Clipboard',
            enabled: true,
            onClicked: () async {
              String copiedText =
                  (await Clipboard.getData('text/plain'))?.text ?? '';
              if (copiedText.isEmpty) {
                showSnackBar('Clipboard is empty');
              }
              Navigate.to(
                page: NewLink(
                  sharedText: copiedText,
                ),
              );
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.keyV,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.meta,
            }),
          ),
          MenuItem(
            label: 'Refresh',
            enabled: true,
            onClicked: () {
              refreshLinks();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.keyR,
              LogicalKeyboardKey.meta,
            }),
          ),
          MenuDivider(),
          MenuItem(
            label: 'Show All',
            enabled: true,
            onClicked: () {
              Get.find<SidebarController>().selectedType(NoteType.ALL);
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyA,
            }),
          ),
          MenuItem(
            label: 'Show Only Notes',
            enabled: true,
            onClicked: () {
              Get.find<SidebarController>().selectedType(NoteType.NOTE);
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyN,
            }),
          ),
          MenuItem(
            label: 'Show Only Links',
            enabled: true,
            onClicked: () {
              Get.find<SidebarController>().selectedType(NoteType.LINK);
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyL,
            }),
          ),
          MenuDivider(),
          MenuItem(
            label: 'Logout',
            enabled: true,
            onClicked: () {
              logout();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.escape,
            }),
          ),
          MenuDivider(),
          MenuItem(
            label: ThemeController.isAuto
                ? 'Light Mode'
                : ThemeController.isDark
                    ? 'System Theme'
                    : 'Dark Mode',
            enabled: true,
            onClicked: () async {
              await Get.find<ThemeController>().switchTheme();
              updateMenubar();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.keyT,
            }),
          ),
        ],
      ),
    ]);
  }
}
