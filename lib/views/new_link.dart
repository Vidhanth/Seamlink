import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menubar/menubar.dart';
import 'package:seamlink/components/color_picker.dart';
import 'package:seamlink/components/custom_titlebar.dart';
import 'package:seamlink/components/label_picker.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/NewLinkController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/views/home.dart';

// ignore: must_be_immutable
class NewLink extends StatelessWidget {
  final Link? link;
  final String? sharedText;
  Function? refreshAutotitle;

  final NewLinkController controller = NewLinkController();
  TextEditingController? titleController;
  TextEditingController? linkController;

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
  Widget build(BuildContext context) {
    updateMenubar();
    return WillPopScope(
      onWillPop: () async {
        return !controller.isSaving.value;
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
                                await cancel();
                              },
                              borderRadius: BorderRadius.circular(200),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 60,
                              ),
                            ),
                          ),
                          Text(
                            link != null
                                ? 'Edit ${noteOrLink(link!.url)}'
                                : 'New note',
                            style: GoogleFonts.poppins(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      scrollPhysics: BouncingScrollPhysics(),
                      controller: titleController,
                      onChanged: (title) {
                        controller.autoTitle(title.trim().isEmpty &&
                            linkController!.text.trim().isValidLink);
                        refreshAutotitle?.call(() {});
                      },
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      maxLines: 1,
                      cursorColor: accent,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'Title',
                        hintStyle:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        scrollPhysics: BouncingScrollPhysics(),
                        controller: linkController,
                        onChanged: (newLink) {
                          controller.autoTitle(newLink.isValidLink);
                          refreshAutotitle?.call(() {});
                        },
                        cursorColor: accent,
                        autofocus: ((link?.url.isEmpty ?? true) &&
                                (sharedText?.isEmpty ?? true)) ||
                            isDesktop,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
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
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 25.0),
                        child: StatefulBuilder(builder: (context, setState) {
                          refreshAutotitle = setState;
                          return GestureDetector(
                            onTap: () {
                              if (!controller.autoTitle.value) {
                                if (linkController!.text.trim().isValidLink)
                                  controller.autoTitle(true);
                                else {
                                  showSnackBar(
                                      context, "Please enter a valid link",
                                      error: true);
                                }
                              } else {
                                controller.autoTitle(false);
                              }
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: controller.autoTitle.value,
                                  onChanged: (val) {
                                    if (val!) {
                                      if (linkController!.text
                                          .trim()
                                          .isValidLink)
                                        controller.autoTitle(true);
                                      else {
                                        showSnackBar(context,
                                            "Please enter a valid link",
                                            error: true);
                                      }
                                    } else {
                                      controller.autoTitle(false);
                                    }
                                    setState(() {});
                                  },
                                  activeColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                Flexible(
                                  child: AutoSizeText(
                                    'Fetch title from link',
                                    style: GoogleFonts.poppins(
                                      color: accent.withOpacity(0.75),
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
                          if (!controller.selectedLabelIndex.contains(index)) {
                            controller.selectedLabelIndex.add(index);
                          } else {
                            controller.selectedLabelIndex.remove(index);
                          }
                          controller.selectedLabelIndex.sort();
                        },
                        selectedIndices: controller.selectedLabelIndex.value,
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
                                controller.selectedColorIndex.value = index;
                              },
                              selectedIndex:
                                  controller.selectedColorIndex.value,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Obx(
                            () => IgnorePointer(
                              ignoring: controller.isSaving.value,
                              child: FloatingActionButton(
                                backgroundColor: accent,
                                focusColor: Colors.white24,
                                hoverColor: Colors.white24,
                                child: controller.isSaving.value
                                    ? SpinKitChasingDots(
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.check_rounded,
                                      ),
                                onPressed: () async {
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

  void updateMenubar() {
    setApplicationMenu([
      Submenu(
        label: "Actions",
        children: [
          MenuItem(
            label: 'Save',
            enabled: true,
            onClicked: () async {
              await save();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.keyS,
              LogicalKeyboardKey.meta,
            }),
          ),
          MenuItem(
            label: 'Cancel',
            enabled: true,
            onClicked: () async {
              await cancel();
            },
            shortcut: LogicalKeySet.fromSet({
              LogicalKeyboardKey.keyW,
              LogicalKeyboardKey.meta,
            }),
          ),
        ],
      ),
    ]);
  }

  Future<void> cancel() async {
    if (controller.isSaving.value) return;
    Future.delayed(1.seconds, () {
      Get.find<HomeController>().updateMenubar();
    });
    if (sharedText?.isEmpty ?? true) {
      await hideKeyboard(Get.context);
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
    if (linkController!.text.trim().isEmpty) {
      showSnackBar(Get.context!, "Please enter a note", error: true);
      return;
    }
    controller.isSaving(true);
    String title = titleController!.text.trim();
    if (link != null) {
      if (link!.url == linkController!.text.trim() &&
          link!.title == title &&
          link!.colorIndex == controller.selectedColorIndex.value &&
          link!.autotitle == controller.autoTitle.value &&
          listEquals(link!.labels, controller.selectedLabelIndex)) {
        await hideKeyboard(Get.context!);
        Future.delayed(1.seconds, () {
          Get.find<HomeController>().updateMenubar();
        });
        Get.back();
        return;
      }
    }
    bool result = await saveLink(
      Get.context!,
      linkController!.text.trim(),
      controller.autoTitle.value ? '' : title,
      controller.selectedColorIndex.value,
      controller.selectedLabelIndex,
      controller.autoTitle.value,
      uid: link?.uid,
    );
    if (result) {
      Future.delayed(1.seconds, () {
        Get.find<HomeController>().updateMenubar();
      });
      if (sharedText?.isEmpty ?? true) {
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
      controller.isSaving(false);
    }
  }
}
