import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/services/navigation.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/views/new_link.dart';
import 'package:share_plus/share_plus.dart';

class LinkOptions extends StatelessWidget {
  final Link link;
  LinkOptions({Key? key, required this.link}) : super(key: key);

  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (isScreenWide(context) || (Get.isDialogOpen ?? false)) {
      return AlertDialog(
        backgroundColor: themeController.currentTheme.backgroundColor,
        contentPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: _buildOptionsColumn(context),
      );
    }

    return BottomSheet(
      backgroundColor: themeController.currentTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      onClosing: () {},
      enableDrag: false,
      builder: (context) => SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: _buildOptionsColumn(context),
          ),
        ),
      ),
    );
  }

  Column _buildOptionsColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (link.url.isValidLink) ...[
          _buildOption("Open and delete link", LineIcons.alternateExternalLink,
              () async {
            Get.back();
            await openAndDelete(context, link);
          }),
        ],
        _buildOption(
            link.url.isValidLink ? "Edit link" : "Edit note", LineIcons.edit,
            () async {
          Get.back();
          Navigate.to(
            page: NewLink(link: link),
          );
        }),
        _buildOption(link.url.isValidLink ? "Copy link" : "Copy contents",
            LineIcons.clipboardAlt, () {
          link.url.copyToClipboard();
          Get.back();
          showSnackBar("Copied to clipboard!");
        }),
        if (isMobile) ...[
          _buildOption("Share ${noteOrLink(link.url)}", LineIcons.share,
              () async {
            Get.back();
            String textToShare = (!link.autotitle && link.title != null
                    ? link.title! + "\n"
                    : '') +
                link.url;
            Share.share(textToShare);
          }),
        ],
        _buildOption(link.url.isValidLink ? "Delete link" : "Delete note",
            LineIcons.trash, () async {
          Get.back();
          if (await confirmDialog(
                context,
                "Delete ${noteOrLink(link.url)}?",
                "Are you sure you want to delete this ${noteOrLink(link.url)}? This cannot be undone.",
              ) ??
              false) {
            await Get.find<HomeController>().deleteLink(context, link.uid);
            Get.back();
          }
        }),
      ],
    );
  }

  Widget _buildOption(String title, IconData icon, Function onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        onTap.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: themeController.currentTheme.foreground,
            ),
            SizedBox(
              width: 10,
            ),
            Text(title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: themeController.currentTheme.foreground,
                )),
          ],
        ),
      ),
    );
  }
}
