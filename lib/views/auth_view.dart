import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/button.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';
import 'package:seamlink/services/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthView extends StatefulWidget {
  final state;

  AuthView({
    Key? key,
    this.state,
  }) : super(key: key);

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  TextEditingController userController = TextEditingController();
  final ThemeController themeController = Get.find();

  FocusNode userFocus = FocusNode();
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: themeController.currentTheme.backgroundColor,
      body: Builder(
        builder: (context) => Center(
          child: AnimatedSwitcher(
            duration: Duration(
              milliseconds: 400,
            ),
            child: loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitChasingDots(
                        size: 50,
                        color: themeController.currentTheme.accent,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Hang on",
                        style: GoogleFonts.poppins(
                          color: themeController.currentTheme.foreground,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  )
                : Container(
                    padding: EdgeInsets.all(width * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hey there!",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: (width * 0.1).clamp(10.0, 50.0),
                            color: themeController.currentTheme.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Please enter your username\nto access your links.",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: themeController.currentTheme.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * (isMobile ? 0.8 : 0.45),
                          child: InputField(
                            bgColor: themeController.currentTheme.mutedBg,
                            radius: 25,
                            cursorColor: themeController.currentTheme.subtext,
                            margin: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 0,
                            ),
                            controller: userController,
                            hint: 'Username',
                            hintStyle: GoogleFonts.poppins(color: themeController.currentTheme.subtext),
                            style: GoogleFonts.poppins(color: themeController.currentTheme.foreground),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            focusNode: userFocus,
                            onSubmitted: (s) async {
                              await submitUsername();
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * (isMobile ? 0.8 : 0.45),
                          child: Button(
                            padding: EdgeInsets.symmetric(vertical: 17.5),
                            radius: 25,
                            text: "Take me in!",
                            splashColor: themeController.currentTheme.contrastText.withOpacity(0.12),
                            hoverColor: themeController.currentTheme.contrastText.withOpacity(0.12),
                            textColor: themeController.currentTheme.contrastText,
                            onTap: () async {
                              await submitUsername();
                            },
                            color: themeController.currentTheme.accent,
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<bool?> checkUsername(String user) async {
    bool valid = false;

    Result result = await Client.doesUserExist(user);
    if (result.success) {
      valid = result.message;
    } else {
      setState(() {
        loading = false;
      });
      showSnackBar(
        "Please check your internet connection.",
        error: true,
      );
      userFocus.requestFocus();
      return null;
    }
    return valid;
  }

  submitUsername() async {
    userFocus.unfocus();
    String user = userController.text.toLowerCase().trim();
    if (user.isEmpty) {
      showSnackBar(
        "Please enter a username.",
        error: true,
      );
      return;
    }

    setState(() {
      loading = true;
    });
    bool? isUserValid = await checkUsername(user);
    if (isUserValid != null) {
      if (isUserValid) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', user);
        Get.find<UserController>().username(user);
        Get.find<HomeController>().refreshLinks();
      } else {
        showSnackBar("This user doesn't exist.", error: true);
        setState(() {
          loading = false;
        });
        userFocus.requestFocus();
      }
    }
  }
}
