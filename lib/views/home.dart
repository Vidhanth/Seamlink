// ignore_for_file: invalid_use_of_protected_member

import 'package:animations/animations.dart';
import 'package:flutter/material.dart' hide MenuBar, SearchBar;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:seamlink/components/all_links_view.dart';
import 'package:seamlink/components/filter_row.dart';
import 'package:seamlink/components/menubar.dart';
import 'package:seamlink/components/search_bar.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/navigation.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/views/new_link.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final HomeController homeController = Get.find<HomeController>();
  final ThemeController themeController = Get.find();
  final FocusNode searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (homeController.showSidebar.isTrue) {
          homeController.toggleSidebar();
          return false;
        }
        return true;
      },
      child: MenuBar(
        child: Builder(builder: (context) {
          String pendingLink = homeController.pendingSharedLink;
          homeController.pendingSharedLink = "";
          if (pendingLink.isNotEmpty) {
            Future.delayed(100.milliseconds, () {
              Navigate.to(
                page: NewLink(
                  sharedText: pendingLink,
                ),
              );
            });
          }
          return Scaffold(
            backgroundColor: themeController.currentTheme.backgroundColor,
            body: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: SearchBar(),
                                ),
                                Obx(
                                  () {
                                    SidebarController sidebarController = Get.find();
                                    return Expanded(
                                      child: AnimatedSwitcher(
                                        duration: 500.milliseconds,
                                        child: homeController.isLoading.value
                                            ? Padding(
                                                padding: EdgeInsets.only(bottom: 30.0),
                                                child: SpinKitChasingDots(size: 30, color: themeController.currentTheme.accent),
                                              )
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  AnimatedContainer(
                                                    margin: (sidebarController.selectedType.value != NoteType.ALL ||
                                                            sidebarController.labelIndex.value != -2)
                                                        ? EdgeInsets.only(left: 25, top: 0, bottom: 0)
                                                        : EdgeInsets.zero,
                                                    width: double.infinity,
                                                    alignment: Alignment.centerLeft,
                                                    height: (sidebarController.selectedType.value != NoteType.ALL ||
                                                            sidebarController.labelIndex.value != -2)
                                                        ? 50
                                                        : 0,
                                                    duration: 300.milliseconds,
                                                    curve: Curves.fastOutSlowIn,
                                                    child: FilterRow(),
                                                  ),
                                                  Expanded(
                                                    child: RefreshIndicator(
                                                      color: themeController.currentTheme.accent,
                                                      onRefresh: () async {
                                                        searchFocus.unfocus();
                                                        showSnackBar(
                                                          "Links were updated.",
                                                        );
                                                        homeController.refreshLinks();
                                                        return;
                                                      },
                                                      child: AllLinksView(
                                                        allLinks: homeController.linksList.value,
                                                        searchText: homeController.searchText.value,
                                                        selectedType: sidebarController.selectedType.value,
                                                        labelIndex: sidebarController.labelIndex.value,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Row(
                                children: [
                                  FloatingActionButton(
                                    heroTag: 'refresh',
                                    onPressed: () {
                                      homeController.refreshLinks();
                                    },
                                    hoverColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                                    focusColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                                    splashColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                                    backgroundColor: themeController.currentTheme.accent,
                                    child: Icon(
                                      Icons.refresh,
                                      color: themeController.currentTheme.contrastText,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  OpenContainer(
                                    closedColor: themeController.currentTheme.backgroundColor,
                                    middleColor: themeController.currentTheme.backgroundColor,
                                    openColor: themeController.currentTheme.backgroundColor,
                                    closedElevation: 15,
                                    closedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(100.0)),
                                    ),
                                    transitionDuration: 400.milliseconds,
                                    transitionType: ContainerTransitionType.fadeThrough,
                                    closedBuilder: (_, openContainer) {
                                      homeController.openNewLink = openContainer;
                                      return FloatingActionButton(
                                        heroTag: 'new_link',
                                        onPressed: () {
                                          hideKeyboard(context, delay: 0.milliseconds);
                                          openContainer.call();
                                        },
                                        hoverColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                                        focusColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                                        splashColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                                        backgroundColor: themeController.currentTheme.accent,
                                        child: Icon(
                                          Icons.add,
                                          color: themeController.currentTheme.contrastText,
                                        ),
                                      );
                                    },
                                    openBuilder: (_, __) {
                                      return NewLink();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        enable: isMacOS,
      ),
    );
  }
}
