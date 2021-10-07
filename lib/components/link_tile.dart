import 'package:flutter/cupertino.dart' hide Dismissible, DismissDirection;
import 'package:flutter/material.dart' hide Dismissible, DismissDirection;
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'dismissible.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/single_future_builder.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/utils.dart';
import 'package:substring_highlight/substring_highlight.dart';

// ignore: must_be_immutable
class LinkTile extends StatelessWidget {
  Link link;
  late Future<dynamic> getLink;
  final String searchText;
  final Function onTap;
  final Function? onLongPress;
  final Function? onSecondaryTap;
  final Function? onTertiaryTap;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Function onDismissed;

  final ThemeController themeController = Get.find();

  LinkTile({
    Key? key,
    required this.link,
    required this.onTap,
    required this.onDismissed,
    this.onLongPress,
    this.onSecondaryTap,
    this.onTertiaryTap,
    this.margin = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 5,
    ),
    this.searchText = '',
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key) {
    this.getLink = getLinkData(link);
  }

  Future<bool> _confirmDismiss(direction) async {
    hideKeyboard(Get.context, delay: 0.milliseconds);
    return await confirmDialog(Get.context, "Delete ${noteOrLink(link.url)}?",
            "Are you sure you want to delete this ${noteOrLink(link.url)}? This cannot be undone.") ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: UniqueKey(),
      background: Container(
        margin: margin,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          LineIcons.trash,
          color: Colors.white,
          size: 25,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _confirmDismiss(direction);
      },
      onDismissed: (direction) {
        onDismissed.call(direction);
      },
      enableDismiss: isMobile,
      child: GestureDetector(
        onLongPress: () {
          onLongPress?.call();
        },
        onSecondaryTap: () {
          onSecondaryTap?.call();
        },
        onTertiaryTapDown: (d) {
          onTertiaryTap?.call();
        },
        child: AnimatedContainer(
          margin: margin,
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeController.currentTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                  blurRadius: 5, color: themeController.currentTheme.shadow),
            ],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorsList[link.colorIndex],
              width: 3,
            ),
          ),
          duration: 500.milliseconds,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              splashColor: colorsList[link.colorIndex].withOpacity(0.15),
              highlightColor: Colors.transparent,
              hoverColor: colorsList[link.colorIndex].withOpacity(0.15),
              onTap: () {
                onTap.call();
              },
              child: Padding(
                padding: padding,
                child: SingleFutureBuilder(
                  future: getLink,
                  condition: !(link.autotitle && link.title.isEmpty),
                  fallbackData: link,
                  childBuilder: (context, data) {
                    return AnimatedSwitcher(
                      duration: 400.milliseconds,
                      child: data != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (link.title.isNotEmpty) ...[
                                  SubstringHighlight(
                                    text: link.title,
                                    textAlign: TextAlign.center,
                                    term: searchText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: GoogleFonts.poppins(
                                      color: themeController
                                          .currentTheme.foreground,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textStyleHighlight: GoogleFonts.poppins(
                                      color: themeController
                                          .currentTheme.contrastText,
                                      backgroundColor: themeController
                                          .currentTheme.foreground,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                                SubstringHighlight(
                                  text: link.subtitle?.isEmpty ?? true
                                      ? link.url
                                      : link.subtitle!,
                                  term: searchText,
                                  textAlign: TextAlign.center,
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: GoogleFonts.poppins(
                                    color:
                                        themeController.currentTheme.foreground,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                  ),
                                  textStyleHighlight: GoogleFonts.poppins(
                                    color: themeController
                                        .currentTheme.contrastText,
                                    backgroundColor:
                                        themeController.currentTheme.foreground,
                                  ),
                                ),
                                if (link.message != null) ...[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SubstringHighlight(
                                    textAlign: TextAlign.center,
                                    text: link.message!,
                                    term: searchText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: GoogleFonts.poppins(
                                      color: themeController
                                          .currentTheme.foreground,
                                      fontSize: 15,
                                    ),
                                    textStyleHighlight: GoogleFonts.poppins(
                                      color: themeController
                                          .currentTheme.contrastText,
                                      backgroundColor: themeController
                                          .currentTheme.foreground,
                                    ),
                                  ),
                                ]
                              ],
                            )
                          : SpinKitChasingDots(
                              size: 30,
                              color: colorsList[link.colorIndex],
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
