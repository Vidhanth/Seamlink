import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/controllers/HomeController.dart';

class SearchBar extends StatefulWidget {
  final FocusNode focusNode;

  SearchBar({Key? key, required this.focusNode}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController controller = TextEditingController();

  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return InputField(
      focusNode: widget.focusNode,
      hint: "Search",
      style: GoogleFonts.poppins(),
      onChanged: (query) {
        homeController.searchText.value = query.toLowerCase().trim();
      },
      controller: controller,
      suffix: Obx(
        () => homeController.searchText.value.trim().isEmpty
            ? SizedBox()
            : InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  homeController.searchText.value = '';
                  controller.clear();
                },
                child: Icon(
                  LineIcons.backspace,
                ),
              ),
      ),
    );
  }
}
