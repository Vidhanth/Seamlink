import 'dart:io' hide Link;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seamlink/components/confirm_dialog.dart';
import 'package:seamlink/components/link_options.dart';
import 'package:seamlink/controllers/HomeController.dart';
import 'package:seamlink/models/link.dart';
import 'package:seamlink/models/result.dart';
import 'package:seamlink/services/client.dart';
import 'package:seamlink/services/reddit_data.dart';
import 'package:seamlink/services/url_parser.dart';
import 'package:seamlink/services/extensions.dart';
import 'package:seamlink/services/youtube_data.dart';
import 'package:url_launcher/url_launcher.dart';

void showLinkOptions(context, Link link) {
  if (isScreenWide(context)) {
    Get.dialog(LinkOptions(link: link));
  } else {
    Get.bottomSheet(LinkOptions(link: link));
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

Future<void> hideKeyboard(context,
    {delay = const Duration(milliseconds: 200)}) async {
  if (FocusScope.of(context).hasFocus) {
    FocusScope.of(context).unfocus();
    await Future.delayed(delay);
  }
  return;
}

int compareLinksList(Link link1, Link link2) {
  return link2.timestamp.compareTo(link1.timestamp);
}

Future<Link> getLinkData(Link link) async {
  if (link.autotitle) {
    if (link.title.isNotEmpty) return link;
    if (link.url.isValidLink) {
      if (link.url.isYoutubeLink) {
        link = await YoutubeData.getDetails(link);
      } else if (link.url.isRedditLink) {
        link = await RedditData.getDetails(link);
      } else {
        link.title = await UrlParser.getUrlTitle(link.url);
      }
    }
  }
  return link;
}

Future<bool> saveLink(context, String url, String title, int colorIndex,
    List<String> labels, bool autotitle,
    {String? uid}) async {
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
      context,
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

showSnackBar(context, text, {error = false}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor:
          error ? Colors.red : Theme.of(context).snackBarTheme.backgroundColor,
      content: Text(
        text,
        style: GoogleFonts.poppins(),
      ),
    ),
  );
}

Future<void> openAndDelete(context, Link link) async {
  if (link.url.isValidLink) {
    if (await confirmDialog(context, "Open and delete link?",
            "Are you sure you want to open and then delete this link? This cannot be undone.") ??
        false) {
      if (await launch(link.url)) {
        await Get.find<HomeController>().deleteLink(context, link.uid);
        Get.back();
      } else {
        showSnackBar(context, "An error occured. Please try again.");
      }
    }
  }
}
