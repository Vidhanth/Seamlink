import 'package:flutter/cupertino.dart' hide Dismissible, DismissDirection;
import 'package:flutter/material.dart' hide Dismissible, DismissDirection;
import 'package:line_icons/line_icons.dart';
import 'dismissible.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/single_future_builder.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/services/extensions.dart';
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
            color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          LineIcons.trash,
          color: Colors.white,
          size: 25,
        ),
      ),
      confirmDismiss: (direction) async {
        hideKeyboard(context, delay: 0.milliseconds);
        String noteOrLink = link.url.isValidLink ? "link" : "note";
        return await confirmDialog(context, "Delete $noteOrLink?",
                "Are you sure you want to delete this $noteOrLink? This cannot be undone.") ??
            false;
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
            color: colorsList[link.colorIndex],
            boxShadow: [BoxShadow(blurRadius: 7, color: Colors.black12)],
            borderRadius: BorderRadius.circular(20),
          ),
          duration: 500.milliseconds,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white30,
              highlightColor: Colors.transparent,
              hoverColor: Colors.black12,
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textStyle: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textStyleHighlight: GoogleFonts.poppins(
                                        color: accent,
                                        backgroundColor: Colors.white,
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
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                    textStyleHighlight: GoogleFonts.poppins(
                                      color: accent,
                                      backgroundColor: Colors.white,
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
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      textStyleHighlight: GoogleFonts.poppins(
                                        color: accent,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ]
                                ],
                              )
                            : SpinKitChasingDots(
                                size: 30,
                                color: Colors.white,
                              ),
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
