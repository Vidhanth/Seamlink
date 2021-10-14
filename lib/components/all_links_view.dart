import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/link_tile.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/navigation.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/views/new_link.dart';
import 'package:url_launcher/url_launcher.dart';

class AllLinksView extends StatelessWidget {
  final List<Link> allLinks;
  final String searchText;
  final NoteType selectedType;
  final int labelIndex;

  final ThemeController themeController = Get.find();

  AllLinksView({
    Key? key,
    required this.allLinks,
    required this.searchText,
    required this.selectedType,
    required this.labelIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Link> linksList = [];

    allLinks.forEach((link) {
      bool typeMatch = true;
      bool labelMatch = true;

      if (labelIndex == -2) {
        labelMatch = true;
      } else if (labelIndex == -1) {
        labelMatch = link.labels.isEmpty;
      } else {
        labelMatch = link.labels.contains(labelIndex);
      }

      if (selectedType == NoteType.ALL)
        typeMatch = true;
      else
        typeMatch = link.type! == selectedType;
      if (link.contains(searchText) && typeMatch && labelMatch) {
        linksList.add(link);
      }
    });

    if (linksList.isEmpty) {
      return LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  height: (constraints.maxHeight / 2) - 100,
                ),
                Icon(
                  searchText.isNotEmpty
                      ? Icons.search_off_rounded
                      : Icons.shopping_cart_outlined,
                  size: 80,
                  color: themeController.currentTheme.foreground,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  searchText.isNotEmpty ? 'No results' : 'Nothing here',
                  style: GoogleFonts.poppins(
                    color: themeController.currentTheme.foreground,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                TextButton(
                  onPressed: () {
                    Get.find<HomeController>().refreshLinks();
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    primary: themeController.currentTheme.foreground,
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Refresh'),
                ),
              ],
            ),
          ],
        );
      });
    }

    if (!isScreenWide(context)) {
      return AnimationLimiter(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 40, top: 10),
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              child: SlideAnimation(
                duration: 400.milliseconds,
                child: FadeInAnimation(
                  duration: 400.milliseconds,
                  child: LinkTile(
                    onDismissed: (direction) async {
                      hideKeyboard(context);
                      await Get.find<HomeController>()
                          .deleteLink(context, linksList[index].uid);
                    },
                    searchText: searchText,
                    link: linksList[index],
                    onTap: () async {
                      hideKeyboard(context);
                      if (linksList[index].url.isValidLink) {
                        launch(linksList[index].url);
                      } else {
                        Navigate.to(
                          page: NewLink(link: linksList[index]),
                        );
                      }
                    },
                    onLongPress: () {
                      hideKeyboard(context);
                      showLinkOptions(context, linksList[index]);
                    },
                    onSecondaryTap: () {
                      showLinkOptions(context, linksList[index]);
                    },
                    onTertiaryTap: () async {
                      if (linksList[index].url.isValidLink)
                        await openAndDelete(context, linksList[index]);
                      else
                        Navigate.to(
                          page: NewLink(link: linksList[index]),
                        );
                    },
                  ),
                ),
              ),
            );
          },
          itemCount: linksList.length,
        ),
      );
    } else {
      return AnimationLimiter(
        child: StaggeredGridView.countBuilder(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          crossAxisCount:
              (MediaQuery.of(context).size.width / 300).floor().clamp(2, 5),
          itemCount: linksList.length,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              columnCount:
                  (MediaQuery.of(context).size.width / 300).floor().clamp(2, 5),
              child: FadeInAnimation(
                duration: 400.milliseconds,
                child: SlideAnimation(
                  duration: 400.milliseconds,
                  child: LinkTile(
                    onDismissed: (direction) async {
                      await Get.find<HomeController>()
                          .deleteLink(context, linksList[index].uid);
                    },
                    margin: EdgeInsets.zero,
                    searchText: searchText,
                    link: linksList[index],
                    onTap: () async {
                      if (linksList[index].url.isValidLink) {
                        launch(linksList[index].url);
                      } else {
                        Navigate.to(
                          page: NewLink(link: linksList[index]),
                        );
                      }
                    },
                    onLongPress: () {
                      showLinkOptions(context, linksList[index]);
                    },
                    onSecondaryTap: () {
                      showLinkOptions(context, linksList[index]);
                    },
                    onTertiaryTap: () async {
                      if (linksList[index].url.isValidLink)
                        await openAndDelete(context, linksList[index]);
                      else
                        Navigate.to(
                          page: NewLink(link: linksList[index]),
                        );
                    },
                  ),
                ),
              ),
            );
          },
          staggeredTileBuilder: (index) {
            return StaggeredTile.fit(1);
          },
        ),
      );
    }
  }
}
