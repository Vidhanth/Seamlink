import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/num_extensions.dart';
import 'package:seamlink/controllers/ThemeController.dart';

class Wipe extends StatefulWidget {
  final Widget child;
  final Function(Function enter, Function exit)? function;
  const Wipe({Key? key, required this.child, this.function}) : super(key: key);

  @override
  _WipeState createState() => _WipeState();
}

class _WipeState extends State<Wipe> {
  bool run = false;

  Color backgroundColor = ThemeController.lightTheme.backgroundColor;
  Color iconColor = ThemeController.lightTheme.foreground;

  runEnterAnimation() async {
    backgroundColor = ThemeController.isDark ? ThemeController.lightTheme.backgroundColor : ThemeController.darkTheme.backgroundColor;
    iconColor = ThemeController.isDark ? ThemeController.lightTheme.foreground : ThemeController.darkTheme.foreground;
    setState(() {
      run = true;
    });
    await Future.delayed(800.milliseconds);
  }

  runExitAnimation() async {
    await Future.delayed(200.milliseconds);
    setState(() {
      run = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.function?.call(runEnterAnimation, runExitAnimation);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: Align(
              alignment: run ? Alignment.centerLeft : Alignment.centerRight,
              child: LayoutBuilder(builder: (context, constraints) {
                return AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 700),
                  color: backgroundColor,
                  width: run ? constraints.maxWidth : 0,
                  height: constraints.maxHeight,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: 300.milliseconds,
                      child: run
                          ? FadeInUp(
                              delay: 0.milliseconds,
                              child: Icon(
                                ThemeController.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                color: iconColor,
                                size: 100,
                              ),
                            )
                          : SizedBox(),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
