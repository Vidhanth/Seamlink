import 'package:flutter/material.dart';
import 'package:seamlink/constants/colors.dart';

class ColorPicker extends StatelessWidget {
  final Function onColorSelected;
  final int selectedIndex;

  const ColorPicker(
      {Key? key, required this.onColorSelected, required this.selectedIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        colorsList.length,
        (index) {
          return InkWell(
            onTap: () {
              onColorSelected.call(index);
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              margin: EdgeInsets.all(5),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: colorsList[index],
                shape: BoxShape.circle,
              ),
              child: index == selectedIndex
                  ? Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.black45,
                      ),
                    )
                  : SizedBox(),
            ),
          );
        },
      ),
    );
  }
}
