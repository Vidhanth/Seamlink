import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class LabelTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final Function onTap;

  const LabelTile({
    Key? key,
    required this.label,
    required this.isSelected,
    this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
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
            Icon(icon ?? LineIcons.tag),
            SizedBox(
              width: 5,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ),
    );
  }
}
