import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:get/get.dart';
import 'package:seamlink/components/search_bar.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/utils.dart';

// ignore: must_be_immutable
class CustomTitleBar extends StatelessWidget {
  bool? macStyle;
  String? title;
  CustomTitleBar({Key? key, this.macStyle = true, this.title})
      : super(key: key) {
    title ??= "s e a m l i n k   d e s k t o p".toUpperCase();
  }

  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: themeController.currentTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: (isWindows ? 35 : 30) * (macStyle! ? 3 : 1),
            color: themeController.currentTheme.backgroundColor,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width -
                (title!.isEmpty
                    ? 0
                    : (MediaQuery.of(context).size.width * 0.2)
                        .clamp(200, 400)),
            child: MoveWindow(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !macStyle!
                      ? Container(
                          child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Platform.isWindows ? 10 : 7.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(title!),
                            ],
                          ),
                        ))
                      : Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 15, bottom: 10, left: 25, right: 25),
                            child: SearchBar(),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
