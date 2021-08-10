import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/SidebarController.dart';

// ignore: must_be_immutable
class FilterRow extends StatelessWidget {
  FilterRow({Key? key}) : super(key: key);

  SidebarController sidebarController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (sidebarController.selectedType.value != NoteType.ALL)
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: FadeIn(
              child: FilterChip(
                onSelected: (val) {
                  sidebarController.selectedType(NoteType.ALL);
                },
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 2,
                ),
                labelPadding: EdgeInsets.only(
                  right: 4,
                  left: 2,
                ),
                avatar: Icon(
                  Icons.remove_circle,
                  size: 20,
                ),
                labelStyle: GoogleFonts.poppins(),
                label: Text(
                    sidebarController.selectedType.value == NoteType.LINK
                        ? "Links"
                        : "Notes"),
              ),
            ),
          ),
        if (sidebarController.labelIndex.value != (-2))
          sidebarController.labelIndex.value == -1
              ? FadeIn(
                  child: FilterChip(
                    onSelected: (val) {
                      sidebarController.labelIndex(-2);
                    },
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    labelPadding: EdgeInsets.only(
                      right: 4,
                      left: 2,
                    ),
                    avatar: Icon(
                      Icons.remove_circle,
                      size: 20,
                    ),
                    labelStyle: GoogleFonts.poppins(),
                    label: Text(
                      'Untagged',
                    ),
                  ),
                )
              : FadeIn(
                  child: FilterChip(
                    onSelected: (val) {
                      sidebarController.labelIndex(-2);
                    },
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    labelPadding: EdgeInsets.only(
                      right: 4,
                      left: 2,
                    ),
                    avatar: Icon(
                      Icons.remove_circle,
                      size: 20,
                    ),
                    labelStyle: GoogleFonts.poppins(),
                    label: Text(
                      sidebarController
                          .labels[sidebarController.labelIndex.value],
                    ),
                  ),
                ),
      ],
    );
  }
}
