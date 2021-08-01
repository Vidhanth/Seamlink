import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:seamlink/components/label_tile.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/constants/strings.dart';
import 'package:seamlink/services/utils.dart';

class Sidebar extends StatelessWidget {
  Sidebar({Key? key}) : super(key: key);

  Size size = Size(0, 0);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 200)],
        ),
        width: (size.width * 0.2).clamp(200, 400),
        height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMacOS)
              Container(
                height: 30,
                width:
                    (MediaQuery.of(context).size.width * 0.2).clamp(200, 400),
                child: MoveWindow(),
              ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(300),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Seamlink',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
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
                  Text(
                    "EDIT",
                    style: GoogleFonts.poppins(color: Colors.black54),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: defaultLabels.length + 1,
                itemBuilder: (context, index) {
                  if (index == defaultLabels.length)
                    return LabelTile(
                      label: 'Create new',
                      isSelected: index == 0,
                      icon: LineIcons.plus,
                      onTap: () {},
                    );
                  return LabelTile(
                    label: defaultLabels[index],
                    isSelected: index == 0,
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
