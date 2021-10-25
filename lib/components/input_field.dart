import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:seamlink/controllers/ThemeController.dart';

class InputField extends StatelessWidget {
  final Color bgColor;
  final double radius;
  final String hint;
  final TextEditingController? controller;
  final String initialText;
  final Color cursorColor;
  final bool showCursor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final List<TextInputFormatter> inputFormatters;
  final Function(String)? onChanged;
  final TextStyle style;
  final TextStyle hintStyle;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool error;
  final Widget? suffix;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final Function? onSubmitted;
  final bool? autofocus;

  InputField({
    this.bgColor = Colors.black12,
    this.radius = 20,
    this.hint = "Hint",
    this.controller,
    this.initialText = "",
    this.cursorColor = Colors.black,
    this.showCursor = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.margin = EdgeInsets.zero,
    this.inputFormatters = const [],
    this.onChanged,
    this.style = const TextStyle(
      fontSize: 20,
    ),
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.error = false,
    this.suffix,
    this.prefixIcon,
    this.focusNode,
    this.onSubmitted,
    this.autofocus,
    this.hintStyle = const TextStyle(),
  });

  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Theme(
              data: Theme.of(context)
                  .copyWith(primaryColor: themeController.currentTheme.accent),
              child: TextField(
                autofocus: autofocus ?? false,
                focusNode: focusNode ?? FocusNode(),
                showCursor: showCursor,
                onSubmitted: (string) {
                  onSubmitted?.call(string);
                },
                inputFormatters: inputFormatters,
                controller:
                    controller ?? TextEditingController(text: initialText),
                obscureText: obscureText,
                keyboardType: keyboardType,
                style: style,
                onChanged: (string) {
                  onChanged?.call(string);
                },
                cursorColor: cursorColor,
                decoration: InputDecoration(
                  prefixIcon: prefixIcon,
                  filled: true,
                  contentPadding: padding,
                  fillColor: bgColor,
                  hintText: hint,
                  hintStyle: hintStyle,
                  hoverColor: themeController.currentTheme.hoverColor,
                  focusColor: themeController.currentTheme.focusColor,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: error ? Colors.red : Colors.transparent,
                      width: 0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: error ? Colors.red : Colors.transparent,
                      width: 0,
                    ),
                  ),
                ),
              ),
            ),
            suffix == null
                ? SizedBox()
                : Positioned(
                    right: padding.right,
                    top: 0,
                    bottom: 0,
                    child: suffix!,
                  )
          ],
        ),
      ),
    );
  }
}
