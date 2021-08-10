import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class LabelTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final IconData? iconSecondary;
  final Function onTap;
  final Function? onLongPress;
  final bool? editing;

  const LabelTile({
    Key? key,
    required this.label,
    required this.isSelected,
    this.icon,
    this.iconSecondary,
    required this.onTap,
    this.onLongPress,
    this.editing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      // hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onTap.call();
      },
      onLongPress: () {
        onLongPress?.call();
      },
      child: GestureDetector(
        onSecondaryTap: () {
          onLongPress?.call();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black12 : Colors.transparent,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Icon(icon ?? LineIcons.tag),
                  if (iconSecondary != null)
                    Icon(
                      iconSecondary!,
                      size: 10,
                    ),
                ],
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                label,
                style: GoogleFonts.poppins(),
              ),
              Spacer(),
              if (editing ?? false) FadeIn(child: Icon(LineIcons.pen)),
            ],
          ),
        ),
      ),
    );
  }
}
