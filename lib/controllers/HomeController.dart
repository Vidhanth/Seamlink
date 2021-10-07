import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menubar/menubar.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';
import 'package:seamlink/services/utils.dart';

class HomeController extends GetxController {
  var linksList = <Link>[].obs;
  var searchText = ''.obs;
  var isLoading = true.obs;
  var showSidebar = false.obs;
  Function openNewLink = () {};
  FocusNode searchFocus = FocusNode();

  void linkAdded(link, {String? uid}) {
    if (uid == null) {
      linksList.add(link);
    } else {
      int index = linksList.indexWhere((ele) => ele.uid == link.uid);
      linksList[index] = link;
    }
    linksList.sort((link1, link2) => compareLinksList(link1, link2));
  }

  Future<void> deleteLink(context, uid) async {
    Result result = await Client.deleteLink(uid);
    if (result.success) {
      linksList.removeWhere((link) => link.uid == result.message);
    } else
      showSnackBar(context, 'There was an error.', error: true);
  }

  void refreshLinks({String? sortBy, bool? ascending}) async {
    updateMenubar();
    isLoading(true);
    Get.find<SidebarController>().refreshLabels();
    final list = await Client.fetchLinks(sortBy: sortBy, ascending: ascending);
    if (list is List<dynamic>) {
      var newList = linkFromJson(list);
      linksList.value = newList;
    } else {
      Get.showSnackbar(GetBar(
        title: "Connection error",
        message: "Please make sure you have internet connectivity.",
        backgroundColor: Colors.red,
        duration: 2.seconds,
      ));
    }
    isLoading(false);
  }

  void updateMenubar() {
    if (isMobile) return;
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
            label: ThemeController.isDark ? 'Light Mode' : 'Dark Mode',
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
