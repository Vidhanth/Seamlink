import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart' hide Dismissible, DismissDirection;
import 'package:line_icons/line_icons.dart';
import 'package:octo_image/octo_image.dart';
import 'package:seamlink/controllers/HomeController.dart';
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
          borderRadius: BorderRadius.circular(15),
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
        onHorizontalDragUpdate: isDesktop
            ? null
            : !Get.find<HomeController>().searchFocus.hasFocus
                ? null
                : (d) {
                    hideKeyboard(context, delay: 0.seconds);
                  },
        onVerticalDragUpdate: isDesktop
            ? null
            : !Get.find<HomeController>().searchFocus.hasFocus
                ? null
                : (d) {
                    hideKeyboard(context, delay: 0.seconds);
                  },
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
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colorsList[link.colorIndex],
              width: 2,
            ),
          ),
          duration: 500.milliseconds,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.5),
              splashColor: colorsList[link.colorIndex].withOpacity(0.15),
              highlightColor: Colors.transparent,
              hoverColor: colorsList[link.colorIndex].withOpacity(0.15),
              onTap: () {
                onTap.call();
              },
              child: SingleFutureBuilder(
                future: getLink,
                condition: !(link.autotitle &&
                    link.title != null &&
                    (link.title?.isEmpty ?? false)),
                fallbackData: link,
                childBuilder: (context, data) {
                  return link.url.isYoutubeLink
                      ? _buildYoutubeCard(data)
                      : _buildNote(data);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYoutubeCard(data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: data == null
          ? Column(
              children: [
                _buildShimmer(height: double.infinity),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 15.0,
                  ),
                  child: Row(
                    children: [
                      _buildShimmer(
                        height: 40,
                        rounded: true,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmer(),
                            SizedBox(
                              height: 3.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 50.0),
                              child: _buildShimmer(),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 80.0),
                              child: _buildShimmer(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          : link.thumbnail == null
              ? _buildNote(data)
              : Column(
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: OctoImage(
                            image:
                                NetworkImage(link.thumbnail!.split('||').first),
                            fadeInDuration: 400.milliseconds,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            placeholderBuilder: (context) =>
                                _buildShimmer(height: double.infinity),
                          ),
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
                                color: themeController.currentTheme.foreground,
                                fontSize: 12.5,
                              ),
                              textStyleHighlight: GoogleFonts.poppins(
                                color:
                                    themeController.currentTheme.contrastText,
                                backgroundColor:
                                    themeController.currentTheme.foreground,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: themeController
                                  .currentTheme.backgroundColor
                                  .withOpacity(0.85),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )
                      ],
                    ),
                    if (link.progress != null)
                      LinearProgressIndicator(
                        value: link.progress,
                        color: Colors.red,
                        backgroundColor: themeController.currentTheme.mutedBg,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: OctoImage(
                              image: NetworkImage(
                                link.thumbnail!.split('||').last,
                              ),
                              placeholderBuilder: (context) {
                                return _buildShimmer(
                                  height: 40,
                                  rounded: true,
                                );
                              },
                              height: 40,
                            ),
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SubstringHighlight(
                                  text: link.title ?? "",
                                  term: searchText,
                                  textAlign: TextAlign.start,
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: GoogleFonts.poppins(
                                    color:
                                        themeController.currentTheme.foreground,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  textStyleHighlight: GoogleFonts.poppins(
                                    color: themeController
                                        .currentTheme.contrastText,
                                    backgroundColor:
                                        themeController.currentTheme.foreground,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                SubstringHighlight(
                                  text: link.subtitle!,
                                  term: searchText,
                                  textAlign: TextAlign.start,
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: GoogleFonts.poppins(
                                    color:
                                        themeController.currentTheme.foreground,
                                    fontSize: 15,
                                  ),
                                  textStyleHighlight: GoogleFonts.poppins(
                                    color: themeController
                                        .currentTheme.contrastText,
                                    backgroundColor:
                                        themeController.currentTheme.foreground,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
    );
  }

  Widget _buildShimmer({
    double? height,
    bool rounded: false,
  }) {
    if (rounded)
      return FadeShimmer.round(
        size: height ?? 16,
        baseColor: themeController.currentTheme.subtext.withOpacity(0.1),
        highlightColor: themeController.currentTheme.subtext.withOpacity(0.25),
      );

    if (height == null)
      return FadeShimmer(
        width: double.infinity,
        height: 16,
        radius: 2,
        baseColor: themeController.currentTheme.subtext.withOpacity(0.1),
        highlightColor: themeController.currentTheme.subtext.withOpacity(0.25),
      );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FadeShimmer(
        width: double.infinity,
        height: double.infinity,
        radius: 2,
        baseColor: themeController.currentTheme.subtext.withOpacity(0.1),
        highlightColor: themeController.currentTheme.subtext.withOpacity(0.25),
      ),
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
                  if (link.title != null &&
                      (link.title?.isNotEmpty ?? false)) ...[
                    SubstringHighlight(
                      text: link.title!,
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
