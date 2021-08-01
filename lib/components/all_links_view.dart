import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/link_tile.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/views/new_link.dart';
import 'package:url_launcher/url_launcher.dart';

class AllLinksView extends StatelessWidget {
  final List<Link> allLinks;
  final String searchText;

  const AllLinksView({
    Key? key,
    required this.allLinks,
    required this.searchText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Link> linksList = [];

    allLinks.forEach((link) {
      if (link.contains(searchText)) linksList.add(link);
    });

    if (linksList.isEmpty) {
      return LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: (constraints.maxHeight / 2) - 100,
            ),
            Icon(
              searchText.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.shopping_cart_outlined,
              size: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              searchText.isNotEmpty ? 'No results' : 'Nothing here',
              style: GoogleFonts.poppins(),
            ),
            SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () {
                Get.find<HomeController>().refreshLinks();
              },
              child: Text(
                'Refresh',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      });
    }

    if (!isScreenWide(context)) {
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 40, top: 10),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (context, index) {
          return LinkTile(
            onDismissed: (direction) async {
              await Get.find<HomeController>()
                  .deleteLink(context, linksList[index].uid);
            },
            searchText: searchText,
            link: linksList[index],
            onTap: () async {
              if (linksList[index].url.isValidLink) {
                launch(linksList[index].url);
              } else {
                Get.to(
                  () => NewLink(
                    link: linksList[index],
                  ),
                  transition: Transition.rightToLeftWithFade,
                  curve: Curves.fastOutSlowIn,
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
              await openAndDelete(context, linksList[index]);
            },
          );
        },
        itemCount: linksList.length,
      );
    } else {
      return StaggeredGridView.countBuilder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        crossAxisCount:
            (MediaQuery.of(context).size.width / 300).floor().clamp(2, 5),
        itemCount: linksList.length,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        itemBuilder: (context, index) {
          return LinkTile(
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
                Get.to(
                  () => NewLink(
                    link: linksList[index],
                  ),
                  transition: Transition.rightToLeftWithFade,
                  curve: Curves.fastOutSlowIn,
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
              await openAndDelete(context, linksList[index]);
            },
          );
        },
        staggeredTileBuilder: (index) {
          return StaggeredTile.fit(1);
        },
      );
    }
  }
}
