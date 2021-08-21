import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/all_links_view.dart';
import 'package:seamlink/components/filter_row.dart';
import 'package:seamlink/components/search_bar.dart';
import 'package:seamlink/components/sidebar.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/views/auth_view.dart';
import 'package:seamlink/views/new_link.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final HomeController homeController = Get.find<HomeController>();
  final FocusNode searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Get.find<UserController>().username.isEmpty) return AuthView();
      return Scaffold(
        backgroundColor: primaryBg,
        drawer: isMobile ? Sidebar() : null,
        body: Builder(
          builder: (context) {
            return Stack(
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 0),
                                  child: Row(
                                    mainAxisAlignment: isScreenWide(context)
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (isMobile) ...[
                                        InkWell(
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            searchFocus.unfocus();
                                            Scaffold.of(context).openDrawer();
                                            Get.find<SidebarController>()
                                                .editMode(false);
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 20.0, left: 0),
                                            child: Icon(
                                              LineIcons.bars,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ],
                                      isDesktop
                                          ? SizedBox()
                                          : Text(
                                              'Seamlink',
                                              style: GoogleFonts.poppins(
                                                fontSize: 50,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                if (!isMacOS) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: SearchBar(focusNode: searchFocus),
                                  ),
                                ],
                                Obx(
                                  () {
                                    SidebarController sidebarController =
                                        Get.find();
                                    return Expanded(
                                      child: AnimatedSwitcher(
                                        duration: 500.milliseconds,
                                        child: homeController.isLoading.value
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 30.0),
                                                child: SpinKitChasingDots(
                                                    size: 30, color: accent),
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AnimatedContainer(
                                                    margin: (sidebarController
                                                                    .selectedType
                                                                    .value !=
                                                                NoteType.ALL ||
                                                            sidebarController
                                                                    .labelIndex
                                                                    .value !=
                                                                -2)
                                                        ? EdgeInsets.only(
                                                            left: 25,
                                                            top: 0,
                                                            bottom: 0)
                                                        : EdgeInsets.zero,
                                                    width: double.infinity,
                                                    alignment: Alignment.centerLeft,
                                                    height: (sidebarController
                                                                    .selectedType
                                                                    .value !=
                                                                NoteType.ALL ||
                                                            sidebarController
                                                                    .labelIndex
                                                                    .value !=
                                                                -2)
                                                        ? 50
                                                        : 0,
                                                    duration: 300.milliseconds,
                                                    curve: Curves.fastOutSlowIn,
                                                    child: FilterRow(),
                                                  ),
                                                  Expanded(
                                                    child: RefreshIndicator(
                                                      color: accent,
                                                      onRefresh: () async {
                                                        Get.showSnackbar(GetBar(
                                                          // title: "You're up to date!",
                                                          message:
                                                              "Links were updated.",
                                                          duration: 2.seconds,
                                                        ));
                                                        homeController
                                                            .refreshLinks();
                                                        return;
                                                      },
                                                      child: AllLinksView(
                                                        allLinks: homeController
                                                            .linksList.value,
                                                        searchText: homeController
                                                            .searchText.value,
                                                        selectedType:
                                                            sidebarController
                                                                .selectedType.value,
                                                        labelIndex:
                                                            sidebarController
                                                                .labelIndex.value,
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
                              child: OpenContainer(
                                closedColor: accent,
                                closedElevation: 15,
                                closedShape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100.0)),
                                ),
                                transitionDuration: 400.milliseconds,
                                transitionType: ContainerTransitionType.fadeThrough,
                                closedBuilder: (_, openContainer) {
                                  return InkWell(
                                    onTap: () {
                                      hideKeyboard(context, delay: 0.milliseconds);
                                      openContainer.call();
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                                openBuilder: (_, __) {
                                  return NewLink();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      );
    });
  }
}
