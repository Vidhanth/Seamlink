import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart' hide Dismissible, DismissDirection;
import 'package:flutter/material.dart' hide Dismissible, DismissDirection;
import 'package:line_icons/line_icons.dart';
import 'package:octo_image/octo_image.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/extensions.dart';
import 'dismissible.dart';
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
              child: link.url.isYoutubeLink
                  ? _buildYoutubeCard()
                  : SingleFutureBuilder(
                      future: getLink,
                      condition: !(link.autotitle && link.title.isEmpty),
                      fallbackData: link,
                      childBuilder: (context, data) {
                        return _buildNote(data);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYoutubeCard() {
    return SingleFutureBuilder(
      fallbackData: link,
      childBuilder: (context, data) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: data == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmer(height: 145),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 3.0,
                        top: 20.0,
                      ),
                      child: _buildShimmer(),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 20, right: 100, bottom: 8.0),
                      child: _buildShimmer(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 130,
                        bottom: 20.0,
                      ),
                      child: _buildShimmer(),
                    ),
                  ],
                )
              : link.thumbnail == null
                  ? _buildNote(data)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatefulBuilder(builder: (context, setState) {
                          return Stack(
                            children: [
                              OctoImage(
                                image: NetworkImage(link.thumbnail!),
                                placeholderBuilder: (context) =>
                                    _buildShimmer(height: 145.0),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: SubstringHighlight(
                                    textAlign: TextAlign.center,
                                    text: link.message! +
                                        (link.url.contains('playlist')
                                            ? ' videos'
                                            : ''),
                                    term: searchText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: GoogleFonts.poppins(
                                      color: themeController
                                          .currentTheme.foreground,
                                      fontSize: 12.5,
                                    ),
                                    textStyleHighlight: GoogleFonts.poppins(
                                      color: themeController
                                          .currentTheme.contrastText,
                                      backgroundColor: themeController
                                          .currentTheme.foreground,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              )
                            ],
                          );
                        }),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                          child: SubstringHighlight(
                            text: link.title,
                            term: searchText,
                            textAlign: TextAlign.start,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            textStyle: GoogleFonts.poppins(
                              color: themeController.currentTheme.foreground,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            textStyleHighlight: GoogleFonts.poppins(
                              color: themeController.currentTheme.contrastText,
                              backgroundColor:
                                  themeController.currentTheme.foreground,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
                          child: SubstringHighlight(
                            text: link.subtitle!,
                            term: searchText,
                            textAlign: TextAlign.start,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            textStyle: GoogleFonts.poppins(
                              color: themeController.currentTheme.foreground,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                            textStyleHighlight: GoogleFonts.poppins(
                              color: themeController.currentTheme.contrastText,
                              backgroundColor:
                                  themeController.currentTheme.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
      condition: !(link.autotitle && link.title.isEmpty),
      future: getLink,
    );
  }

  Widget _buildShimmer({
    double height: 16,
    double width: double.infinity,
  }) {
    return FadeShimmer(
      width: width,
      height: height,
      radius: 2,
      baseColor: themeController.currentTheme.subtext.withOpacity(0.1),
      highlightColor: themeController.currentTheme.subtext.withOpacity(0.25),
    );
  }

  Widget _buildNote(data) {
    return AnimatedSwitcher(
      duration: 400.milliseconds,
      child: data != null
          ? Padding(
              padding: padding,
              child: Column(
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
                        color: themeController.currentTheme.foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textStyleHighlight: GoogleFonts.poppins(
                        color: themeController.currentTheme.contrastText,
                        backgroundColor:
                            themeController.currentTheme.foreground,
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
                      color: themeController.currentTheme.foreground,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                    textStyleHighlight: GoogleFonts.poppins(
                      color: themeController.currentTheme.contrastText,
                      backgroundColor: themeController.currentTheme.foreground,
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
                        color: themeController.currentTheme.foreground,
                        fontSize: 15,
                      ),
                      textStyleHighlight: GoogleFonts.poppins(
                        color: themeController.currentTheme.contrastText,
                        backgroundColor:
                            themeController.currentTheme.foreground,
                      ),
                    ),
                  ]
                ],
              ),
            )
          : Padding(
              padding: padding,
              child: Column(
                children: [
                  _buildShimmer(),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: _buildShimmer(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: _buildShimmer(),
                  ),
                ],
              ),
            ),
    );
  }
}
