import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/constants/strings.dart';
import 'package:seamlink/controllers/SidebarController.dart';
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
  var customMenubarItems = [].obs;
  var pendingSharedLink = '';
  int sortBy = 0;
  bool ascending = false;
  Function openNewLink = () {};
  FocusNode searchFocus = FocusNode();
  AnimationController? menuIconController;

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

  void toggleSidebar({bool? value}) {
    if (isMobile) {
      if (value != null) {
        if (value == showSidebar.value) return;
      }
      if (showSidebar.isTrue) {
        menuIconController?.reverse();
      } else {
        menuIconController?.forward();
      }
      if (value != null) showSidebar(value);
      if (value == null) showSidebar.toggle();
    }
  }

  void reset() {
    linksList.clear();
    toggleSidebar(value: false);
    searchText('');
  }

  List getMenuItems() {
    if (customMenubarItems.isNotEmpty) {
      return customMenubarItems;
    }
    return [
      PlatformMenuItemGroup(
        members: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenu(
                label: 'New',
                menus: [
                  PlatformMenuItem(
                    label: 'New Note',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyN,
                        meta: true),
                    onSelected: () {
                      openNewLink.call();
                    },
                  ),
                  PlatformMenuItem(
                    label: 'New Note from Clipboard',
                    onSelected: () async {
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
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyV,
                      meta: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Refresh',
                shortcut:
                    const SingleActivator(LogicalKeyboardKey.keyR, meta: true),
                onSelected: () {
                  refreshLinks();
                },
              ),
              PlatformMenuItem(
                label: 'Search',
                shortcut: const CharacterActivator('s'),
                onSelected: () {
                  searchFocus.requestFocus();
                },
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenu(
                label: 'Sort',
                menus: [
                  PlatformMenuItemGroup(
                    members: [
                      PlatformMenuItem(
                        label: 'Date Added',
                        onSelected: () {
                          final homeController = Get.find<HomeController>();
                          homeController.updateSortingMethod(
                            0,
                            homeController.ascending,
                          );
                        },
                      ),
                      PlatformMenuItem(
                        label: 'Date Updated',
                        onSelected: () {
                          final homeController = Get.find<HomeController>();
                          homeController.updateSortingMethod(
                            1,
                            homeController.ascending,
                          );
                        },
                      ),
                    ],
                  ),
                  PlatformMenuItemGroup(
                    members: [
                      PlatformMenuItem(
                        label: 'Newest First',
                        onSelected: () {
                          final homeController = Get.find<HomeController>();
                          homeController.updateSortingMethod(
                            homeController.sortBy,
                            false,
                          );
                        },
                      ),
                      PlatformMenuItem(
                        label: 'Oldest First',
                        onSelected: () {
                          final homeController = Get.find<HomeController>();
                          homeController.updateSortingMethod(
                            homeController.sortBy,
                            true,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              PlatformMenu(
                label: 'Filter',
                menus: [
                  PlatformMenuItem(
                    label: 'All',
                    shortcut: SingleActivator(
                      LogicalKeyboardKey.keyA,
                      shift: true,
                      meta: true,
                    ),
                    onSelected: () {
                      Get.find<SidebarController>().selectedType(NoteType.ALL);
                    },
                  ),
                  PlatformMenuItem(
                    label: 'Links Only',
                    shortcut: SingleActivator(
                      LogicalKeyboardKey.keyL,
                      shift: true,
                      meta: true,
                    ),
                    onSelected: () {
                      Get.find<SidebarController>().selectedType(NoteType.LINK);
                    },
                  ),
                  PlatformMenuItem(
                    label: 'Notes Only',
                    shortcut: SingleActivator(
                      LogicalKeyboardKey.keyN,
                      shift: true,
                      meta: true,
                    ),
                    onSelected: () {
                      Get.find<SidebarController>().selectedType(NoteType.NOTE);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      )
    ];
  }
}
