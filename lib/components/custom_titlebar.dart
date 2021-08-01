import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:seamlink/components/search_bar.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/services/utils.dart';

class CustomTitleBar extends StatelessWidget {
  bool? macStyle;
  String? title;
  CustomTitleBar({Key? key, this.macStyle, this.title}) : super(key: key) {
    macStyle ??= isMacOS;
    title ??= "s e a m l i n k   d e s k t o p".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: (isWindows ? 35 : 30) * (macStyle! ? 3 : 1),
            color: primaryBg,
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
                                top: 15, bottom: 10, left: 20, right: 20),
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
