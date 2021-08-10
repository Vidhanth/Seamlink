import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/label_tile.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/constants/enum.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/services/utils.dart';

// ignore: must_be_immutable
class Sidebar extends StatelessWidget {
  Sidebar({Key? key}) : super(key: key);

  Size size = Size(0, 0);

  final SidebarController controller = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (Get.find<UserController>().username.isEmpty) return SizedBox();
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isMobile ? primaryBg : primarySidebarBg,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 200)],
        ),
        width: isDesktop
            ? (size.width * 0.2).clamp(200, 400)
            : (size.width * 0.75),
        height: size.height,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMacOS)
                Container(
                  height: 30,
                  width: isDesktop
                      ? (size.width * 0.2).clamp(200, 400)
                      : (size.width * 0.75),
                  child: MoveWindow(),
                ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: isDesktop ? 40 : 45,
                      width: isDesktop ? 40 : 45,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Seamlink',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 20 : 25,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                child: Divider(),
              ),
              Obx(() => Column(
                    children: [
                      LabelTile(
                        label: 'All',
                        isSelected:
                            controller.selectedType.value == NoteType.ALL,
                        onTap: () {
                          controller.selectedType(NoteType.ALL);
                          if (isMobile) {
                            Get.find<HomeController>().showSidebar.toggle();
                          }
                        },
                        icon: Icons.notes_sharp,
                      ),
                      LabelTile(
                        label: 'Notes',
                        isSelected:
                            controller.selectedType.value == NoteType.NOTE,
                        onTap: () {
                          controller.selectedType(NoteType.NOTE);
                          if (isMobile) {
                            Get.find<HomeController>().showSidebar.toggle();
                          }
                        },
                        icon: LineIcons.stickyNote,
                      ),
                      LabelTile(
                        label: 'Links',
                        isSelected:
                            controller.selectedType.value == NoteType.LINK,
                        onTap: () {
                          controller.selectedType(NoteType.LINK);
                          if (isMobile) {
                            Get.find<HomeController>().showSidebar.toggle();
                          }
                        },
                        icon: LineIcons.link,
                      ),
                    ],
                  )),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "L A B E L S",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: Colors.black87),
                      textAlign: TextAlign.start,
                    ),
                    InkWell(
                      onTap: () async {
                        controller.editMode.toggle();
                      },
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Obx(
                          () => Text(
                            controller.editMode.value ? "DONE" : "EDIT",
                            style: GoogleFonts.poppins(color: Colors.black54),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Obx(() {
                ScrollController scrollController = ScrollController();
                return Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    isAlwaysShown: true,
                    child: ListView.builder(
                      controller: scrollController,
                      physics: BouncingScrollPhysics(),
                      itemCount: controller.labels.length + 3,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Obx(() => LabelTile(
                                label: 'All',
                                isSelected: controller.labelIndex.value == -2,
                                icon: LineIcons.tags,
                                onTap: () {
                                  controller.labelIndex(-2);
                                  if (isMobile) {
                                    Get.find<HomeController>()
                                        .showSidebar
                                        .toggle();
                                  }
                                },
                              ));
                        }
                        if (index == 1) {
                          return Obx(() => LabelTile(
                                label: 'Untagged',
                                isSelected: controller.labelIndex.value == -1,
                                icon: LineIcons.tag,
                                iconSecondary: Icons.close_outlined,
                                onTap: () {
                                  controller.labelIndex(-1);
                                  if (isMobile) {
                                    Get.find<HomeController>()
                                        .showSidebar
                                        .toggle();
                                  }
                                },
                              ));
                        }
                        index -= 2;
                        if (index == controller.labels.length)
                          return LabelTile(
                            label: 'Create new',
                            isSelected: false,
                            icon: LineIcons.plus,
                            onTap: () async {
                              await newLabelDialog(
                                context,
                                'Create new label',
                                'Please enter the name of your new label.',
                              );
                            },
                          );
                        return Obx(() => LabelTile(
                              editing: controller.editMode.value,
                              label: controller.labels[index],
                              isSelected: index == controller.labelIndex.value,
                              onLongPress: () async {
                                await editLabelDialog(
                                  context,
                                  index,
                                  "Edit label ",
                                  "Enter a new label",
                                  controller.labels[index],
                                );
                              },
                              onTap: () async {
                                if (controller.editMode.value) {
                                  await editLabelDialog(
                                    context,
                                    index,
                                    "Edit label ",
                                    "Enter a new label",
                                    controller.labels[index],
                                  );
                                } else {
                                  controller.labelIndex(index);
                                  if (isMobile) {
                                    Get.find<HomeController>()
                                        .showSidebar
                                        .toggle();
                                  }
                                }
                              },
                            ));
                      },
                    ),
                  ),
                );
              }),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      LineIcons.userCircle,
                      size: 40,
                    ),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' ${Get.find<UserController>().username} ',
                          style: GoogleFonts.poppins(
                            // fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await logout();
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: Text(
                            ' Logout ',
                            style: GoogleFonts.poppins(
                              // fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
