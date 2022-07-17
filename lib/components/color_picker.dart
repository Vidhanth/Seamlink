import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/utils.dart';

class ColorPicker extends StatelessWidget {
  final Function onColorSelected;
  final int selectedIndex;
  static final size = isDesktop ? 30.0 : 35.0;

  final ThemeController themeController = Get.find();

  ColorPicker(
      {Key? key, required this.onColorSelected, required this.selectedIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            colorsList.length,
            (index) {
              return Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: colorsList[index],
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: themeController.currentTheme.splashColor,
                    hoverColor: themeController.currentTheme.hoverColor,
                    focusColor: themeController.currentTheme.focusColor,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      onColorSelected.call(index);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: size,
                      width: size,
                      child: index == selectedIndex
                          ? Container(
                              height: size,
                              width: size,
                              decoration: BoxDecoration(
                                color: themeController.currentTheme.hoverColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.black45,
                              ),
                            )
                          : SizedBox(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
