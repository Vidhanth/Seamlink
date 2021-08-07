import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/controllers/HomeController.dart';

class SearchBar extends StatelessWidget {
  final FocusNode focusNode;

  SearchBar({Key? key, required this.focusNode}) : super(key: key);

  final TextEditingController controller = TextEditingController();
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return InputField(
      focusNode: focusNode,
      hint: "Search",
      margin: EdgeInsets.only(right: 0),
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
