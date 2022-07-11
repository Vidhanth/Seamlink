import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/services/utils.dart';

class LinkDetails extends StatelessWidget {
  LinkDetails({Key? key, required this.link}) : super(key: key);

  final Link link;
  final ThemeController themeController = Get.find<ThemeController>();

  Widget _buildLinkDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetail("Date created", link.timestamp.displayString),
        SizedBox(
          height: 10,
        ),
        _buildDetail("Date updated", link.updatedAt.displayString),
      ],
    );
  }

  Widget _buildDetail(String title, String subtitle) {
    final textStyleHeader = GoogleFonts.poppins(
      fontSize: 18,
      color: themeController.currentTheme.foreground,
    );
    final textStyleSubheader = GoogleFonts.poppins(
      fontSize: 16,
      color: themeController.currentTheme.subtext,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textStyleHeader,
        ),
        Text(
          subtitle,
          style: textStyleSubheader,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isScreenWide(context) || (Get.isDialogOpen ?? false)) {
      return AlertDialog(
        backgroundColor: themeController.currentTheme.backgroundColor,
        contentPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: _buildLinkDetails(),
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _buildLinkDetails(),
          ),
        ),
      ),
    );
  }
}
