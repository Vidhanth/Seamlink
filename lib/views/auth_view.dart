import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/button.dart';
import 'package:seamlink/components/input_field.dart';
import 'package:seamlink/constants/colors.dart';
import 'package:seamlink/controllers/HomeController.dart';
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
      backgroundColor: primaryBg,
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
                        color: accent,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Hang on",
                        style: GoogleFonts.poppins(),
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
                              fontSize: (width * 0.1).clamp(10.0, 50.0)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Please enter your username\nto access your links.",
                          style: GoogleFonts.poppins(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              (isMobile ? 0.8 : 0.45),
                          child: InputField(
                            radius: 25,
                            margin: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 0,
                            ),
                            controller: userController,
                            hint: 'Username',
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
                          width: MediaQuery.of(context).size.width *
                              (isMobile ? 0.8 : 0.45),
                          child: Button(
                            padding: EdgeInsets.symmetric(vertical: 17.5),
                            radius: 25,
                            text: "Take me in!",
                            onTap: () async {
                              await submitUsername();
                            },
                            color: accent,
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
        context,
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
        context,
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
        showSnackBar(context, "This user doesn't exist.", error: true);
        setState(() {
          loading = false;
        });
        userFocus.requestFocus();
      }
    }
  }
}
