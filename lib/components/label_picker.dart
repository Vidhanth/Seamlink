import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/services/utils.dart';

class LabelPicker extends StatelessWidget {
  final Function(int) onLabelSelected;
  final List<int> selectedIndices;

  late final SidebarController sidebarController;

  LabelPicker(
      {Key? key, required this.onLabelSelected, required this.selectedIndices})
      : super(key: key) {
    try {
      sidebarController = Get.find<SidebarController>();
    } catch (e) {
      sidebarController = Get.put(SidebarController());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> labelsList = sidebarController.labels;
    return Obx(
      () => SingleChildScrollView(
        padding: EdgeInsets.only(top: 10.0, left: 20, right: 20),
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: List.generate(
            labelsList.length + 1,
            (index) {
              if (index == labelsList.length) {
                return Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: InkWell(
                    onTap: () async {
                      await newLabelDialog(
                        context,
                        'Create new label',
                        'Please enter the name of your new label.',
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: accent.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '+ Create new',
                          style: GoogleFonts.poppins(
                            color: accent.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: () {
                    onLabelSelected.call(index);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: selectedIndices.contains(index)
                          ? accent
                          : Colors.transparent,
                      border: Border.all(color: accent.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        labelsList[index],
                        style: GoogleFonts.poppins(
                          color: selectedIndices.contains(index)
                              ? Colors.white.withOpacity(0.9)
                              : accent.withOpacity(0.6),
                        ),
                      ),
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
