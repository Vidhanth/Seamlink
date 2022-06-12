// ignore_for_file: invalid_use_of_protected_member

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/color_picker.dart';
import 'package:seamlink/components/custom_titlebar.dart';
import 'package:seamlink/components/label_picker.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/NewLinkController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/views/home.dart';

// ignore: must_be_immutable
class NewLink extends StatefulWidget {
  final Link? link;
  final String? sharedText;
  TextEditingController? titleController;
  TextEditingController? linkController;

  final NewLinkController controller = Get.put(NewLinkController());

  NewLink({Key? key, this.link, this.sharedText}) : super(key: key) {
    if (linkController == null) {
      titleController ??= TextEditingController(text: link?.title);
      linkController ??= TextEditingController(text: link?.url ?? sharedText);
      controller.selectedColorIndex.value = link?.colorIndex ?? 0;
      controller.selectedLabelIndex.value += link?.labels ?? [];
      if (link != null) {
        controller.autoTitle(link!.autotitle);
      } else if (sharedText?.isValidLink ?? false) {
        controller.autoTitle(true);
      }
    }
  }

  @override
  State<NewLink> createState() => _NewLinkState();
}

class _NewLinkState extends State<NewLink> {
  Function? refreshAutotitle;

  final ThemeController themeController = Get.find();

  @override
  void dispose() {
    Get.delete<NewLinkController>();
    Future.delayed(10.milliseconds, () {
      Get.find<HomeController>().customMenubarItems([]);
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      10.milliseconds,
      () {
        Get.find<HomeController>().customMenubarItems(
          [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Save',
                  onSelected: () async {
                    await save();
                  },
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyS,
                    meta: true,
                  ),
                ),
                PlatformMenuItem(
                  label: 'Cancel',
                  onSelected: () async {
                    await cancel();
                  },
                  shortcut: new SingleActivator(
                    LogicalKeyboardKey.keyW,
                    meta: true,
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !widget.controller.isSaving.value;
      },
      child: Column(
        children: [
          if (isMacOS) ...[
            CustomTitleBar(
              macStyle: false,
              title: '',
            ),
          ],
          Expanded(
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 25, top: 10, left: 5),
                      child: Row(
                        mainAxisAlignment: isScreenWide(context)
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () async {
                                await hideKeyboard(context);
                                await cancel();
                              },
                              borderRadius: BorderRadius.circular(200),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 60,
                                color: themeController.currentTheme.foreground,
                              ),
                            ),
                          ),
                          Text(
                            widget.link != null
                                ? 'Edit ${noteOrLink(widget.link!.url)}'
                                : 'New note',
                            style: GoogleFonts.poppins(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: themeController.currentTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      textInputAction: TextInputAction.next,
                      scrollPhysics: BouncingScrollPhysics(),
                      controller: widget.titleController,
                      onChanged: (title) {
                        widget.controller.autoTitle(title.trim().isEmpty &&
                            widget.linkController!.text.trim().isValidLink);
                        refreshAutotitle?.call(() {});
                      },
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: themeController.currentTheme.foreground,
                      ),
                      maxLines: 1,
                      cursorColor: themeController.currentTheme.subtext,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'Title',
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: themeController.currentTheme.subtext,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        scrollPhysics: BouncingScrollPhysics(),
                        controller: widget.linkController,
                        onChanged: (newLink) {
                          widget.controller.autoTitle(newLink.isValidLink);
                          refreshAutotitle?.call(() {});
                        },
                        cursorColor: themeController.currentTheme.subtext,
                        autofocus: ((widget.link?.url.isEmpty ?? true) &&
                                (widget.sharedText?.isEmpty ?? true)) ||
                            isDesktop,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: themeController.currentTheme.foreground,
                        ),
                        maxLines: 100,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Type something',
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            color: themeController.currentTheme.subtext,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 25.0),
                        child: StatefulBuilder(builder: (context, setState) {
                          refreshAutotitle = setState;
                          return GestureDetector(
                            onTap: () {
                              if (!widget.controller.autoTitle.value) {
                                if (widget.linkController!.text
                                    .trim()
                                    .isValidLink)
                                  widget.controller.autoTitle(true);
                                else {
                                  showSnackBar("Please enter a valid link",
                                      error: true);
                                }
                              } else {
                                widget.controller.autoTitle(false);
                              }
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: widget.controller.autoTitle.value,
                                  onChanged: (val) {
                                    if (val!) {
                                      if (widget.linkController!.text
                                          .trim()
                                          .isValidLink)
                                        widget.controller.autoTitle(true);
                                      else {
                                        showSnackBar(
                                          "Please enter a valid link",
                                          error: true,
                                        );
                                      }
                                    } else {
                                      widget.controller.autoTitle(false);
                                    }
                                    setState(() {});
                                  },
                                  side: BorderSide(
                                    color:
                                        themeController.currentTheme.foreground,
                                    width: 2,
                                  ),
                                  focusColor:
                                      themeController.currentTheme.focusColor,
                                  hoverColor:
                                      themeController.currentTheme.hoverColor,
                                  checkColor:
                                      themeController.currentTheme.contrastText,
                                  activeColor:
                                      themeController.currentTheme.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                Flexible(
                                  child: AutoSizeText(
                                    'Fetch title from link',
                                    style: GoogleFonts.poppins(
                                      color: themeController.currentTheme.accent
                                          .withOpacity(0.75),
                                      fontSize: 17,
                                    ),
                                    minFontSize: 1,
                                    maxLines: 2,
                                  ),
                                )
                              ],
                            ),
                          );
                        })),
                    Obx(
                      () => LabelPicker(
                        onLabelSelected: (index) {
                          if (!widget.controller.selectedLabelIndex
                              .contains(index)) {
                            widget.controller.selectedLabelIndex.add(index);
                          } else {
                            widget.controller.selectedLabelIndex.remove(index);
                          }
                          widget.controller.selectedLabelIndex.sort();
                        },
                        selectedIndices:
                            widget.controller.selectedLabelIndex.value,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5, bottom: 20, left: 15, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => ColorPicker(
                              onColorSelected: (index) {
                                widget.controller.selectedColorIndex.value =
                                    index;
                              },
                              selectedIndex:
                                  widget.controller.selectedColorIndex.value,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Obx(
                            () => IgnorePointer(
                              ignoring: widget.controller.isSaving.value,
                              child: FloatingActionButton(
                                backgroundColor:
                                    themeController.currentTheme.accent,
                                focusColor: themeController
                                    .currentTheme.contrastText
                                    .withOpacity(0.24),
                                splashColor: themeController
                                    .currentTheme.contrastText
                                    .withOpacity(0.24),
                                hoverColor: themeController
                                    .currentTheme.contrastText
                                    .withOpacity(0.24),
                                child: widget.controller.isSaving.value
                                    ? SpinKitChasingDots(
                                        color: themeController
                                            .currentTheme.contrastText,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.check_rounded,
                                        color: themeController
                                            .currentTheme.contrastText,
                                      ),
                                onPressed: () async {
                                  await hideKeyboard(context);
                                  await save();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> cancel() async {
    if (widget.controller.isSaving.value) return;
    if (widget.sharedText?.isEmpty ?? true) {
      Get.back();
    } else {
      if (isAndroid) {
        if (Navigator.canPop(Get.context!))
          Get.back();
        else
          SystemNavigator.pop();
      } else {
        if (Navigator.canPop(Get.context!))
          Get.back();
        else
          Get.off(() => Home());
      }
    }
  }

  Future<void> save() async {
    if (widget.linkController!.text.trim().isEmpty) {
      showSnackBar("Please enter a note", error: true);
      return;
    }
    widget.controller.isSaving(true);
    String title = widget.titleController!.text.trim();
    if (widget.link != null) {
      if (widget.link!.url == widget.linkController!.text.trim() &&
          widget.link!.title == title &&
          widget.link!.colorIndex ==
              widget.controller.selectedColorIndex.value &&
          widget.link!.autotitle == widget.controller.autoTitle.value &&
          listEquals(
              widget.link!.labels, widget.controller.selectedLabelIndex)) {
        await hideKeyboard(Get.context!);
        Get.back();
        return;
      }
    }
    bool result = await saveLink(
      Get.context!,
      widget.linkController!.text.trim(),
      widget.controller.autoTitle.value ? '' : title,
      widget.controller.selectedColorIndex.value,
      widget.controller.selectedLabelIndex,
      widget.controller.autoTitle.value,
      uid: widget.link?.uid,
    );
    if (result) {
      if (widget.sharedText?.isEmpty ?? true) {
        Get.back();
      } else {
        if (isAndroid) {
          if (Navigator.canPop(Get.context!))
            Get.back();
          else
            SystemNavigator.pop();
        } else {
          if (Navigator.canPop(Get.context!))
            Get.back();
          else
            Get.off(() => Home());
        }
      }
    } else {
      widget.controller.isSaving(false);
    }
  }
}
