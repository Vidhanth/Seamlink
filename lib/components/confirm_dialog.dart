import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/button.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/services/utils.dart';

// ignore: must_be_immutable
class BottomDialog extends StatelessWidget {
  BottomDialog({
    Key? key,
    this.onConfirm,
    required this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.showTextField = false,
    this.onSubmitted,
    this.hint,
    required this.onCancel,
    this.onOptional,
    this.optionalText,
  }) : super(key: key) {
    if (onSubmitted == null) {
      onSubmitted = (controller) {};
    } else {
      _textController = TextEditingController();
    }
    onConfirm ??= () {
      Get.back(result: true);
    };
  }

  Function? onConfirm;
  final Function onCancel;
  final Function? onOptional;
  final String? optionalText;
  final String title;
  final String? message;
  final String? confirmText;
  final String? cancelText;
  final bool? showTextField;
  final String? hint;
  Function(TextEditingController)? onSubmitted;

  late TextEditingController? _textController;

  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (isScreenWide(context) || (Get.isDialogOpen ?? false)) {
      return AlertDialog(
        backgroundColor: themeController.currentTheme.backgroundColor,
        contentPadding: EdgeInsets.all(18),
        content: Container(
          width: (MediaQuery.of(context).size.width * 0.4).clamp(300, 500),
          child: _buildDialog(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      );
    }

    return BottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      onClosing: () {},
      enableDrag: isDesktop,
      builder: (context) {
        return SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: _buildDialog(),
            ),
          ),
        );
      },
    );
  }

  Column _buildDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: themeController.currentTheme.foreground,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (message != null) ...[
          Text(
            message!,
            style: GoogleFonts.poppins(
              color: themeController.currentTheme.subtext,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
        if (showTextField!) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: InputField(
              cursorColor: themeController.currentTheme.subtext,
              bgColor: themeController.currentTheme.mutedBg,
              controller: _textController,
              onSubmitted: (_) {
                onSubmitted!.call(_textController!);
              },
              autofocus: true,
              hint: hint ?? 'Label',
              hintStyle: GoogleFonts.poppins(
                color: themeController.currentTheme.subtext,
              ),
              style: GoogleFonts.poppins(
                color: themeController.currentTheme.foreground,
              ),
              radius: 20,
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
        Row(
          children: [
            Flexible(
              child: Button(
                onTap: () {
                  onCancel.call();
                },
                color: themeController.currentTheme.accent.withOpacity(0.15),
                splashColor: themeController.currentTheme.splashColor,
                hoverColor: themeController.currentTheme.hoverColor,
                focusColor: themeController.currentTheme.focusColor,
                textColor: themeController.currentTheme.accent.withOpacity(0.7),
                text: cancelText ?? "NO",
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            if (optionalText != null && onOptional != null) ...[
              Flexible(
                child: Button(
                  onTap: () {
                    onOptional!.call();
                  },
                  color: themeController.currentTheme.accent.withOpacity(0.15),
                  splashColor: themeController.currentTheme.splashColor,
                  hoverColor: themeController.currentTheme.hoverColor,
                  focusColor: themeController.currentTheme.focusColor,
                  textColor: themeController.currentTheme.accent.withOpacity(0.7),
                  text: optionalText!,
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
            Flexible(
              child: Button(
                splashColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                hoverColor: themeController.currentTheme.contrastText.withOpacity(0.24),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                onTap: () {
                  if (showTextField!)
                    onSubmitted!.call(_textController!);
                  else
                    onConfirm!.call();
                },
                color: themeController.currentTheme.accent,
                text: confirmText ?? 'YES',
                textColor: themeController.currentTheme.contrastText,
              ),
            ),
          ],
        )
      ],
    );
  }
}
