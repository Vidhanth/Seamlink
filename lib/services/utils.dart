// ignore_for_file: invalid_use_of_protected_member

import 'dart:io' hide Link;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/confirm_dialog.dart';
import 'package:seamlink/components/link_details.dart';
import 'package:seamlink/components/link_options.dart';
import 'package:seamlink/components/sorting_menu.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/controllers/SidebarController.dart';
import 'package:seamlink/controllers/ThemeController.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';
import 'package:seamlink/services/parsers/reddit_data.dart';
import 'package:seamlink/services/parsers/url_parser.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/services/parsers/youtube_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

String noteOrLink(String url) {
  return url.isValidLink ? "link" : "note";
}

Future<String> getDataFromApi(String url) async {
  var request = http.Request(
      'GET',
      Uri.parse(
        url,
      ));

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    return await response.stream.bytesToString();
  } else {
    throw Exception();
  }
}

Future<void> logout() async {
  while (Navigator.canPop(Get.context!)) {
    Navigator.pop(Get.context!);
  }
  await SharedPreferences.getInstance()
    ..remove('username');
  Get.find<UserController>().reset();
  Get.find<SidebarController>().reset();
  Get.find<HomeController>().reset();
}

void showLinkOptions(context, Link link) {
  if (isScreenWide(context)) {
    Get.dialog(LinkOptions(link: link));
  } else {
    Get.bottomSheet(LinkOptions(link: link));
  }
}

void showSortingMenu(context) {
  if (isScreenWide(context)) {
    Get.dialog(SortingMenu());
  } else {
    Get.bottomSheet(SortingMenu());
  }
}

void showLinkDetails(context, Link link) {
  if (isScreenWide(context)) {
    Get.dialog(LinkDetails(link: link));
  } else {
    Get.bottomSheet(LinkDetails(link: link));
  }
}

Future<bool?> confirmDialog(
  context,
  title,
  message,
) async {
  if (isScreenWide(context))
    return await Get.dialog(
      BottomDialog(
        onCancel: () {
          Get.back(result: false);
        },
        onConfirm: () {
          Get.back(result: true);
        },
        title: title,
        message: message,
      ),
      useSafeArea: true,
    );

  return await Get.bottomSheet(
    BottomDialog(
      onCancel: () {
        Get.back(result: false);
      },
      onConfirm: () {
        Get.back(result: true);
      },
      title: title,
      message: message,
    ),
    isScrollControlled: true,
  );
}

Future<bool?> deleteLabel(
  context,
  int index,
) async {
  bool delete = await confirmDialog(
        context,
        "Delete label?",
        "Are you sure you want to delete this label? Your notes will not be deleted.",
      ) ??
      false;
  if (delete) {
    HomeController homeController = Get.find();
    SidebarController sidebarController = Get.find();
    UserController userController = Get.find();

    var requestData = [];

    homeController.linksList.forEach((link) {
      bool update = false;
      if (link.labels.contains(index)) {
        update = true;
        int linkIndex = link.labels.indexOf(index);
        link.labels.remove(index);
        for (int i = linkIndex; i < link.labels.length; i++) {
          link.labels[i]--;
        }
      } else {
        int linkIndex = link.labels.length;

        for (int i = 0; i < link.labels.length; i++) {
          if (link.labels[i] > index) {
            update = true;
            linkIndex = link.labels.indexOf(link.labels[i]);
            break;
          }
        }

        for (int i = linkIndex; i < link.labels.length; i++) {
          link.labels[i]--;
        }
      }
      link.labels.sort();
      if (update)
        requestData.add({
          "uid": link.uid,
          "url": link.url,
          "title": link.autotitle ? "" : link.title,
          "color": link.colorIndex,
          "labels": link.labels,
          "user": link.user,
          "autotitle": link.autotitle,
        });
    });

    Result result = await Client.updateLinks(requestData);
    if (result.success) {
      if (index == sidebarController.labels.length - 1) {
        if (sidebarController.labelIndex.value == index) {
          sidebarController.labelIndex.value--;
        }
      }
      sidebarController.labels.removeAt(index);
      Result finalResult = await Client.updateLabels(userController.username.value, sidebarController.labels);
      if (finalResult.success) {
        homeController.refreshLinks();
        return true;
      } else {
        homeController.refreshLinks();
        showSnackBar("An error occured. Please try deleting the label again.", error: true);
        return false;
      }
    } else {
      homeController.refreshLinks();
      showSnackBar("An error occured. Please try deleting the label again.", error: true);
      return false;
    }
  }
  return false;
}

Future<bool?> newLabelDialog(
  context,
  title,
  message,
) async {
  bool isSaving = false;
  Function(TextEditingController) onSubmitted = (controller) async {
    if (isSaving) return false;
    String newLabel = controller.text.trim();
    var sbController = Get.find<SidebarController>();
    List labels = [];
    labels += sbController.labels.value;
    if (labels.any((element) => element.toString().toLowerCase() == newLabel.toLowerCase())) {
      return Result(false, message: "Label already exists.");
    } else {
      isSaving = true;
      labels.add(newLabel);
      Result result = await Client.updateLabels(Get.find<UserController>().username.value, labels);
      if (result.success) {
        sbController.labels.add(newLabel);
        return Result(true, message: "Label created.");
      } else {
        isSaving = false;
        return Result(false, message: 'There was an error. Please try again.');
      }
    }
  };
  if (isScreenWide(context))
    return await Get.dialog(
      BottomDialog(
        onSubmitted: (controller) async {
          Result result = await onSubmitted.call(controller);
          Get.back(result: result.success);
          showSnackBar(result.message, error: !result.success);
        },
        showTextField: true,
        onCancel: () {
          Get.back(result: false);
        },
        title: title,
        message: message,
        confirmText: "DONE",
        cancelText: "CANCEL",
      ),
      useSafeArea: true,
    );

  return await Get.bottomSheet(
    BottomDialog(
      onSubmitted: (controller) async {
        Result result = await onSubmitted.call(controller);
        Get.back(result: result.success);
        showSnackBar(result.message, error: !result.success);
      },
      showTextField: true,
      onCancel: () {
        Get.back(result: false);
      },
      title: title,
      message: message,
      confirmText: "DONE",
      cancelText: "CANCEL",
    ),
    isScrollControlled: true,
  );
}

Future<bool?> switchUserDialog(context, title, message, {bool refreshOnSwitch = false}) async {
  bool isSaving = false;
  refreshOnSwitch = Get.find<HomeController>().showSidebar.value;
  if (!refreshOnSwitch) {
    if (isDesktop) {
      refreshOnSwitch = true;
    } else {
      refreshOnSwitch = Navigator.canPop(context);
    }
  }
  Function(TextEditingController) onSubmitted = (controller) async {
    if (isSaving) return false;
    String newUser = controller.text.trim();
    if (newUser == Get.find<UserController>().username.value) return Result(true);
    isSaving = true;
    Result result = await Client.doesUserExist(newUser);
    isSaving = false;
    print(result.message);
    if (result.success) {
      if (result.message) {
        Get.find<SidebarController>().reset();
        Get.find<UserController>().username(newUser);
        Get.find<SidebarController>().refreshLabels();
        if (refreshOnSwitch) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', newUser);
          Get.find<HomeController>().reset();
          Get.find<HomeController>().refreshLinks();
          Get.find<HomeController>().toggleSidebar(value: false);
        }
        return Result(true, message: "Switched to $newUser");
      } else {
        return Result(false, message: "This user doesn't exist");
      }
    } else {
      return Result(false, message: "Something went wrong.");
    }
  };
  if (isScreenWide(context))
    return await Get.dialog(
      BottomDialog(
        onSubmitted: (controller) async {
          Result result = await onSubmitted.call(controller);
          Get.back(result: result.success);
          showSnackBar(result.message, error: !result.success);
        },
        showTextField: true,
        hint: "Username",
        onCancel: () {
          Get.back(result: false);
        },
        title: title,
        message: message,
        confirmText: "DONE",
        cancelText: "CANCEL",
      ),
      useSafeArea: true,
    );

  return await Get.bottomSheet(
    BottomDialog(
      onSubmitted: (controller) async {
        Result result = await onSubmitted.call(controller);
        Get.back(result: result.success);
        showSnackBar(result.message, error: !result.success);
      },
      showTextField: true,
      hint: "Username",
      onCancel: () {
        Get.back(result: false);
      },
      title: title,
      message: message,
      confirmText: "DONE",
      cancelText: "CANCEL",
    ),
    isScrollControlled: true,
  );
}

Future<bool?> editLabelDialog(
  context,
  index,
  title,
  message,
  hint,
) async {
  bool isSaving = false;
  Function(TextEditingController) onSubmitted = (controller) async {
    if (isSaving) return false;
    String newLabel = controller.text.trim();
    var sbController = Get.find<SidebarController>();
    List labels = [];
    labels += sbController.labels.value;

    if (newLabel.isEmpty) {
      return Result(false, message: "Please enter a valid name.");
    } else if (labels.any((element) => element.toString().toLowerCase() == newLabel.toLowerCase())) {
      return Result(false, message: "Label already exists.");
    } else {
      isSaving = true;
      labels[index] = newLabel;
      Result result = await Client.updateLabels(Get.find<UserController>().username.value, labels);
      if (result.success) {
        sbController.labels[index] = newLabel;
        return Result(true, message: "Label updated.");
      } else {
        isSaving = false;
        return Result(false, message: 'There was an error. Please try again.');
      }
    }
  };
  if (isScreenWide(context))
    return await Get.dialog(
      BottomDialog(
        onSubmitted: (controller) async {
          Result result = await onSubmitted.call(controller);
          Get.back(result: result.success);
          showSnackBar(result.message, error: !result.success);
        },
        optionalText: "DELETE",
        onOptional: () async {
          Get.back();
          deleteLabel(context, index);
        },
        showTextField: true,
        onCancel: () {
          Get.back(result: false);
        },
        hint: hint,
        title: title,
        message: message,
        confirmText: "DONE",
        cancelText: "CANCEL",
      ),
      useSafeArea: true,
    );

  return await Get.bottomSheet(
    BottomDialog(
      onSubmitted: (controller) async {
        Result result = await onSubmitted.call(controller);
        Get.back(result: result.success);
        showSnackBar(result.message, error: !result.success);
      },
      showTextField: true,
      onCancel: () {
        Get.back(result: false);
      },
      hint: hint,
      title: title,
      message: message,
      optionalText: "DELETE",
      onOptional: () {
        Get.back();
        deleteLabel(context, index);
      },
      confirmText: "DONE",
      cancelText: "CANCEL",
    ),
    isScrollControlled: true,
  );
}

Future<void> hideKeyboard(context, {delay = const Duration(milliseconds: 200)}) async {
  if (FocusScope.of(context).hasFocus) {
    FocusScope.of(context).unfocus();
    await Future.delayed(delay);
  }
  return;
}

int compareLinksList(Link link1, Link link2, int sortBy, bool ascending) {
  if (!ascending) {
    if (sortBy == 0) return link2.timestamp.compareTo(link1.timestamp);
    return link2.updatedAt.compareTo(link1.updatedAt);
  }
  if (sortBy == 0) return link1.timestamp.compareTo(link2.timestamp);
  return link1.updatedAt.compareTo(link2.updatedAt);
}

Future<Link> getLinkData(Link link) async {
  if (link.autotitle) {
    if (link.title?.isNotEmpty ?? false) return link;
    if (link.url.isValidLink) {
      if (link.url.isYoutubeLink) {
        print(link.url);
        link = await YoutubeData.getDetails(link);
      } else if (link.url.isRedditLink) {
        link = await RedditData.getDetails(link);
      } else {
        link.title = await UrlParser.getUrlTitle(link.url);
      }
      if (link.title!.isEmpty) link.title = null;
    }
  }
  return link;
}

Future<bool> saveLink(context, String url, String title, int colorIndex, List<int> labels, bool autotitle, {String? uid}) async {
  hideKeyboard(context);
  HomeController? controller;

  try {
    controller = Get.find<HomeController>();
  } catch (e) {}

  Result result = await Client.saveLink(
    uid: uid,
    colorIndex: colorIndex,
    labels: labels,
    title: title,
    url: url,
    autotitle: autotitle,
  );
  if (result.success) {
    Link link = Link.fromJson(result.message);
    controller?.linkAdded(link, uid: uid);
  } else {
    showSnackBar(
      result.message ?? "There was an error. Please try again.",
      error: true,
    );
  }
  return result.success;
}

bool get isMacOS => Platform.isMacOS;

bool get isLinux => Platform.isLinux;

bool get isAndroid => Platform.isAndroid;

bool get isIOS => Platform.isIOS;

bool get isWindows => Platform.isWindows;

bool get isMobile => isAndroid || isIOS;

bool get isDesktop => isMacOS || isLinux || isWindows;

bool isScreenWide(context) {
  Size size = MediaQuery.of(context).size;
  return size.height <= size.width * 1.6;
}

showSnackBar(message, {error = false, title}) {
  GetSnackBar(
    titleText: title != null
        ? Text(
            title,
            style: GoogleFonts.poppins(
              color: error ? Colors.white : Get.find<ThemeController>().currentTheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    backgroundColor: error ? Colors.red : Get.find<ThemeController>().currentTheme.mutedBg,
    messageText: Text(
      message,
      style: GoogleFonts.poppins(
        color: error ? Colors.white : Get.find<ThemeController>().currentTheme.foreground,
      ),
    ),
    duration: 2.seconds,
    animationDuration: 500.milliseconds,
    forwardAnimationCurve: Curves.fastOutSlowIn,
    reverseAnimationCurve: Curves.fastOutSlowIn,
  ).show();
}

Future<void> openAndDelete(context, Link link) async {
  if (await confirmDialog(context, "Open and delete link?", "Are you sure you want to open and then delete this link? This cannot be undone.") ??
      false) {
    if (await launchUrl(
      Uri.parse(link.url),
      mode: LaunchMode.externalApplication,
    )) {
      await Get.find<HomeController>().deleteLink(context, link.uid);
      Get.back();
    } else {
      showSnackBar("An error occured. Please try again.");
    }
  }
}

bool searchLabels(String query, List<int> labels) {
  bool labelExists = false;
  List allLabels = Get.find<SidebarController>().labels;
  allLabels.where((label) => labels.contains(allLabels.indexOf(label))).forEach((label) {
    labelExists = label.toString().toLowerCase().contains(query);
  });
  return labelExists;
}
