import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  final Function onTap;
  final Color color;
  final double? radius;
  final Color? textColor;
  final Color? splashColor;
  final Color? hoverColor;
  final Color? focusColor;
  final Color? borderColor;
  final double? borderWidth;
  final String text;
  final double? textSize;
  final EdgeInsets? padding;

  const Button({
    Key? key,
    required this.onTap,
    required this.color,
    this.radius,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    required this.text,
    this.textSize,
    this.padding,
    this.splashColor,
    this.hoverColor,
    this.focusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 20),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth ?? 0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: splashColor ?? Colors.white10,
          hoverColor: hoverColor ?? Colors.white24,
          focusColor: focusColor ?? Colors.white24,
          onTap: () {
            onTap.call();
          },
          borderRadius: BorderRadius.circular(radius ?? 20),
          child: Container(
            padding: padding ?? EdgeInsets.zero,
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: textColor ?? Colors.white,
                  fontSize: textSize ?? 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
