import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/button.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/services/utils.dart';

class BottomDialog extends StatelessWidget {
  const BottomDialog({
    Key? key,
    required this.onConfirm,
    required this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    required this.onCancel,
  }) : super(key: key);

  final Function onConfirm;
  final Function onCancel;
  final String title;
  final String? message;
  final String? confirmText;
  final String? cancelText;

  @override
  Widget build(BuildContext context) {
    if (isScreenWide(context) || (Get.isDialogOpen ?? false)) {
      return AlertDialog(
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
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (message != null) ...[
          Text(
            message!,
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontWeight: FontWeight.normal,
              fontSize: 20,
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
                color: accent.withOpacity(0.15),
                textColor: accent.withOpacity(0.7),
                text: "NO",
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: Button(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                onTap: () {
                  onConfirm.call();
                },
                color: accent,
                text: 'YES',
              ),
            ),
          ],
        )
      ],
    );
  }
}
