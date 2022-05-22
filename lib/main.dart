import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:seamlink/components/custom_titlebar.dart';
import 'package:seamlink/components/sidebar.dart';
import 'package:seamlink/components/wipe.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/services/navigation.dart';
import 'package:seamlink/services/utils.dart';
import 'package:seamlink/views/home.dart';
import 'package:seamlink/views/new_link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializePrefs();

  if (isDesktop) {
    window_size.getWindowInfo().then((window) {
      final screen = window.screen;
      if (screen != null) {
        final screenFrame = screen.visibleFrame;
        final width = screenFrame.width;
        final height = screenFrame.height;
        doWhenWindowReady(() {
          appWindow.title = 'Seamlink Desktop';
          final initialSize = Size(0.5 * width, 0.7 * height);
          appWindow.size = initialSize;
          appWindow.alignment = Alignment.center;
          appWindow.minSize = initialSize;
          appWindow.show();
        });
      }
    });
  }

  if (isMobile) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  }
  runApp(MainActivity());
}

Future<void> initializePrefs() async {
  UserController _userController = Get.put(UserController());
  Get.put(SidebarController());
  HomeController _homeController = Get.put(HomeController());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String username = prefs.getString('username') ?? '';
  _homeController.ascending = prefs.getBool('ascending') ?? false;
  _homeController.sortBy = prefs.getInt('sort_by') ?? 0;
  ThemeController.isDark = prefs.getBool('dark_mode') ?? false;
  ThemeController.mode = (prefs.getBool('auto_mode') ?? false)
      ? Mode.SYSTEM
      : ThemeController.isDark
          ? Mode.DARK
          : Mode.LIGHT;
  if (ThemeController.isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  } else {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }
  if (username.isNotEmpty) {
    _userController.username(username);
    _homeController.refreshLinks();
  }
}

class MainActivity extends StatefulWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity>
    with WidgetsBindingObserver {
  StreamSubscription? _sharedTextSub;

  Future<String> getInitialSharedText() async {
    if (isDesktop) return '';
    String sharedText = (await ReceiveSharingIntent.getInitialText()) ?? '';
    if (Get.find<UserController>().username.value.isEmpty &&
        sharedText.isNotEmpty) {
      Get.find<HomeController>().pendingSharedLink = sharedText;
      showSnackBar('Please log in first', error: true);
      return '';
    }
    return (sharedText);
  }

  @override
  void didChangePlatformBrightness() {
    setAutoTheme();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (isMobile) {
      _sharedTextSub =
          ReceiveSharingIntent.getTextStream().listen((String value) {
        if (Get.find<UserController>().username.value.isEmpty) {
          Get.find<HomeController>().pendingSharedLink = value;
          showSnackBar('Please log in first', error: true);
        } else {
          Navigate.to(
            page: NewLink(
              sharedText: value,
            ),
          );
        }
      }, onError: (err) {
        print("getLinkStream error: $err");
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _sharedTextSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wipe(
      function: (enter, exit) {
        ThemeController.enterWipe = enter;
        ThemeController.exitWipe = exit;
      },
      child: GetBuilder<ThemeController>(
        init: ThemeController(),
        initState: (_) {},
        builder: (themeController) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              canvasColor: themeController.currentTheme.backgroundColor,
              backgroundColor: themeController.currentTheme.backgroundColor,
              textTheme: GoogleFonts.poppinsTextTheme(),
              brightness:
                  ThemeController.isDark ? Brightness.dark : Brightness.light,
            ),
            color: themeController.currentTheme.backgroundColor,
            home: Builder(
              builder: (context) {
                return Row(
                  children: [
                    isDesktop
                        ? Obx(() {
                            return Get.find<UserController>()
                                    .username
                                    .isNotEmpty
                                ? Sidebar()
                                : SizedBox();
                          })
                        : SizedBox(),
                    Expanded(
                      child: Column(
                        children: [
                          if (isMacOS) ...[
                            Obx(() => CustomTitleBar(
                                  macStyle: Get.find<UserController>()
                                      .username
                                      .isNotEmpty,
                                  title:
                                      Get.find<UserController>().username.value,
                                ))
                          ],
                          Expanded(
                            child: FutureBuilder(
                              future: getInitialSharedText(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return SizedBox();
                                return snapshot.data.toString().isEmpty
                                    ? isDesktop
                                        ? Home()
                                        : Stack(
                                            children: [
                                              Obx(() => AnimatedPositioned(
                                                    duration: 400.milliseconds,
                                                    curve: Curves.fastOutSlowIn,
                                                    left: Get.find<
                                                                HomeController>()
                                                            .showSidebar
                                                            .isFalse
                                                        ? context.mediaQuerySize
                                                                .width *
                                                            -0.25
                                                        : 0,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Sidebar(),
                                                    ),
                                                  )),
                                              Obx(() => AnimatedPositioned(
                                                    curve: Curves.fastOutSlowIn,
                                                    left: Get.find<
                                                                HomeController>()
                                                            .showSidebar
                                                            .isTrue
                                                        ? context.mediaQuerySize
                                                                .width *
                                                            0.75
                                                        : 0,
                                                    duration: 500.milliseconds,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 20,
                                                              color: Colors
                                                                  .black12,
                                                            ),
                                                          ]),
                                                      height: context
                                                          .mediaQuerySize
                                                          .height,
                                                      width: context
                                                          .mediaQuerySize.width,
                                                      child: Stack(
                                                        children: [
                                                          Home(),
                                                          if (Get.find<
                                                                  HomeController>()
                                                              .showSidebar
                                                              .isTrue)
                                                            Positioned.fill(
                                                              child: Container(
                                                                color: Colors
                                                                    .transparent,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Get.find<
                                                                            HomeController>()
                                                                        .toggleSidebar();
                                                                  },
                                                                  onHorizontalDragUpdate:
                                                                      (_) {
                                                                    Get.find<
                                                                            HomeController>()
                                                                        .toggleSidebar();
                                                                  },
                                                                ),
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          )
                                    : NewLink(
                                        sharedText: snapshot.data.toString(),
                                      );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void setAutoTheme() {
    if (ThemeController.isAuto) {
      if (WidgetsBinding.instance.window.platformBrightness ==
          Brightness.dark) {
        if (!ThemeController.isDark) Get.find<ThemeController>().setDark();
      } else {
        if (ThemeController.isDark) Get.find<ThemeController>().setLight();
      }
    }
  }
}
